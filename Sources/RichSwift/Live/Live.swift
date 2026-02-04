import Foundation

/// Provides live (updating in place) display capabilities
public actor Live {
    private let console: Console
    private var lastLineCount: Int = 0
    private var isStarted: Bool = false
    
    /// Create a Live display context
    public init(console: Console = .shared) {
        self.console = console
    }
    
    /// Clear the lines we previously wrote
    private func clearPreviousOutput() {
        guard lastLineCount > 0, console.terminal.isTerminal else { return }
        
        // Move cursor up and clear each line
        for _ in 0..<lastLineCount {
            write("\u{001B}[A") // Move up
            write("\u{001B}[2K") // Clear line
        }
        write("\r") // Return to start of line
    }
    
    /// Update the display with new content
    public func update(_ renderable: Renderable) {
        clearPreviousOutput()
        
        let text = renderable.render(console: console)
        let rendered = text.render(forTerminal: console.useColor)
        
        // Count newlines to know how many lines we wrote
        lastLineCount = rendered.filter { $0 == "\n" }.count
        if !rendered.hasSuffix("\n") {
            lastLineCount += 1
        }
        
        write(rendered)
        if !rendered.hasSuffix("\n") {
            write("\n")
        }
        
        // Flush output
        fflush(stdout)
    }
    
    /// Update with a simple string (with markup support)
    public func update(_ message: String) async {
        let text = message.asMarkup
        await update(text)
    }
    
    /// Start the live display
    public func start() {
        guard !isStarted else { return }
        isStarted = true
        
        // Hide cursor for cleaner updates
        if console.terminal.isTerminal {
            write("\u{001B}[?25l")
        }
    }
    
    /// Stop the live display and show cursor
    public func stop() {
        guard isStarted else { return }
        isStarted = false
        
        // Show cursor again
        if console.terminal.isTerminal {
            write("\u{001B}[?25h")
        }
    }
    
    private nonisolated func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }
}

// MARK: - LiveContext for structured concurrency

/// A context for live display that automatically manages start/stop
public struct LiveContext<T: Renderable & Sendable>: Sendable {
    private let live: Live
    private let renderable: T
    private let refreshRate: Duration
    
    public init(
        _ renderable: T,
        console: Console = .shared,
        refreshRate: Duration = .milliseconds(100)
    ) {
        self.live = Live(console: console)
        self.renderable = renderable
        self.refreshRate = refreshRate
    }
    
    /// Run with live display, updating the renderable
    public func run<R: Sendable>(
        _ operation: @Sendable (T) async throws -> R
    ) async throws -> R {
        await live.start()
        
        // Start refresh task
        let refreshTask = Task {
            while !Task.isCancelled {
                await live.update(renderable)
                try? await Task.sleep(for: refreshRate)
            }
        }
        
        defer {
            refreshTask.cancel()
            Task { await live.stop() }
        }
        
        do {
            let result = try await operation(renderable)
            // Final update
            await live.update(renderable)
            return result
        } catch {
            throw error
        }
    }
}
