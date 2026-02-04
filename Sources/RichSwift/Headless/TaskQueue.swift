import Foundation

/// A task that can be queued and executed
public struct QueuedTask: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let priority: Priority
    public let createdAt: Date
    public var status: Status
    public var result: Result?
    public var startedAt: Date?
    public var completedAt: Date?
    public var progress: Double
    public var metadata: [String: String]
    
    public enum Priority: Int, Sendable, Comparable {
        case low = 0
        case normal = 1
        case high = 2
        case critical = 3
        
        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public enum Status: String, Sendable, Codable {
        case pending
        case running
        case completed
        case failed
        case cancelled
    }
    
    public struct Result: Sendable {
        public let success: Bool
        public let message: String?
        public let error: String?
        public let data: [String: String]
        
        public init(success: Bool, message: String? = nil, error: String? = nil, data: [String: String] = [:]) {
            self.success = success
            self.message = message
            self.error = error
            self.data = data
        }
    }
    
    public init(
        id: UUID = UUID(),
        name: String,
        priority: Priority = .normal,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.name = name
        self.priority = priority
        self.createdAt = Date()
        self.status = .pending
        self.result = nil
        self.startedAt = nil
        self.completedAt = nil
        self.progress = 0
        self.metadata = metadata
    }
}

/// Asynchronous task queue for headless environments
public actor TaskQueue {
    public typealias TaskHandler = @Sendable (QueuedTask) async throws -> QueuedTask.Result
    
    private var tasks: [QueuedTask] = []
    private var handlers: [String: TaskHandler] = [:]
    private var isRunning = false
    private var maxConcurrent: Int
    private var runningCount = 0
    
    public init(maxConcurrent: Int = 4) {
        self.maxConcurrent = maxConcurrent
    }
    
    // MARK: - Task Management
    
    /// Add a task to the queue
    @discardableResult
    public func enqueue(_ task: QueuedTask) -> UUID {
        var newTask = task
        newTask.status = .pending
        tasks.append(newTask)
        
        // Sort by priority (highest first) then by creation time
        tasks.sort { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority > task2.priority
            }
            return task1.createdAt < task2.createdAt
        }
        
        return task.id
    }
    
    /// Enqueue a task with just a name
    @discardableResult
    public func enqueue(name: String, priority: QueuedTask.Priority = .normal) -> UUID {
        let task = QueuedTask(name: name, priority: priority)
        return enqueue(task)
    }
    
    /// Cancel a pending task
    public func cancel(id: UUID) -> Bool {
        if let index = tasks.firstIndex(where: { $0.id == id && $0.status == .pending }) {
            tasks[index].status = .cancelled
            return true
        }
        return false
    }
    
    /// Get task by ID
    public func task(id: UUID) -> QueuedTask? {
        tasks.first { $0.id == id }
    }
    
    /// Get all tasks
    public func allTasks() -> [QueuedTask] {
        tasks
    }
    
    /// Get tasks by status
    public func tasks(withStatus status: QueuedTask.Status) -> [QueuedTask] {
        tasks.filter { $0.status == status }
    }
    
    /// Get pending task count
    public var pendingCount: Int {
        tasks.filter { $0.status == .pending }.count
    }
    
    /// Get running task count
    public var currentlyRunning: Int {
        runningCount
    }
    
    // MARK: - Handler Registration
    
    /// Register a handler for a task type (by name pattern)
    public func registerHandler(pattern: String, handler: @escaping TaskHandler) {
        handlers[pattern] = handler
    }
    
    /// Register a default handler for all tasks
    public func registerDefaultHandler(_ handler: @escaping TaskHandler) {
        handlers["*"] = handler
    }
    
    // MARK: - Execution
    
    /// Start processing the queue
    public func start() async {
        guard !isRunning else { return }
        isRunning = true
        
        while isRunning && (pendingCount > 0 || runningCount > 0) {
            // Process available slots
            while runningCount < maxConcurrent, let nextTask = nextPendingTask() {
                runningCount += 1
                let taskId = nextTask.id
                
                // Mark as running
                updateTask(id: taskId) { task in
                    task.status = .running
                    task.startedAt = Date()
                }
                
                // Execute in background
                Task {
                    await self.executeTask(id: taskId)
                }
            }
            
            // Brief pause to avoid spinning
            try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        }
    }
    
    /// Stop processing (finishes current tasks)
    public func stop() {
        isRunning = false
    }
    
    /// Process a single task synchronously
    public func processNext() async -> QueuedTask? {
        guard let task = nextPendingTask() else { return nil }
        
        updateTask(id: task.id) { t in
            t.status = .running
            t.startedAt = Date()
        }
        
        await executeTask(id: task.id)
        return self.task(id: task.id)
    }
    
    // MARK: - Private
    
    private func nextPendingTask() -> QueuedTask? {
        tasks.first { $0.status == .pending }
    }
    
    private func executeTask(id: UUID) async {
        guard let task = self.task(id: id) else {
            runningCount = max(0, runningCount - 1)
            return
        }
        
        do {
            // Find handler
            let handler = handlers[task.name] ?? handlers["*"]
            
            guard let handler = handler else {
                updateTask(id: id) { t in
                    t.status = .failed
                    t.completedAt = Date()
                    t.result = QueuedTask.Result(success: false, error: "No handler registered for task: \(task.name)")
                }
                runningCount = max(0, runningCount - 1)
                return
            }
            
            let result = try await handler(task)
            
            updateTask(id: id) { t in
                t.status = result.success ? .completed : .failed
                t.completedAt = Date()
                t.result = result
                t.progress = 1.0
            }
        } catch {
            updateTask(id: id) { t in
                t.status = .failed
                t.completedAt = Date()
                t.result = QueuedTask.Result(success: false, error: error.localizedDescription)
            }
        }
        
        runningCount = max(0, runningCount - 1)
    }
    
    private func updateTask(id: UUID, update: (inout QueuedTask) -> Void) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            update(&tasks[index])
        }
    }
    
    /// Update progress for a running task
    public func updateProgress(id: UUID, progress: Double) {
        updateTask(id: id) { task in
            task.progress = min(1.0, max(0.0, progress))
        }
    }
}

// MARK: - Console Integration

extension Console {
    /// Print task queue status
    public func printQueueStatus(_ queue: TaskQueue) async {
        let tasks = await queue.allTasks()
        let pending = tasks.filter { $0.status == .pending }.count
        let running = tasks.filter { $0.status == .running }.count
        let completed = tasks.filter { $0.status == .completed }.count
        let failed = tasks.filter { $0.status == .failed }.count
        
        let table = Table()
        table.addColumn("Status")
        table.addColumn("Count")
        
        table.addRow(["⏳ Pending", "\(pending)"])
        table.addRow(["🔄 Running", "\(running)"])
        table.addRow(["✅ Completed", "\(completed)"])
        table.addRow(["❌ Failed", "\(failed)"])
        
        // Render table to string then wrap in panel
        let rendered = table.render(console: self)
        print(Panel(rendered.plain, title: "Task Queue Status"))
    }
}
