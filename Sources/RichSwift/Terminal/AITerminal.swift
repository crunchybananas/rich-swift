import Foundation

/// AI-friendly terminal that adapts commands and provides structured output
public actor AITerminal {
    
    public struct Config: Sendable {
        public var shellPath: String
        public var workingDirectory: URL
        public var environment: [String: String]
        public var timeout: TimeInterval
        public var adaptCommands: Bool
        public var sanitizeCommands: Bool
        public var maxRiskLevel: CommandSanitizer.RiskLevel
        public var captureOutput: Bool
        
        public static var `default`: Config {
            Config(
                shellPath: ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh",
                workingDirectory: URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
                environment: ProcessInfo.processInfo.environment,
                timeout: 300, // 5 minutes
                adaptCommands: true,
                sanitizeCommands: true,
                maxRiskLevel: .high,
                captureOutput: true
            )
        }
    }
    
    public struct CommandResult: Sendable {
        public let command: String
        public let adaptedCommand: String?
        public let exitCode: Int32
        public let stdout: String
        public let stderr: String
        public let duration: TimeInterval
        public let wasAdapted: Bool
        public let adaptationChanges: [CommandChange]
        public let sanitizationWarnings: [String]
        
        public var succeeded: Bool { exitCode == 0 }
        
        public var output: String {
            if stderr.isEmpty {
                return stdout
            }
            return stdout + (stdout.isEmpty ? "" : "\n") + stderr
        }
        
        /// JSON representation for AI consumption
        public func toJSON() -> String {
            let data: [String: Any] = [
                "command": command,
                "adapted_command": adaptedCommand as Any,
                "exit_code": exitCode,
                "stdout": stdout,
                "stderr": stderr,
                "duration_ms": Int(duration * 1000),
                "success": succeeded,
                "was_adapted": wasAdapted,
                "adaptation_changes": adaptationChanges.map { [
                    "type": $0.type.rawValue,
                    "description": $0.description,
                    "original": $0.original,
                    "replacement": $0.replacement
                ]},
                "warnings": sanitizationWarnings
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            return "{}"
        }
    }
    
    private let config: Config
    private let adapter: ShellAdapter
    private let sanitizer: CommandSanitizer
    private let console: Console
    private var commandHistory: [CommandResult] = []
    
    public init(config: Config = .default) {
        self.config = config
        self.adapter = ShellAdapter(targetShell: .current)
        self.sanitizer = CommandSanitizer()
        self.console = Console()
    }
    
    // MARK: - Command Execution
    
    /// Execute a command with adaptation and sanitization
    public func run(_ command: String) async throws -> CommandResult {
        let startDate = Date()
        
        // Sanitize if enabled
        var warnings: [String] = []
        if config.sanitizeCommands {
            let sanitization = sanitizer.analyze(command)
            warnings = sanitization.warnings
            
            if !sanitization.isAllowed {
                throw TerminalError.commandBlocked(reason: sanitization.blockedReason ?? "Unknown")
            }
            
            if sanitization.riskLevel > config.maxRiskLevel {
                throw TerminalError.riskTooHigh(level: sanitization.riskLevel, max: config.maxRiskLevel)
            }
        }
        
        // Adapt if enabled
        var adaptedCommand = command
        var changes: [CommandChange] = []
        if config.adaptCommands {
            let adapted = adapter.adapt(command)
            adaptedCommand = adapted.adapted
            changes = adapted.changes
        }
        
        // Execute
        let (stdout, stderr, exitCode) = try await execute(adaptedCommand)
        
        let duration = Date().timeIntervalSince(startDate)
        
        let result = CommandResult(
            command: command,
            adaptedCommand: adaptedCommand != command ? adaptedCommand : nil,
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr,
            duration: duration,
            wasAdapted: adaptedCommand != command,
            adaptationChanges: changes,
            sanitizationWarnings: warnings
        )
        
        commandHistory.append(result)
        
        return result
    }
    
    /// Execute multiple commands in sequence
    public func runSequence(_ commands: [String], stopOnError: Bool = true) async throws -> [CommandResult] {
        var results: [CommandResult] = []
        
        for command in commands {
            let result = try await run(command)
            results.append(result)
            
            if stopOnError && !result.succeeded {
                break
            }
        }
        
        return results
    }
    
    /// Execute a command and return just the output
    public func output(_ command: String) async throws -> String {
        let result = try await run(command)
        if result.succeeded {
            return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        throw TerminalError.commandFailed(exitCode: result.exitCode, stderr: result.stderr)
    }
    
    // MARK: - Private Execution
    
    private func execute(_ command: String) async throws -> (stdout: String, stderr: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: config.shellPath)
        process.arguments = ["-c", command]
        process.currentDirectoryURL = config.workingDirectory
        process.environment = config.environment
        
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try process.run()
                
                // Set up timeout
                let timeoutTask = Task {
                    try await Task.sleep(nanoseconds: UInt64(config.timeout * 1_000_000_000))
                    if process.isRunning {
                        process.terminate()
                    }
                }
                
                process.waitUntilExit()
                timeoutTask.cancel()
                
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                
                continuation.resume(returning: (stdout, stderr, process.terminationStatus))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - History
    
    public func history() -> [CommandResult] {
        commandHistory
    }
    
    public func clearHistory() {
        commandHistory.removeAll()
    }
    
    public func lastResult() -> CommandResult? {
        commandHistory.last
    }
}

// MARK: - Errors

public enum TerminalError: Error, LocalizedError {
    case commandBlocked(reason: String)
    case riskTooHigh(level: CommandSanitizer.RiskLevel, max: CommandSanitizer.RiskLevel)
    case commandFailed(exitCode: Int32, stderr: String)
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .commandBlocked(let reason):
            return "Command blocked: \(reason)"
        case .riskTooHigh(let level, let max):
            return "Command risk level (\(level)) exceeds maximum allowed (\(max))"
        case .commandFailed(let code, let stderr):
            return "Command failed with exit code \(code): \(stderr)"
        case .timeout:
            return "Command timed out"
        }
    }
}

// MARK: - Console Extensions

extension Console {
    /// Print a command result with rich formatting
    public func printCommandResult(_ result: AITerminal.CommandResult) {
        // Show adaptation info if changed
        if result.wasAdapted {
            print(Panel(
                """
                [dim]Original:[/dim] \(result.command)
                [dim]Adapted:[/dim]  \(result.adaptedCommand ?? result.command)
                """,
                title: "🔄 Command Adapted",
                borderStyle: Style(foreground: .yellow)
            ))
            
            for change in result.adaptationChanges {
                print("  [yellow]•[/yellow] \(change.description)".asMarkup)
            }
            print("")
        }
        
        // Show warnings
        for warningMsg in result.sanitizationWarnings {
            warning("⚠️ \(warningMsg)")
        }
        
        // Show output
        if !result.stdout.isEmpty {
            print(result.stdout, end: result.stdout.hasSuffix("\n") ? "" : "\n")
        }
        
        if !result.stderr.isEmpty {
            print("[red]\(result.stderr)[/red]".asMarkup, end: result.stderr.hasSuffix("\n") ? "" : "\n")
        }
        
        // Show status
        if result.succeeded {
            print("[dim]✓ Exit code: 0 (\(String(format: "%.2f", result.duration))s)[/dim]".asMarkup)
        } else {
            print("[red]✗ Exit code: \(result.exitCode) (\(String(format: "%.2f", result.duration))s)[/red]".asMarkup)
        }
    }
}
