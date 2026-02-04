import Foundation

/// Pretty-printed exception/error display
public struct PrettyError: Renderable {
    public let error: Error
    public let title: String?
    public let showType: Bool
    public let showSuggestions: Bool
    
    public init(
        _ error: Error,
        title: String? = nil,
        showType: Bool = true,
        showSuggestions: Bool = true
    ) {
        self.error = error
        self.title = title
        self.showType = showType
        self.showSuggestions = showSuggestions
    }
    
    public func render(console: Console) -> Text {
        var text = Text()
        let width = min(console.width, 80)
        
        // Top border
        text.append("╭", style: Style(foreground: .red))
        text.append(String(repeating: "─", count: width - 2), style: Style(foreground: .red))
        text.append("╮\n", style: Style(foreground: .red))
        
        // Title
        let displayTitle = title ?? "Error"
        let titlePadding = (width - displayTitle.count - 4) / 2
        text.append("│", style: Style(foreground: .red))
        text.append(String(repeating: " ", count: titlePadding))
        text.append(" \(displayTitle) ", style: Style(foreground: .white, background: .red, bold: true))
        text.append(String(repeating: " ", count: width - titlePadding - displayTitle.count - 4))
        text.append("│\n", style: Style(foreground: .red))
        
        // Separator
        text.append("├", style: Style(foreground: .red))
        text.append(String(repeating: "─", count: width - 2), style: Style(foreground: .red))
        text.append("┤\n", style: Style(foreground: .red))
        
        // Error type
        if showType {
            let typeName = String(describing: type(of: error))
            text.append("│ ", style: Style(foreground: .red))
            text.append("Type: ", style: Style(foreground: .brightBlack))
            text.append(typeName, style: Style(foreground: .cyan))
            let typeLineLen = 8 + typeName.count
            text.append(String(repeating: " ", count: max(0, width - typeLineLen - 2)))
            text.append("│\n", style: Style(foreground: .red))
        }
        
        // Error message
        let message = error.localizedDescription
        let wrappedLines = wrapText(message, width: width - 4)
        
        for line in wrappedLines {
            text.append("│ ", style: Style(foreground: .red))
            text.append(line, style: .none)
            text.append(String(repeating: " ", count: max(0, width - line.count - 4)))
            text.append(" │\n", style: Style(foreground: .red))
        }
        
        // NSError details
        if let nsError = error as NSError? {
            if nsError.code != 0 {
                text.append("│ ", style: Style(foreground: .red))
                text.append("Code: ", style: Style(foreground: .brightBlack))
                text.append("\(nsError.code)", style: Style(foreground: .yellow))
                let codeLen = 7 + String(nsError.code).count
                text.append(String(repeating: " ", count: max(0, width - codeLen - 2)))
                text.append("│\n", style: Style(foreground: .red))
            }
            
            if !nsError.domain.isEmpty && nsError.domain != "NSCocoaErrorDomain" {
                text.append("│ ", style: Style(foreground: .red))
                text.append("Domain: ", style: Style(foreground: .brightBlack))
                text.append(nsError.domain, style: Style(foreground: .cyan))
                let domainLen = 9 + nsError.domain.count
                text.append(String(repeating: " ", count: max(0, width - domainLen - 2)))
                text.append("│\n", style: Style(foreground: .red))
            }
        }
        
        // Recovery suggestion
        if showSuggestions, let suggestion = (error as NSError).localizedRecoverySuggestion {
            text.append("├", style: Style(foreground: .red))
            text.append(String(repeating: "─", count: width - 2), style: Style(foreground: .red))
            text.append("┤\n", style: Style(foreground: .red))
            
            text.append("│ ", style: Style(foreground: .red))
            text.append("💡 Suggestion:", style: Style(foreground: .yellow, bold: true))
            let suggLen = 15
            text.append(String(repeating: " ", count: max(0, width - suggLen - 2)))
            text.append("│\n", style: Style(foreground: .red))
            
            let suggestionLines = wrapText(suggestion, width: width - 4)
            for line in suggestionLines {
                text.append("│ ", style: Style(foreground: .red))
                text.append(line, style: Style(foreground: .green))
                text.append(String(repeating: " ", count: max(0, width - line.count - 4)))
                text.append(" │\n", style: Style(foreground: .red))
            }
        }
        
        // Bottom border
        text.append("╰", style: Style(foreground: .red))
        text.append(String(repeating: "─", count: width - 2), style: Style(foreground: .red))
        text.append("╯", style: Style(foreground: .red))
        
        return text
    }
    
    private func wrapText(_ text: String, width: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        
        for word in text.split(separator: " ") {
            if currentLine.isEmpty {
                currentLine = String(word)
            } else if currentLine.count + 1 + word.count <= width {
                currentLine += " " + word
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.isEmpty ? [""] : lines
    }
}

// MARK: - Traceback (Python-style stack traces)

/// Display a stack trace in a readable format
public struct Traceback: Renderable {
    public let error: Error
    public let showLocals: Bool
    
    public init(_ error: Error, showLocals: Bool = false) {
        self.error = error
        self.showLocals = showLocals
    }
    
    public func render(console: Console) -> Text {
        var text = Text()
        
        text.append("Traceback (most recent call last):\n", style: Style(foreground: .red))
        
        // Note: Swift doesn't have built-in stack traces for errors like Python
        // We show what information we can extract
        
        let typeName = String(describing: type(of: error))
        let message = error.localizedDescription
        
        text.append("  Error Type: ", style: Style(foreground: .brightBlack))
        text.append(typeName, style: Style(foreground: .cyan, bold: true))
        text.append("\n")
        
        text.append("  Message: ", style: Style(foreground: .brightBlack))
        text.append(message, style: Style(foreground: .white))
        text.append("\n")
        
        // If it's an NSError, show more details
        if let nsError = error as NSError? {
            if !nsError.userInfo.isEmpty {
                text.append("\n  User Info:\n", style: Style(foreground: .brightBlack))
                for (key, value) in nsError.userInfo {
                    text.append("    \(key): ", style: Style(foreground: .cyan))
                    text.append("\(value)\n", style: .none)
                }
            }
        }
        
        return text
    }
}

// MARK: - Console Extension

extension Console {
    /// Print a formatted error
    public func printError(_ error: Error, title: String? = nil) {
        print(PrettyError(error, title: title))
    }
    
    /// Print an exception with traceback style
    public func printException(_ error: Error) {
        print(Traceback(error))
    }
}
