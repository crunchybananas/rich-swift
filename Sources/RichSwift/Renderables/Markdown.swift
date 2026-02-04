import Foundation

/// Renders Markdown content with styling
public struct Markdown: Renderable, Sendable {
    public let content: String
    public let codeTheme: Syntax.Theme
    public let headingStyle: Style
    public let linkStyle: Style
    public let codeStyle: Style
    public let blockquoteStyle: Style
    public let listMarkerStyle: Style
    
    public init(
        _ content: String,
        codeTheme: Syntax.Theme = .monokai,
        headingStyle: Style = Style(foreground: .cyan, bold: true),
        linkStyle: Style = Style(foreground: .blue, underline: true),
        codeStyle: Style = Style(foreground: .yellow),
        blockquoteStyle: Style = Style(foreground: .brightBlack, italic: true),
        listMarkerStyle: Style = Style(foreground: .magenta)
    ) {
        self.content = content
        self.codeTheme = codeTheme
        self.headingStyle = headingStyle
        self.linkStyle = linkStyle
        self.codeStyle = codeStyle
        self.blockquoteStyle = blockquoteStyle
        self.listMarkerStyle = listMarkerStyle
    }
    
    /// Load markdown from a file
    public static func fromFile(_ path: String) -> Markdown? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }
        return Markdown(content)
    }
    
    public func render(console: Console) -> Text {
        var text = Text()
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var inCodeBlock = false
        var codeBlockLanguage: Syntax.Language = .plaintext
        var codeBlockContent: [String] = []
        
        for (index, line) in lines.enumerated() {
            // Code block handling
            if line.hasPrefix("```") {
                if inCodeBlock {
                    // End of code block - render it
                    let code = codeBlockContent.joined(separator: "\n")
                    let syntax = Syntax(code, language: codeBlockLanguage, theme: codeTheme)
                    text.append(syntax.render(console: console))
                    text.append("\n")
                    codeBlockContent = []
                    inCodeBlock = false
                } else {
                    // Start of code block
                    inCodeBlock = true
                    let langStr = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    codeBlockLanguage = Syntax.Language(rawValue: langStr) ?? .plaintext
                }
                continue
            }
            
            if inCodeBlock {
                codeBlockContent.append(line)
                continue
            }
            
            // Regular markdown parsing
            text.append(parseLine(line, console: console))
            
            if index < lines.count - 1 {
                text.append("\n")
            }
        }
        
        return text
    }
    
    private func parseLine(_ line: String, console: Console) -> Text {
        var text = Text()
        
        // Headings
        if line.hasPrefix("######") {
            let content = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            text.append("      ", style: .none)
            text.append(content, style: headingStyle)
            return text
        }
        if line.hasPrefix("#####") {
            let content = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            text.append("     ", style: .none)
            text.append(content, style: headingStyle)
            return text
        }
        if line.hasPrefix("####") {
            let content = String(line.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            text.append("    ", style: .none)
            text.append(content, style: headingStyle)
            return text
        }
        if line.hasPrefix("###") {
            let content = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            text.append("   ", style: .none)
            text.append(content, style: headingStyle)
            return text
        }
        if line.hasPrefix("##") {
            let content = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            text.append("  ", style: .none)
            text.append(content, style: headingStyle)
            return text
        }
        if line.hasPrefix("#") {
            let content = String(line.dropFirst(1)).trimmingCharacters(in: .whitespaces)
            text.append(content, style: headingStyle.merged(with: Style(underline: true)))
            return text
        }
        
        // Horizontal rules
        if line.trimmingCharacters(in: .whitespaces).allSatisfy({ $0 == "-" || $0 == "*" || $0 == "_" }) &&
           line.trimmingCharacters(in: .whitespaces).count >= 3 {
            text.append(String(repeating: "─", count: min(console.width, 80)), style: Style(foreground: .brightBlack))
            return text
        }
        
        // Blockquotes
        if line.hasPrefix(">") {
            let content = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
            text.append("│ ", style: Style(foreground: .brightBlack))
            text.append(parseInline(content))
            for span in text.spans {
                // Apply blockquote style to all spans
            }
            return text
        }
        
        // Unordered lists
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") ||
           line.trimmingCharacters(in: .whitespaces).hasPrefix("* ") ||
           line.trimmingCharacters(in: .whitespaces).hasPrefix("+ ") {
            let indent = line.prefix(while: { $0 == " " || $0 == "\t" })
            let content = line.trimmingCharacters(in: .whitespaces).dropFirst(2)
            text.append(String(indent), style: .none)
            text.append("• ", style: listMarkerStyle)
            text.append(parseInline(String(content)))
            return text
        }
        
        // Ordered lists
        let orderedListPattern = #"^(\s*)(\d+)\.\s+(.*)$"#
        if let match = line.range(of: orderedListPattern, options: .regularExpression) {
            let parts = line.split(separator: ".", maxSplits: 1)
            if parts.count == 2 {
                let indent = line.prefix(while: { $0 == " " || $0 == "\t" })
                let numPart = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let content = String(parts[1]).trimmingCharacters(in: .whitespaces)
                text.append(String(indent), style: .none)
                text.append("\(numPart). ", style: listMarkerStyle)
                text.append(parseInline(content))
                return text
            }
        }
        
        // Regular paragraph
        text.append(parseInline(line))
        return text
    }
    
    private func parseInline(_ text: String) -> Text {
        var result = Text()
        var remaining = text[...]
        
        while !remaining.isEmpty {
            // Bold + Italic (***text*** or ___text___)
            if remaining.hasPrefix("***") || remaining.hasPrefix("___") {
                let marker = String(remaining.prefix(3))
                remaining = remaining.dropFirst(3)
                if let endIdx = remaining.range(of: marker) {
                    let content = String(remaining[..<endIdx.lowerBound])
                    result.append(content, style: Style(bold: true, italic: true))
                    remaining = remaining[endIdx.upperBound...]
                    continue
                } else {
                    result.append(marker, style: .none)
                    continue
                }
            }
            
            // Bold (**text** or __text__)
            if remaining.hasPrefix("**") || remaining.hasPrefix("__") {
                let marker = String(remaining.prefix(2))
                remaining = remaining.dropFirst(2)
                if let endIdx = remaining.range(of: marker) {
                    let content = String(remaining[..<endIdx.lowerBound])
                    result.append(content, style: Style.bold)
                    remaining = remaining[endIdx.upperBound...]
                    continue
                } else {
                    result.append(marker, style: .none)
                    continue
                }
            }
            
            // Italic (*text* or _text_)
            if remaining.hasPrefix("*") || remaining.hasPrefix("_") {
                let marker = String(remaining.prefix(1))
                let startIdx = remaining.index(after: remaining.startIndex)
                if startIdx < remaining.endIndex {
                    let rest = remaining[startIdx...]
                    if let endIdx = rest.firstIndex(of: Character(marker)) {
                        let content = String(rest[..<endIdx])
                        // Don't match if content is empty or has spaces at boundaries
                        if !content.isEmpty && !content.hasPrefix(" ") && !content.hasSuffix(" ") {
                            result.append(content, style: Style.italic)
                            remaining = rest[rest.index(after: endIdx)...]
                            continue
                        }
                    }
                }
                result.append(marker, style: .none)
                remaining = remaining.dropFirst()
                continue
            }
            
            // Inline code (`code`)
            if remaining.hasPrefix("`") {
                remaining = remaining.dropFirst()
                if let endIdx = remaining.firstIndex(of: "`") {
                    let code = String(remaining[..<endIdx])
                    result.append(code, style: codeStyle)
                    remaining = remaining[remaining.index(after: endIdx)...]
                    continue
                } else {
                    result.append("`", style: .none)
                    continue
                }
            }
            
            // Links [text](url)
            if remaining.hasPrefix("[") {
                remaining = remaining.dropFirst()
                if let closeIdx = remaining.firstIndex(of: "]") {
                    let linkText = String(remaining[..<closeIdx])
                    let afterClose = remaining[remaining.index(after: closeIdx)...]
                    if afterClose.hasPrefix("(") {
                        let urlPart = afterClose.dropFirst()
                        if let urlEnd = urlPart.firstIndex(of: ")") {
                            let _ = String(urlPart[..<urlEnd])
                            result.append(linkText, style: linkStyle)
                            remaining = urlPart[urlPart.index(after: urlEnd)...]
                            continue
                        }
                    }
                    result.append("[", style: .none)
                    result.append(linkText, style: .none)
                    remaining = remaining[closeIdx...]
                    continue
                } else {
                    result.append("[", style: .none)
                    continue
                }
            }
            
            // Strikethrough (~~text~~)
            if remaining.hasPrefix("~~") {
                remaining = remaining.dropFirst(2)
                if let endIdx = remaining.range(of: "~~") {
                    let content = String(remaining[..<endIdx.lowerBound])
                    result.append(content, style: Style(strikethrough: true))
                    remaining = remaining[endIdx.upperBound...]
                    continue
                } else {
                    result.append("~~", style: .none)
                    continue
                }
            }
            
            // Regular character
            result.append(String(remaining.first!), style: .none)
            remaining = remaining.dropFirst()
        }
        
        return result
    }
}

// MARK: - Console Extension

extension Console {
    /// Print markdown content
    public func printMarkdown(_ markdown: String) {
        print(Markdown(markdown))
    }
}
