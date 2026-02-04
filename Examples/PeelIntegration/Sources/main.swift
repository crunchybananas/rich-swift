import Foundation
import RichSwift

// MARK: - Peel Integration Example
//
// This example demonstrates how RichSwift can be used as the console UI
// foundation for a headless AI agent like Peel. It shows:
//
// 1. Structured event emission for machine-readable output
// 2. Progress persistence that survives restarts
// 3. Task queuing for batch operations
// 4. Environment-aware output formatting
// 5. Rich console output when running interactively
//

// MARK: - Agent Configuration

/// Configuration for the Peel agent
struct AgentConfig {
    let outputFormat: OutputFormat
    let isHeadless: Bool
    let workingDirectory: URL
    let progressStorePath: URL?
    
    static func fromEnvironment() -> AgentConfig {
        let envConfig = Environment.suggestedConfig
        
        // Override format based on PEEL_OUTPUT environment variable
        let format: OutputFormat
        if let peelOutput = ProcessInfo.processInfo.environment["PEEL_OUTPUT"] {
            switch peelOutput.lowercased() {
            case "json": format = .json
            case "ndjson": format = .ndjson
            case "plain": format = .plain
            default: format = envConfig.format
            }
        } else {
            format = envConfig.format
        }
        
        return AgentConfig(
            outputFormat: format,
            isHeadless: envConfig.isCI || format == .json || format == .ndjson,
            workingDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
            progressStorePath: nil
        )
    }
}

// MARK: - Agent Events

/// Standard event types for Peel agent
struct AgentEvents {
    static let taskStarted = "agent.task.started"
    static let taskProgress = "agent.task.progress"
    static let taskCompleted = "agent.task.completed"
    static let taskFailed = "agent.task.failed"
    static let fileCreated = "agent.file.created"
    static let fileModified = "agent.file.modified"
    static let commandExecuted = "agent.command.executed"
    static let modelQuery = "agent.model.query"
    static let modelResponse = "agent.model.response"
}

// MARK: - Agent Task Types

enum AgentTask: String, CaseIterable {
    case analyzeCode = "analyze-code"
    case generateCode = "generate-code"
    case refactorCode = "refactor-code"
    case runTests = "run-tests"
    case createPR = "create-pr"
    
    var description: String {
        switch self {
        case .analyzeCode: return "Analyzing codebase"
        case .generateCode: return "Generating code"
        case .refactorCode: return "Refactoring code"
        case .runTests: return "Running tests"
        case .createPR: return "Creating pull request"
        }
    }
}

// MARK: - Peel Agent

/// Example headless AI agent using RichSwift for output
actor PeelAgent {
    let config: AgentConfig
    let console: Console
    let eventEmitter: EventEmitter
    let progressStore: ProgressStore
    let taskQueue: TaskQueue
    
    init(config: AgentConfig) {
        self.config = config
        self.console = Console()
        self.eventEmitter = EventEmitter()
        self.progressStore = ProgressStore(path: config.progressStorePath)
        self.taskQueue = TaskQueue(maxConcurrent: 2)
    }
    
    // MARK: - Output Helpers
    
    /// Emit output - either as structured JSON or rich console output
    func output(_ message: String, type: String, level: Event.Level = .info, data: [String: Any] = [:]) async {
        if config.isHeadless {
            // Machine-readable output
            console.emit(type, message: message, level: level, data: data)
        } else {
            // Human-readable output
            switch level {
            case .debug:
                console.print("[dim]\(message)[/dim]".asMarkup)
            case .info:
                console.info(message)
            case .warning:
                console.warning(message)
            case .error:
                console.error(message)
            case .critical:
                console.error(message)
            }
        }
    }
    
    // MARK: - Task Execution
    
    /// Run a task with progress tracking
    func runTask(_ task: AgentTask, params: [String: String] = [:]) async throws {
        let taskId = "\(task.rawValue)-\(UUID().uuidString.prefix(8))"
        
        // Start progress
        let progress = await progressStore.getOrCreate(
            id: taskId,
            label: task.description,
            total: 100
        )
        
        await output(
            "Starting: \(task.description)",
            type: AgentEvents.taskStarted,
            data: ["taskId": taskId, "task": task.rawValue]
        )
        
        if !config.isHeadless {
            // Show rich progress in interactive mode
            console.print(Panel(
                "📋 Task: \(task.description)\n🆔 ID: \(taskId)",
                title: "Starting Task",
                borderStyle: Style(foreground: .cyan)
            ))
        }
        
        do {
            // Simulate task execution with progress updates
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms
                
                let completed = Double(i * 10)
                await progressStore.update(id: taskId, completed: completed)
                
                if !config.isHeadless {
                    // Update console progress
                    let bar = ProgressBar(completed: completed, total: 100, width: 40)
                    console.print("\r\(bar.render(console: console).render()) \(Int(completed))%", end: "")
                } else {
                    console.emitProgress(
                        task: taskId,
                        completed: completed,
                        total: 100,
                        message: "Step \(i)/10"
                    )
                }
            }
            
            if !config.isHeadless {
                console.print("") // newline after progress
            }
            
            // Complete the task
            await progressStore.complete(id: taskId, message: "Task completed successfully")
            
            await output(
                "Completed: \(task.description)",
                type: AgentEvents.taskCompleted,
                data: [
                    "taskId": taskId,
                    "duration": progress.duration.description
                ]
            )
            
            if !config.isHeadless {
                console.success("✅ Task completed successfully")
            }
            
        } catch {
            await progressStore.fail(id: taskId, error: error.localizedDescription)
            
            await output(
                "Failed: \(task.description)",
                type: AgentEvents.taskFailed,
                level: .error,
                data: [
                    "taskId": taskId,
                    "error": error.localizedDescription
                ]
            )
            
            throw error
        }
    }
    
    // MARK: - File Operations
    
    func reportFileCreated(path: String, content: String) async {
        await output(
            "Created file: \(path)",
            type: AgentEvents.fileCreated,
            data: [
                "path": path,
                "size": content.count
            ]
        )
        
        if !config.isHeadless {
            // Show syntax-highlighted preview
            let ext = URL(fileURLWithPath: path).pathExtension
            let language = Syntax.Language.fromExtension(ext)
            let preview = String(content.prefix(500))
            
            let syntax = Syntax(preview, language: language, lineNumbers: true)
            console.print(Panel(
                syntax.render(console: console).plain,
                title: "📄 \(path)",
                borderStyle: Style(foreground: .green)
            ))
        }
    }
    
    // MARK: - Model Interaction
    
    func queryModel(prompt: String, context: [String: Any] = [:]) async -> String {
        await output(
            "Querying model",
            type: AgentEvents.modelQuery,
            data: ["promptLength": prompt.count]
        )
        
        if !config.isHeadless {
            console.print("[dim]🤖 Querying AI model...[/dim]".asMarkup)
        }
        
        // Simulate model response
        try? await Task.sleep(nanoseconds: 500_000_000)
        let response = "Model response for: \(prompt.prefix(50))..."
        
        await output(
            "Model response received",
            type: AgentEvents.modelResponse,
            data: ["responseLength": response.count]
        )
        
        return response
    }
    
    // MARK: - Batch Processing
    
    func processFiles(_ files: [String]) async throws -> BatchProcessor<String>.BatchResult {
        await output(
            "Processing \(files.count) files",
            type: "agent.batch.started",
            data: ["count": files.count]
        )
        
        let processor = BatchProcessor(
            items: files,
            progressStore: progressStore,
            progressId: "batch-\(UUID().uuidString.prefix(8))"
        )
        
        let result = try await processor.process(concurrency: 4) { file, index, total in
            // Simulate processing each file
            try await Task.sleep(nanoseconds: 100_000_000)
            
            await self.output(
                "Processed: \(file)",
                type: "agent.file.processed",
                level: .debug,
                data: ["index": index, "total": total]
            )
        }
        
        await output(
            "Batch complete: \(result.succeeded)/\(result.total) succeeded",
            type: "agent.batch.completed",
            data: [
                "total": result.total,
                "succeeded": result.succeeded,
                "failed": result.failed
            ]
        )
        
        return result
    }
}

// MARK: - Main Entry Point

@main
struct PeelAgentMain {
    static func main() async {
        let config = AgentConfig.fromEnvironment()
        let agent = PeelAgent(config: config)
        let console = Console()
        
        // Show banner in interactive mode
        if !config.isHeadless {
            console.print(Panel(
                """
                🍐 Peel Agent Example
                
                Demonstrating RichSwift integration with a headless AI agent.
                
                Output Mode: \(config.outputFormat)
                Headless: \(config.isHeadless)
                """,
                title: "Peel Agent",
                borderStyle: Style(foreground: .magenta)
            ))
            console.print("")
        }
        
        do {
            // Run some example tasks
            try await agent.runTask(.analyzeCode)
            
            // Simulate file creation
            await agent.reportFileCreated(
                path: "src/NewFeature.swift",
                content: """
                import Foundation
                
                /// New feature implementation
                public struct NewFeature {
                    public init() {}
                    
                    public func execute() async throws {
                        // Implementation here
                    }
                }
                """
            )
            
            // Process batch of files
            let files = ["file1.swift", "file2.swift", "file3.swift", "file4.swift"]
            let result = try await agent.processFiles(files)
            
            if !config.isHeadless {
                let table = Table()
                table.addColumn("Metric")
                table.addColumn("Value")
                table.addRow(["Total Files", "\(result.total)"])
                table.addRow(["Succeeded", "\(result.succeeded)"])
                table.addRow(["Failed", "\(result.failed)"])
                
                console.print(Panel(
                    table.render(console: console).plain,
                    title: "Batch Results",
                    borderStyle: Style(foreground: .blue)
                ))
            }
            
            // Show final summary
            if !config.isHeadless {
                console.print("")
                console.success("🎉 All tasks completed!")
            } else {
                console.emitComplete(task: "all", data: [
                    "tasksCompleted": 1,
                    "filesCreated": 1,
                    "filesProcessed": files.count
                ])
            }
            
        } catch {
            if !config.isHeadless {
                console.error("Agent failed: \(error)")
            } else {
                console.emit(
                    "agent.error",
                    message: error.localizedDescription,
                    level: .error
                )
            }
        }
    }
}
