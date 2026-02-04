import Foundation

/// OSC 8 terminal hyperlink support
public struct Hyperlink {
    /// The URL
    public let url: String
    
    /// The display text
    public let text: String
    
    /// Optional ID for the link
    public let id: String?
    
    public init(_ text: String, url: String, id: String? = nil) {
        self.text = text
        self.url = url
        self.id = id
    }
    
    /// Generate the OSC 8 escape sequence
    public func render() -> String {
        let idPart = id.map { "id=\($0)" } ?? ""
        let params = idPart.isEmpty ? "" : "\(idPart):"
        
        // OSC 8 ; params ; URI ST text OSC 8 ; ; ST
        // Where OSC = \e] and ST = \e\\
        let start = "\u{001B}]8;\(params)\(url)\u{001B}\\"
        let end = "\u{001B}]8;;\u{001B}\\"
        
        return "\(start)\(text)\(end)"
    }
}

// MARK: - Text Extension

extension Text {
    /// Append a hyperlink
    public mutating func appendLink(_ text: String, url: String, style: Style = Style(foreground: .blue, underline: true)) {
        let link = Hyperlink(text, url: url)
        // For terminals that support OSC 8
        append(link.render(), style: style)
    }
    
    /// Create text containing a hyperlink
    public static func link(_ text: String, url: String, style: Style = Style(foreground: .blue, underline: true)) -> Text {
        var t = Text()
        t.appendLink(text, url: url, style: style)
        return t
    }
}

// MARK: - Console Extension

extension Console {
    /// Print a hyperlink
    public func printLink(_ text: String, url: String) {
        let link = Hyperlink(text, url: url)
        if terminal.supportsHyperlinks {
            print(link.render())
        } else {
            // Fallback: show text and URL
            print("\(text) (\(url))")
        }
    }
}

// MARK: - Terminal Hyperlink Detection

extension Terminal {
    /// Check if the terminal supports OSC 8 hyperlinks
    public var supportsHyperlinks: Bool {
        // Most modern terminals support OSC 8
        // iTerm2, Windows Terminal, GNOME Terminal, etc.
        if let termProgram = ProcessInfo.processInfo.environment["TERM_PROGRAM"] {
            let supported = ["iTerm.app", "Apple_Terminal", "WezTerm", "Hyper", "vscode"]
            if supported.contains(where: { termProgram.contains($0) }) {
                return true
            }
        }
        
        if let wtSession = ProcessInfo.processInfo.environment["WT_SESSION"] {
            // Windows Terminal
            return !wtSession.isEmpty
        }
        
        if let vteVersion = ProcessInfo.processInfo.environment["VTE_VERSION"],
           let version = Int(vteVersion), version >= 5000 {
            // GNOME Terminal and others using VTE
            return true
        }
        
        // Default: assume modern terminal supports it
        return supportsColor
    }
}
