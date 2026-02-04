import Foundation

/// Persistent progress state for headless/CI environments
public struct PersistentProgress: Codable, Sendable {
    public let id: String
    public var label: String
    public var completed: Double
    public var total: Double
    public var status: Status
    public var startedAt: Date
    public var updatedAt: Date
    public var completedAt: Date?
    public var metadata: [String: String]
    public var checkpoints: [Checkpoint]
    
    public enum Status: String, Codable, Sendable {
        case running
        case paused
        case completed
        case failed
        case cancelled
    }
    
    public struct Checkpoint: Codable, Sendable {
        public let timestamp: Date
        public let completed: Double
        public let message: String?
        
        public init(completed: Double, message: String? = nil) {
            self.timestamp = Date()
            self.completed = completed
            self.message = message
        }
    }
    
    public var percentage: Double {
        guard total > 0 else { return 0 }
        return (completed / total) * 100
    }
    
    public var isFinished: Bool {
        status == .completed || status == .failed || status == .cancelled
    }
    
    public var duration: TimeInterval {
        let endTime = completedAt ?? Date()
        return endTime.timeIntervalSince(startedAt)
    }
    
    public init(
        id: String,
        label: String,
        total: Double = 100,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.label = label
        self.completed = 0
        self.total = total
        self.status = .running
        self.startedAt = Date()
        self.updatedAt = Date()
        self.completedAt = nil
        self.metadata = metadata
        self.checkpoints = []
    }
}

/// Manages persistent progress that survives process restarts
public actor ProgressStore {
    private let storePath: URL
    private var progresses: [String: PersistentProgress] = [:]
    private var autoSave: Bool
    
    public init(path: URL? = nil, autoSave: Bool = true) {
        self.storePath = path ?? Self.defaultStorePath
        self.autoSave = autoSave
        
        // Load existing progress on init
        Task {
            await self.load()
        }
    }
    
    private static var defaultStorePath: URL {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDir.appendingPathComponent("rich-swift-progress.json")
    }
    
    // MARK: - Progress Management
    
    /// Create or get existing progress
    public func getOrCreate(id: String, label: String, total: Double = 100) -> PersistentProgress {
        if let existing = progresses[id], !existing.isFinished {
            return existing
        }
        
        let progress = PersistentProgress(id: id, label: label, total: total)
        progresses[id] = progress
        saveIfNeeded()
        return progress
    }
    
    /// Get progress by ID
    public func get(id: String) -> PersistentProgress? {
        progresses[id]
    }
    
    /// Get all active (non-finished) progresses
    public func activeProgresses() -> [PersistentProgress] {
        progresses.values.filter { !$0.isFinished }
    }
    
    /// Get all progresses
    public func allProgresses() -> [PersistentProgress] {
        Array(progresses.values)
    }
    
    /// Update progress
    public func update(
        id: String,
        completed: Double? = nil,
        status: PersistentProgress.Status? = nil,
        message: String? = nil
    ) {
        guard var progress = progresses[id] else { return }
        
        if let completed = completed {
            progress.completed = completed
            progress.checkpoints.append(.init(completed: completed, message: message))
        }
        
        if let status = status {
            progress.status = status
            if status == .completed || status == .failed || status == .cancelled {
                progress.completedAt = Date()
            }
        }
        
        progress.updatedAt = Date()
        progresses[id] = progress
        saveIfNeeded()
    }
    
    /// Increment progress
    public func increment(id: String, by amount: Double = 1, message: String? = nil) {
        guard var progress = progresses[id] else { return }
        progress.completed += amount
        progress.updatedAt = Date()
        progress.checkpoints.append(.init(completed: progress.completed, message: message))
        progresses[id] = progress
        saveIfNeeded()
    }
    
    /// Mark progress as complete
    public func complete(id: String, message: String? = nil) {
        guard var progress = progresses[id] else { return }
        progress.completed = progress.total
        progress.status = .completed
        progress.completedAt = Date()
        progress.updatedAt = Date()
        if let message = message {
            progress.checkpoints.append(.init(completed: progress.total, message: message))
        }
        progresses[id] = progress
        saveIfNeeded()
    }
    
    /// Mark progress as failed
    public func fail(id: String, error: String? = nil) {
        guard var progress = progresses[id] else { return }
        progress.status = .failed
        progress.completedAt = Date()
        progress.updatedAt = Date()
        if let error = error {
            progress.checkpoints.append(.init(completed: progress.completed, message: "Error: \(error)"))
        }
        progresses[id] = progress
        saveIfNeeded()
    }
    
    /// Remove progress
    public func remove(id: String) {
        progresses.removeValue(forKey: id)
        saveIfNeeded()
    }
    
    /// Clear all progresses
    public func clear() {
        progresses.removeAll()
        saveIfNeeded()
    }
    
    /// Clear finished progresses
    public func clearFinished() {
        progresses = progresses.filter { !$0.value.isFinished }
        saveIfNeeded()
    }
    
    // MARK: - Persistence
    
    /// Save to disk
    public func save() {
        do {
            let data = try JSONEncoder().encode(Array(progresses.values))
            try data.write(to: storePath, options: .atomic)
        } catch {
            // Silently fail - progress persistence is best-effort
        }
    }
    
    /// Load from disk
    public func load() {
        do {
            guard FileManager.default.fileExists(atPath: storePath.path) else { return }
            let data = try Data(contentsOf: storePath)
            let loaded = try JSONDecoder().decode([PersistentProgress].self, from: data)
            progresses = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch {
            // Start fresh on load failure
            progresses = [:]
        }
    }
    
    private func saveIfNeeded() {
        if autoSave {
            save()
        }
    }
}

// MARK: - Console Integration

extension Console {
    /// Print persistent progress summary
    public func printProgressSummary(_ store: ProgressStore) async {
        let active = await store.activeProgresses()
        
        if active.isEmpty {
            print("[dim]No active progress[/dim]".asMarkup)
            return
        }
        
        let table = Table()
        table.addColumn("ID")
        table.addColumn("Label")
        table.addColumn("Progress")
        table.addColumn("Status")
        table.addColumn("Duration")
        
        for progress in active {
            let duration = formatDuration(progress.duration)
            let statusIcon: String
            switch progress.status {
            case .running: statusIcon = "🔄"
            case .paused: statusIcon = "⏸️"
            case .completed: statusIcon = "✅"
            case .failed: statusIcon = "❌"
            case .cancelled: statusIcon = "🚫"
            }
            
            table.addRow([
                progress.id,
                progress.label,
                "\(Int(progress.percentage))%",
                statusIcon,
                duration
            ])
        }
        
        // Render table to string then wrap in panel
        let rendered = table.render(console: self)
        print(Panel(rendered.plain, title: "Progress Summary"))
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        if duration < 60 {
            return String(format: "%.1fs", duration)
        } else if duration < 3600 {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            return "\(minutes)m \(seconds)s"
        } else {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }
}

// MARK: - Batch Operations

/// Batch operation support for processing multiple items
public actor BatchProcessor<Item: Sendable> {
    public typealias ProcessHandler = @Sendable (Item, Int, Int) async throws -> Void
    
    private let items: [Item]
    private var processedCount = 0
    private var failedCount = 0
    private var errors: [(index: Int, error: Error)] = []
    private let progressStore: ProgressStore?
    private let progressId: String?
    
    public init(
        items: [Item],
        progressStore: ProgressStore? = nil,
        progressId: String? = nil
    ) {
        self.items = items
        self.progressStore = progressStore
        self.progressId = progressId
    }
    
    /// Process all items with a handler
    public func process(
        concurrency: Int = 4,
        continueOnError: Bool = true,
        handler: @escaping ProcessHandler
    ) async throws -> BatchResult {
        // Initialize progress
        if let store = progressStore, let id = progressId {
            _ = await store.getOrCreate(id: id, label: "Batch Processing", total: Double(items.count))
        }
        
        // Process in batches
        for i in stride(from: 0, to: items.count, by: concurrency) {
            let batch = Array(items[i..<min(i + concurrency, items.count)])
            
            await withTaskGroup(of: (Int, Error?).self) { group in
                for (offset, item) in batch.enumerated() {
                    let index = i + offset
                    group.addTask {
                        do {
                            try await handler(item, index, self.items.count)
                            return (index, nil)
                        } catch {
                            return (index, error)
                        }
                    }
                }
                
                for await (index, error) in group {
                    if let error = error {
                        failedCount += 1
                        errors.append((index, error))
                        
                        if !continueOnError {
                            // Cancel remaining tasks
                            group.cancelAll()
                            break
                        }
                    }
                    
                    processedCount += 1
                    
                    // Update persistent progress
                    if let store = progressStore, let id = progressId {
                        await store.increment(id: id, by: 1)
                    }
                }
            }
            
            if !continueOnError && failedCount > 0 {
                break
            }
        }
        
        // Mark progress complete
        if let store = progressStore, let id = progressId {
            if failedCount > 0 {
                await store.update(id: id, status: .failed)
            } else {
                await store.complete(id: id)
            }
        }
        
        return BatchResult(
            total: items.count,
            processed: processedCount,
            failed: failedCount,
            errors: errors.map { ($0.index, $0.error.localizedDescription) }
        )
    }
    
    public struct BatchResult: Sendable {
        public let total: Int
        public let processed: Int
        public let failed: Int
        public let errors: [(index: Int, message: String)]
        
        public var succeeded: Int {
            processed - failed
        }
        
        public var isFullSuccess: Bool {
            failed == 0 && processed == total
        }
    }
}
