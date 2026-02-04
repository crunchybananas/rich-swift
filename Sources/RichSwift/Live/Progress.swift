import Foundation

/// A task being tracked by Progress
public actor ProgressTask: Sendable {
    public let id: UUID
    public let description: String
    public private(set) var completed: Double
    public let total: Double
    public private(set) var startTime: ContinuousClock.Instant
    public private(set) var isFinished: Bool = false
    
    public init(description: String, total: Double = 100) {
        self.id = UUID()
        self.description = description
        self.completed = 0
        self.total = total
        self.startTime = .now
    }
    
    /// Update the completed amount
    public func update(_ completed: Double) {
        self.completed = min(completed, total)
        if completed >= total {
            isFinished = true
        }
    }
    
    /// Advance by a certain amount
    public func advance(by amount: Double = 1) {
        self.completed = min(completed + amount, total)
        if completed >= total {
            isFinished = true
        }
    }
    
    /// Get percentage complete
    public var percentage: Double {
        guard total > 0 else { return 0 }
        return min(1.0, completed / total)
    }
    
    /// Get elapsed time
    public var elapsed: Duration {
        ContinuousClock.now - startTime
    }
    
    /// Estimate remaining time
    public var remaining: Duration? {
        guard completed > 0, !isFinished else { return nil }
        let elapsedSeconds = elapsed.components.seconds
        let rate = Double(elapsedSeconds) / completed
        let remainingWork = total - completed
        let remainingSeconds = Int64(rate * remainingWork)
        return .seconds(remainingSeconds)
    }
    
    /// Mark as finished
    public func finish() {
        completed = total
        isFinished = true
    }
}

/// Tracks multiple progress bars with live updates
public actor Progress: Sendable {
    private var tasks: [ProgressTask] = []
    private let console: Console
    private let showSpeed: Bool
    private let showTimeRemaining: Bool
    
    public init(
        console: Console = .shared,
        showSpeed: Bool = true,
        showTimeRemaining: Bool = true
    ) {
        self.console = console
        self.showSpeed = showSpeed
        self.showTimeRemaining = showTimeRemaining
    }
    
    /// Add a new task to track
    public func addTask(description: String, total: Double = 100) -> ProgressTask {
        let task = ProgressTask(description: description, total: total)
        tasks.append(task)
        return task
    }
    
    /// Remove a task
    public func removeTask(_ task: ProgressTask) {
        tasks.removeAll { $0.id == task.id }
    }
    
    /// Check if all tasks are finished
    public var isFinished: Bool {
        get async {
            for task in tasks {
                if await !task.isFinished {
                    return false
                }
            }
            return true
        }
    }
    
    /// Render all progress bars
    public func render() async -> Text {
        var text = Text()
        
        for (index, task) in tasks.enumerated() {
            if index > 0 {
                text.append("\n")
            }
            
            // Immutable properties can be accessed without await
            let description = task.description
            let total = task.total
            // Mutable properties and computed properties need await
            let completed = await task.completed
            let percentage = await task.percentage
            let isFinished = await task.isFinished
            
            // Description
            text.append(description, style: Style.bold)
            text.append(" ")
            
            // Progress bar
            let barWidth = min(40, max(20, console.width - description.count - 30))
            let filledWidth = Int(Double(barWidth) * percentage)
            let emptyWidth = barWidth - filledWidth
            
            let barStyle = isFinished ? Style(foreground: .green) : Style(foreground: .magenta)
            let emptyStyle = Style(foreground: .brightBlack)
            
            text.append(String(repeating: "━", count: filledWidth), style: barStyle)
            text.append(String(repeating: "━", count: emptyWidth), style: emptyStyle)
            
            // Percentage
            let percentText = String(format: " %3.0f%%", percentage * 100)
            text.append(percentText, style: isFinished ? Style(foreground: .green) : .none)
            
            // Completed / Total
            text.append(String(format: " %.0f/%.0f", completed, total), style: Style(foreground: .cyan))
            
            // Time remaining
            if showTimeRemaining, let remaining = await task.remaining {
                let seconds = remaining.components.seconds
                if seconds < 60 {
                    text.append(String(format: " ETA %ds", seconds), style: Style(foreground: .brightBlack))
                } else if seconds < 3600 {
                    text.append(String(format: " ETA %dm%ds", seconds / 60, seconds % 60), style: Style(foreground: .brightBlack))
                } else {
                    text.append(String(format: " ETA %dh%dm", seconds / 3600, (seconds % 3600) / 60), style: Style(foreground: .brightBlack))
                }
            } else if isFinished {
                let elapsed = await task.elapsed
                let seconds = elapsed.components.seconds
                text.append(String(format: " Done in %ds", seconds), style: Style(foreground: .green))
            }
        }
        
        return text
    }
}

// MARK: - Console extension for progress

extension Console {
    /// Track progress of multiple tasks with live display
    public func progress<T: Sendable>(
        _ operation: @Sendable (Progress) async throws -> T
    ) async throws -> T {
        let progress = Progress(console: self)
        let live = Live(console: self)
        
        await live.start()
        
        // Start refresh task
        let refreshTask = Task {
            while !Task.isCancelled {
                await live.update(await progress.render())
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
        
        defer {
            refreshTask.cancel()
            Task {
                // Final render
                await live.update(await progress.render())
                await live.stop()
            }
        }
        
        return try await operation(progress)
    }
    
    /// Simple progress iteration over a sequence
    public func progress<S: Sequence & Sendable>(
        _ sequence: S,
        description: String = "Working"
    ) -> ProgressSequence<S> where S.Element: Sendable {
        ProgressSequence(sequence: sequence, description: description, console: self)
    }
}

/// A sequence wrapper that shows progress while iterating
public struct ProgressSequence<S: Sequence & Sendable>: AsyncSequence where S.Element: Sendable {
    public typealias Element = S.Element
    
    private let sequence: S
    private let description: String
    private let console: Console
    
    public init(sequence: S, description: String, console: Console) {
        self.sequence = sequence
        self.description = description
        self.console = console
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(
            iterator: sequence.makeIterator(),
            total: Double(sequence.underestimatedCount),
            description: description,
            console: console
        )
    }
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        private var iterator: S.Iterator
        private let total: Double
        private let description: String
        private let console: Console
        private var current: Double = 0
        private let live: Live
        private var started = false
        
        init(iterator: S.Iterator, total: Double, description: String, console: Console) {
            self.iterator = iterator
            self.total = total
            self.description = description
            self.console = console
            self.live = Live(console: console)
        }
        
        public mutating func next() async -> Element? {
            if !started {
                started = true
                await live.start()
            }
            
            guard let element = iterator.next() else {
                // Finished - show 100%
                let bar = ProgressBar(completed: total, total: total, width: 40)
                var text = Text()
                text.append(description, style: Style.bold)
                text.append(" ")
                text.append(bar.render(console: console))
                await live.update(text)
                await live.stop()
                return nil
            }
            
            current += 1
            
            // Update progress display
            let bar = ProgressBar(completed: current, total: total, width: 40)
            var text = Text()
            text.append(description, style: Style.bold)
            text.append(" ")
            text.append(bar.render(console: console))
            await live.update(text)
            
            return element
        }
    }
}
