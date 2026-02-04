import Foundation

/// A status display with spinner and message
public actor Status: Renderable, Sendable {
    private var message: String
    private var spinnerStyle: Spinner.Style
    private var textStyle: Style
    private var spinnerTextStyle: Style
    private var frameIndex: Int = 0
    private var startTime: ContinuousClock.Instant?
    
    public init(
        _ message: String,
        spinner: Spinner.Style = .dots,
        textStyle: Style = .none,
        spinnerStyle: Style = Style(foreground: .green)
    ) {
        self.message = message
        self.spinnerStyle = spinner
        self.textStyle = textStyle
        self.spinnerTextStyle = spinnerStyle
    }
    
    /// Update the status message
    public func update(_ newMessage: String) {
        self.message = newMessage
    }
    
    /// Advance to next spinner frame
    public func tick() {
        let frames = spinnerStyle.frames
        frameIndex = (frameIndex + 1) % frames.count
    }
    
    /// Get current rendered text
    public nonisolated func render(console: Console) -> Text {
        // Note: For actor, we need a sync version for Renderable conformance
        // The actual rendering is done in renderAsync
        var text = Text()
        text.append("⠋ ", style: Style(foreground: .green))
        text.append("Working...", style: .none)
        return text
    }
    
    /// Render with current state (call from async context)
    public func renderAsync() -> Text {
        let frames = spinnerStyle.frames
        let frame = frames[frameIndex % frames.count]
        
        var text = Text()
        text.append("\(frame) ", style: spinnerTextStyle)
        text.append(message, style: textStyle)
        
        if let start = startTime {
            let elapsed = ContinuousClock.now - start
            let seconds = elapsed.components.seconds
            let elapsedText = String(format: " (%.1fs)", Double(seconds) + Double(elapsed.components.attoseconds) / 1e18)
            text.append(elapsedText, style: Style(foreground: .brightBlack))
        }
        
        return text
    }
    
    /// Start tracking time
    public func start() {
        startTime = .now
    }
}

// MARK: - Console extension for status

extension Console {
    /// Run an operation with a status spinner
    @discardableResult
    public func status<T: Sendable>(
        _ message: String,
        spinner: Spinner.Style = .dots,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let status = Status(message, spinner: spinner)
        let live = Live(console: self)
        
        await live.start()
        await status.start()
        
        // Start animation task
        let animationTask = Task {
            while !Task.isCancelled {
                await status.tick()
                await live.update(await status.renderAsync())
                try? await Task.sleep(for: .milliseconds(80))
            }
        }
        
        defer {
            animationTask.cancel()
            Task { await live.stop() }
        }
        
        do {
            let result = try await operation()
            
            // Show completion
            var completedText = Text()
            completedText.append("✓ ", style: Style(foreground: .green))
            completedText.append(message, style: .none)
            await live.update(completedText)
            
            return result
        } catch {
            // Show error
            var errorText = Text()
            errorText.append("✗ ", style: Style(foreground: .red))
            errorText.append(message, style: .none)
            await live.update(errorText)
            throw error
        }
    }
}
