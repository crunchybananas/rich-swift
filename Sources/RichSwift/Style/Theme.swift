import Foundation

/// Global theme configuration for RichSwift
public final class Theme: @unchecked Sendable {
    
    /// The shared default theme
    public static var shared = Theme()
    
    // MARK: - Semantic Colors
    
    /// Color for success messages
    public var success: Color = .green
    
    /// Color for error messages
    public var error: Color = .red
    
    /// Color for warning messages
    public var warning: Color = .yellow
    
    /// Color for info messages
    public var info: Color = .blue
    
    /// Color for debug/dim text
    public var muted: Color = .brightBlack
    
    /// Color for primary/accent elements
    public var primary: Color = .cyan
    
    /// Color for secondary elements
    public var secondary: Color = .magenta
    
    // MARK: - Component Colors
    
    /// Style for table borders
    public var tableBorder: Style = Style(foreground: .brightBlack)
    
    /// Style for table headers
    public var tableHeader: Style = Style.bold
    
    /// Style for panel borders
    public var panelBorder: Style = Style(foreground: .blue)
    
    /// Style for panel titles
    public var panelTitle: Style = Style(foreground: .cyan, bold: true)
    
    /// Style for tree guides
    public var treeGuide: Style = Style(foreground: .brightBlack)
    
    /// Style for progress bar completed portion
    public var progressComplete: Style = Style(foreground: .green)
    
    /// Style for progress bar remaining portion
    public var progressRemaining: Style = Style(foreground: .brightBlack)
    
    /// Style for rule lines
    public var rule: Style = Style(foreground: .blue)
    
    // MARK: - Syntax Highlighting Theme
    
    /// Default syntax highlighting theme
    public var syntaxTheme: Syntax.Theme = .monokai
    
    // MARK: - Predefined Themes
    
    /// Default theme with balanced colors
    public static let `default` = Theme()
    
    /// Minimal theme with muted colors
    public static var minimal: Theme {
        let theme = Theme()
        theme.tableBorder = Style(foreground: .white, dim: true)
        theme.panelBorder = Style(foreground: .white, dim: true)
        theme.treeGuide = Style(foreground: .white, dim: true)
        theme.rule = Style(foreground: .white, dim: true)
        theme.primary = .white
        theme.secondary = .white
        return theme
    }
    
    /// High contrast theme for accessibility
    public static var highContrast: Theme {
        let theme = Theme()
        theme.success = .brightGreen
        theme.error = .brightRed
        theme.warning = .brightYellow
        theme.info = .brightBlue
        theme.primary = .brightCyan
        theme.secondary = .brightMagenta
        theme.tableBorder = Style(foreground: .white)
        theme.tableHeader = Style(foreground: .white, bold: true, underline: true)
        theme.panelBorder = Style(foreground: .brightWhite)
        return theme
    }
    
    /// Monochrome theme (no colors, just attributes)
    public static var monochrome: Theme {
        let theme = Theme()
        theme.success = .white
        theme.error = .white
        theme.warning = .white
        theme.info = .white
        theme.muted = .white
        theme.primary = .white
        theme.secondary = .white
        theme.tableBorder = Style(foreground: .white)
        theme.tableHeader = Style.bold
        theme.panelBorder = Style(foreground: .white)
        theme.panelTitle = Style.bold
        theme.treeGuide = Style(foreground: .white, dim: true)
        theme.progressComplete = Style.bold
        theme.progressRemaining = Style(dim: true)
        theme.rule = Style(foreground: .white, dim: true)
        theme.syntaxTheme = .ansi
        return theme
    }
    
    /// Dracula-inspired dark theme
    public static var dracula: Theme {
        let theme = Theme()
        theme.success = .rgb(r: 80, g: 250, b: 123)      // Green
        theme.error = .rgb(r: 255, g: 85, b: 85)          // Red
        theme.warning = .rgb(r: 255, g: 184, b: 108)      // Orange
        theme.info = .rgb(r: 139, g: 233, b: 253)         // Cyan
        theme.muted = .rgb(r: 98, g: 114, b: 164)         // Comment
        theme.primary = .rgb(r: 189, g: 147, b: 249)      // Purple
        theme.secondary = .rgb(r: 255, g: 121, b: 198)    // Pink
        theme.tableBorder = Style(foreground: .rgb(r: 68, g: 71, b: 90))
        theme.panelBorder = Style(foreground: .rgb(r: 189, g: 147, b: 249))
        theme.syntaxTheme = .dracula
        return theme
    }
    
    /// GitHub-inspired light theme
    public static var github: Theme {
        let theme = Theme()
        theme.success = .rgb(r: 34, g: 134, b: 58)
        theme.error = .rgb(r: 215, g: 58, b: 73)
        theme.warning = .rgb(r: 227, g: 98, b: 9)
        theme.info = .rgb(r: 3, g: 102, b: 214)
        theme.muted = .rgb(r: 106, g: 115, b: 125)
        theme.primary = .rgb(r: 111, g: 66, b: 193)
        theme.secondary = .rgb(r: 227, g: 98, b: 9)
        theme.syntaxTheme = .github
        return theme
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    /// Create a theme from a dictionary
    public init(from dictionary: [String: String]) {
        if let color = dictionary["success"] { success = Color.hex(color) }
        if let color = dictionary["error"] { error = Color.hex(color) }
        if let color = dictionary["warning"] { warning = Color.hex(color) }
        if let color = dictionary["info"] { info = Color.hex(color) }
        if let color = dictionary["muted"] { muted = Color.hex(color) }
        if let color = dictionary["primary"] { primary = Color.hex(color) }
        if let color = dictionary["secondary"] { secondary = Color.hex(color) }
    }
}

// MARK: - Console Theme Integration

public extension Console {
    /// The theme used by this console
    var theme: Theme {
        Theme.shared
    }
    
    /// Print a success message
    func success(_ message: String) {
        var text = Text()
        text.append("✓ ", style: Style(foreground: theme.success))
        text.append(message, style: .none)
        print(text)
    }
    
    /// Print an error message
    func error(_ message: String) {
        var text = Text()
        text.append("✗ ", style: Style(foreground: theme.error))
        text.append(message, style: .none)
        print(text)
    }
    
    /// Print a warning message
    func warning(_ message: String) {
        var text = Text()
        text.append("⚠ ", style: Style(foreground: theme.warning))
        text.append(message, style: .none)
        print(text)
    }
    
    /// Print an info message
    func info(_ message: String) {
        var text = Text()
        text.append("ℹ ", style: Style(foreground: theme.info))
        text.append(message, style: .none)
        print(text)
    }
}
