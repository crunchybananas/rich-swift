/// Represents text styling including colors and attributes
public struct Style: Equatable, Sendable {
    public var foreground: Color?
    public var background: Color?
    public var bold: Bool
    public var dim: Bool
    public var italic: Bool
    public var underline: Bool
    public var blink: Bool
    public var reverse: Bool
    public var strikethrough: Bool
    
    public init(
        foreground: Color? = nil,
        background: Color? = nil,
        bold: Bool = false,
        dim: Bool = false,
        italic: Bool = false,
        underline: Bool = false,
        blink: Bool = false,
        reverse: Bool = false,
        strikethrough: Bool = false
    ) {
        self.foreground = foreground
        self.background = background
        self.bold = bold
        self.dim = dim
        self.italic = italic
        self.underline = underline
        self.blink = blink
        self.reverse = reverse
        self.strikethrough = strikethrough
    }
    
    /// A style with no formatting
    public static let none = Style()
    
    /// Generate the ANSI escape sequence for this style
    public var ansiCodes: [String] {
        var codes: [String] = []
        
        if bold { codes.append("1") }
        if dim { codes.append("2") }
        if italic { codes.append("3") }
        if underline { codes.append("4") }
        if blink { codes.append("5") }
        if reverse { codes.append("7") }
        if strikethrough { codes.append("9") }
        
        if let fg = foreground {
            codes.append(fg.foregroundCode)
        }
        
        if let bg = background {
            codes.append(bg.backgroundCode)
        }
        
        return codes
    }
    
    /// The ANSI escape sequence to apply this style
    public var openSequence: String {
        guard !ansiCodes.isEmpty else { return "" }
        return "\u{001B}[\(ansiCodes.joined(separator: ";"))m"
    }
    
    /// The ANSI escape sequence to reset all styles
    public static var resetSequence: String {
        return "\u{001B}[0m"
    }
    
    /// Merge another style into this one (other takes precedence)
    public func merged(with other: Style) -> Style {
        Style(
            foreground: other.foreground ?? self.foreground,
            background: other.background ?? self.background,
            bold: other.bold || self.bold,
            dim: other.dim || self.dim,
            italic: other.italic || self.italic,
            underline: other.underline || self.underline,
            blink: other.blink || self.blink,
            reverse: other.reverse || self.reverse,
            strikethrough: other.strikethrough || self.strikethrough
        )
    }
}

// MARK: - Convenience Initializers

extension Style {
    /// Create a style with just a foreground color
    public static func color(_ color: Color) -> Style {
        Style(foreground: color)
    }
    
    /// Create a bold style
    public static var bold: Style {
        Style(bold: true)
    }
    
    /// Create an italic style
    public static var italic: Style {
        Style(italic: true)
    }
    
    /// Create an underline style
    public static var underline: Style {
        Style(underline: true)
    }
    
    /// Create a dim style
    public static var dim: Style {
        Style(dim: true)
    }
}

// MARK: - Parse from string

extension Style {
    /// Parse a style from a string like "bold red on white"
    public static func parse(_ string: String) -> Style {
        var style = Style()
        let parts = string.lowercased().split(separator: " ")
        
        var expectingBackground = false
        
        for part in parts {
            let partString = String(part)
            
            if partString == "on" {
                expectingBackground = true
                continue
            }
            
            // Check for attributes
            switch partString {
            case "bold", "b":
                style.bold = true
            case "dim", "d":
                style.dim = true
            case "italic", "i":
                style.italic = true
            case "underline", "u":
                style.underline = true
            case "blink":
                style.blink = true
            case "reverse":
                style.reverse = true
            case "strike", "strikethrough", "s":
                style.strikethrough = true
            default:
                // Try to parse as a color
                if let color = Color.named(partString) {
                    if expectingBackground {
                        style.background = color
                        expectingBackground = false
                    } else {
                        style.foreground = color
                    }
                }
            }
        }
        
        return style
    }
}
