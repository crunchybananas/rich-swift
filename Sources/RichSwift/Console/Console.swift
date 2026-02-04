import Foundation

/// The main interface for rich terminal output
public final class Console: @unchecked Sendable {
    /// The terminal instance
    public let terminal: Terminal
    
    /// Whether to force color output even if terminal doesn't support it
    public var forceColor: Bool
    
    /// Whether to use markup parsing
    public var markup: Bool
    
    /// The output stream (defaults to stdout)
    private let output: FileHandle
    
    /// Markup parser for processing rich text
    private let parser = MarkupParser()
    
    /// Create a new Console instance
    public init(
        forceColor: Bool = false,
        markup: Bool = true,
        output: FileHandle = .standardOutput
    ) {
        self.terminal = Terminal.shared
        self.forceColor = forceColor
        self.markup = markup
        self.output = output
    }
    
    /// Whether to render with colors
    public var useColor: Bool {
        forceColor || terminal.supportsColor
    }
    
    /// The width of the console
    public var width: Int {
        terminal.width
    }
    
    /// The height of the console
    public var height: Int {
        terminal.height
    }
    
    // MARK: - Output Methods
    
    /// Print a message with optional style
    public func print(
        _ message: String = "",
        style: Style = .none,
        end: String = "\n"
    ) {
        var text: Text
        
        if markup {
            text = parser.parse(message)
        } else {
            text = Text(message, style: style)
        }
        
        let rendered = text.render(forTerminal: useColor)
        write(rendered + end)
    }
    
    /// Print styled Text directly
    public func print(_ text: Text, end: String = "\n") {
        let rendered = text.render(forTerminal: useColor)
        write(rendered + end)
    }
    
    /// Print a renderable object (like Table)
    public func print(_ renderable: Renderable, end: String = "\n") {
        let text = renderable.render(console: self)
        let rendered = text.render(forTerminal: useColor)
        write(rendered + end)
    }
    
    /// Print a rule/horizontal line
    public func rule(
        _ title: String? = nil,
        style: Style = Style(foreground: .brightBlack),
        character: Character = "─"
    ) {
        let ruleWidth = width
        
        if let title = title {
            let titleText = " \(title) "
            let sideWidth = (ruleWidth - titleText.count) / 2
            let leftSide = String(repeating: character, count: max(0, sideWidth))
            let rightSide = String(repeating: character, count: max(0, ruleWidth - sideWidth - titleText.count))
            
            var text = Text(leftSide, style: style)
            text.append(titleText, style: Style.bold)
            text.append(rightSide, style: style)
            
            write(text.render(forTerminal: useColor) + "\n")
        } else {
            let line = String(repeating: character, count: ruleWidth)
            let text = Text(line, style: style)
            write(text.render(forTerminal: useColor) + "\n")
        }
    }
    
    /// Print a blank line
    public func line() {
        write("\n")
    }
    
    /// Clear the console
    public func clear() {
        if terminal.isTerminal {
            write("\u{001B}[2J\u{001B}[H")
        }
    }
    
    // MARK: - Private Methods
    
    private func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            output.write(data)
        }
    }
}

// MARK: - Static Convenience

extension Console {
    /// A shared console instance for convenience
    public static let shared = Console()
}
