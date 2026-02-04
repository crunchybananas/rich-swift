import Foundation

/// Syntax highlighting for code blocks
public struct Syntax: Renderable, Sendable {
    public let code: String
    public let language: Language
    public let theme: Theme
    public let lineNumbers: Bool
    public let startLine: Int
    public let highlightLines: Set<Int>
    public let wordWrap: Bool
    
    /// Supported languages
    public enum Language: String, Sendable, CaseIterable {
        case swift
        case python
        case javascript
        case typescript
        case json
        case yaml
        case xml
        case html
        case css
        case sql
        case bash
        case shell
        case markdown
        case rust
        case go
        case java
        case kotlin
        case ruby
        case plaintext
        
        /// Detect language from file extension
        public static func fromExtension(_ ext: String) -> Language {
            switch ext.lowercased() {
            case "swift": return .swift
            case "py": return .python
            case "js": return .javascript
            case "ts": return .typescript
            case "json": return .json
            case "yml", "yaml": return .yaml
            case "xml": return .xml
            case "html", "htm": return .html
            case "css": return .css
            case "sql": return .sql
            case "sh", "bash", "zsh": return .bash
            case "md", "markdown": return .markdown
            case "rs": return .rust
            case "go": return .go
            case "java": return .java
            case "kt": return .kotlin
            case "rb": return .ruby
            default: return .plaintext
            }
        }
    }
    
    /// Color themes for syntax highlighting
    public struct Theme: Sendable {
        public let keyword: Style
        public let string: Style
        public let number: Style
        public let comment: Style
        public let function: Style
        public let type: Style
        public let variable: Style
        public let operator_: Style
        public let punctuation: Style
        public let plain: Style
        public let lineNumber: Style
        public let highlightedLine: Style
        
        /// Monokai-inspired theme
        public static let monokai = Theme(
            keyword: Style(foreground: .rgb(r: 249, g: 38, b: 114)),
            string: Style(foreground: .rgb(r: 230, g: 219, b: 116)),
            number: Style(foreground: .rgb(r: 174, g: 129, b: 255)),
            comment: Style(foreground: .rgb(r: 117, g: 113, b: 94), italic: true),
            function: Style(foreground: .rgb(r: 166, g: 226, b: 46)),
            type: Style(foreground: .rgb(r: 102, g: 217, b: 239)),
            variable: Style(foreground: .white),
            operator_: Style(foreground: .rgb(r: 249, g: 38, b: 114)),
            punctuation: Style(foreground: .white),
            plain: Style(foreground: .white),
            lineNumber: Style(foreground: .brightBlack),
            highlightedLine: Style(background: .rgb(r: 60, g: 60, b: 60))
        )
        
        /// GitHub-style light theme (for terminals with light backgrounds)
        public static let github = Theme(
            keyword: Style(foreground: .rgb(r: 207, g: 34, b: 46)),
            string: Style(foreground: .rgb(r: 10, g: 48, b: 105)),
            number: Style(foreground: .rgb(r: 5, g: 80, b: 174)),
            comment: Style(foreground: .rgb(r: 106, g: 115, b: 125), italic: true),
            function: Style(foreground: .rgb(r: 111, g: 66, b: 193)),
            type: Style(foreground: .rgb(r: 227, g: 98, b: 9)),
            variable: Style(foreground: .rgb(r: 36, g: 41, b: 46)),
            operator_: Style(foreground: .rgb(r: 207, g: 34, b: 46)),
            punctuation: Style(foreground: .rgb(r: 36, g: 41, b: 46)),
            plain: Style(foreground: .rgb(r: 36, g: 41, b: 46)),
            lineNumber: Style(foreground: .rgb(r: 106, g: 115, b: 125)),
            highlightedLine: Style(background: .rgb(r: 255, g: 251, b: 221))
        )
        
        /// Dracula theme
        public static let dracula = Theme(
            keyword: Style(foreground: .rgb(r: 255, g: 121, b: 198)),
            string: Style(foreground: .rgb(r: 241, g: 250, b: 140)),
            number: Style(foreground: .rgb(r: 189, g: 147, b: 249)),
            comment: Style(foreground: .rgb(r: 98, g: 114, b: 164), italic: true),
            function: Style(foreground: .rgb(r: 80, g: 250, b: 123)),
            type: Style(foreground: .rgb(r: 139, g: 233, b: 253)),
            variable: Style(foreground: .rgb(r: 248, g: 248, b: 242)),
            operator_: Style(foreground: .rgb(r: 255, g: 121, b: 198)),
            punctuation: Style(foreground: .rgb(r: 248, g: 248, b: 242)),
            plain: Style(foreground: .rgb(r: 248, g: 248, b: 242)),
            lineNumber: Style(foreground: .rgb(r: 98, g: 114, b: 164)),
            highlightedLine: Style(background: .rgb(r: 68, g: 71, b: 90))
        )
        
        /// Simple ANSI theme (works on all terminals)
        public static let ansi = Theme(
            keyword: Style(foreground: .magenta, bold: true),
            string: Style(foreground: .green),
            number: Style(foreground: .cyan),
            comment: Style(foreground: .brightBlack, italic: true),
            function: Style(foreground: .yellow),
            type: Style(foreground: .cyan, bold: true),
            variable: Style(foreground: .white),
            operator_: Style(foreground: .red),
            punctuation: Style(foreground: .white),
            plain: Style.none,
            lineNumber: Style(foreground: .brightBlack),
            highlightedLine: Style(background: .brightBlack)
        )
    }
    
    public init(
        _ code: String,
        language: Language = .plaintext,
        theme: Theme = .monokai,
        lineNumbers: Bool = false,
        startLine: Int = 1,
        highlightLines: Set<Int> = [],
        wordWrap: Bool = false
    ) {
        self.code = code
        self.language = language
        self.theme = theme
        self.lineNumbers = lineNumbers
        self.startLine = startLine
        self.highlightLines = highlightLines
        self.wordWrap = wordWrap
    }
    
    /// Load syntax from a file
    public static func fromFile(_ path: String, theme: Theme = .monokai, lineNumbers: Bool = true) -> Syntax? {
        guard let code = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }
        let ext = (path as NSString).pathExtension
        let language = Language.fromExtension(ext)
        return Syntax(code, language: language, theme: theme, lineNumbers: lineNumbers)
    }
    
    public func render(console: Console) -> Text {
        let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let maxLineNum = startLine + lines.count - 1
        let lineNumWidth = String(maxLineNum).count
        
        var text = Text()
        
        for (index, line) in lines.enumerated() {
            let lineNum = startLine + index
            let isHighlighted = highlightLines.contains(lineNum)
            
            // Line number
            if lineNumbers {
                let numStr = String(lineNum).padding(toLength: lineNumWidth, withPad: " ", startingAt: 0)
                text.append(numStr, style: theme.lineNumber)
                text.append(" │ ", style: theme.lineNumber)
            }
            
            // Highlighted line background
            if isHighlighted {
                // Note: For full line highlight we'd need more complex handling
                // For now we just highlight the content
            }
            
            // Syntax-highlighted content
            let highlighted = highlightLine(line, language: language)
            text.append(highlighted)
            
            if index < lines.count - 1 {
                text.append("\n")
            }
        }
        
        return text
    }
    
    private func highlightLine(_ line: String, language: Language) -> Text {
        // Language-specific highlighting
        switch language {
        case .swift:
            return highlightSwift(line)
        case .python:
            return highlightPython(line)
        case .javascript, .typescript:
            return highlightJavaScript(line)
        case .json:
            return highlightJSON(line)
        case .yaml:
            return highlightYAML(line)
        case .bash, .shell:
            return highlightBash(line)
        case .sql:
            return highlightSQL(line)
        case .html, .xml:
            return highlightXML(line)
        case .css:
            return highlightCSS(line)
        default:
            return Text(line, style: theme.plain)
        }
    }
    
    // MARK: - Language-specific highlighters
    
    private func highlightSwift(_ line: String) -> Text {
        let keywords = ["import", "func", "var", "let", "class", "struct", "enum", "protocol",
                       "extension", "if", "else", "guard", "switch", "case", "default", "for",
                       "while", "repeat", "return", "throw", "throws", "try", "catch", "defer",
                       "public", "private", "internal", "fileprivate", "open", "static", "final",
                       "override", "mutating", "init", "deinit", "self", "super", "nil", "true",
                       "false", "async", "await", "actor", "nonisolated", "isolated", "@main",
                       "where", "typealias", "associatedtype", "some", "any", "in", "as", "is"]
        
        let types = ["String", "Int", "Double", "Float", "Bool", "Array", "Dictionary", "Set",
                    "Optional", "Result", "Error", "Void", "Any", "AnyObject", "Self", "Type"]
        
        return highlightGeneric(line, keywords: keywords, types: types)
    }
    
    private func highlightPython(_ line: String) -> Text {
        let keywords = ["import", "from", "def", "class", "if", "elif", "else", "for", "while",
                       "try", "except", "finally", "with", "as", "return", "yield", "raise",
                       "pass", "break", "continue", "and", "or", "not", "in", "is", "lambda",
                       "global", "nonlocal", "assert", "async", "await", "True", "False", "None"]
        
        let types = ["str", "int", "float", "bool", "list", "dict", "set", "tuple", "type"]
        
        return highlightGeneric(line, keywords: keywords, types: types, commentPrefix: "#")
    }
    
    private func highlightJavaScript(_ line: String) -> Text {
        let keywords = ["import", "export", "from", "function", "const", "let", "var", "class",
                       "extends", "if", "else", "switch", "case", "default", "for", "while",
                       "do", "return", "throw", "try", "catch", "finally", "new", "this",
                       "super", "typeof", "instanceof", "async", "await", "yield", "true",
                       "false", "null", "undefined", "of", "in"]
        
        let types = ["String", "Number", "Boolean", "Array", "Object", "Function", "Promise",
                    "Map", "Set", "Symbol", "BigInt"]
        
        return highlightGeneric(line, keywords: keywords, types: types)
    }
    
    private func highlightJSON(_ line: String) -> Text {
        var text = Text()
        var remaining = line[...]
        
        while !remaining.isEmpty {
            if remaining.first == "\"" {
                // Find the string
                if let endQuote = remaining.dropFirst().firstIndex(of: "\"") {
                    let string = String(remaining[remaining.startIndex...endQuote])
                    // Check if it's a key (followed by :)
                    let afterString = remaining[remaining.index(after: endQuote)...]
                    let isKey = afterString.trimmingCharacters(in: .whitespaces).hasPrefix(":")
                    text.append(string, style: isKey ? theme.variable : theme.string)
                    remaining = remaining[remaining.index(after: endQuote)...]
                } else {
                    text.append(String(remaining), style: theme.string)
                    break
                }
            } else if remaining.first?.isNumber == true || remaining.hasPrefix("-") {
                var numStr = ""
                var idx = remaining.startIndex
                if remaining.hasPrefix("-") {
                    numStr.append("-")
                    idx = remaining.index(after: idx)
                }
                while idx < remaining.endIndex && (remaining[idx].isNumber || remaining[idx] == ".") {
                    numStr.append(remaining[idx])
                    idx = remaining.index(after: idx)
                }
                text.append(numStr, style: theme.number)
                remaining = remaining[idx...]
            } else if remaining.hasPrefix("true") || remaining.hasPrefix("false") || remaining.hasPrefix("null") {
                let word = remaining.hasPrefix("true") ? "true" : (remaining.hasPrefix("false") ? "false" : "null")
                text.append(word, style: theme.keyword)
                remaining = remaining.dropFirst(word.count)
            } else {
                text.append(String(remaining.first!), style: theme.punctuation)
                remaining = remaining.dropFirst()
            }
        }
        
        return text
    }
    
    private func highlightYAML(_ line: String) -> Text {
        var text = Text()
        
        // Check for comment
        if let commentIdx = line.firstIndex(of: "#") {
            let beforeComment = String(line[..<commentIdx])
            let comment = String(line[commentIdx...])
            text.append(highlightYAMLContent(beforeComment))
            text.append(comment, style: theme.comment)
        } else {
            text.append(highlightYAMLContent(line))
        }
        
        return text
    }
    
    private func highlightYAMLContent(_ line: String) -> Text {
        var text = Text()
        
        // Check for key: value
        if let colonIdx = line.firstIndex(of: ":") {
            let key = String(line[..<colonIdx])
            let rest = String(line[colonIdx...])
            
            // Highlight indentation
            let trimmed = key.trimmingCharacters(in: .whitespaces)
            let indent = String(key.prefix(key.count - trimmed.count))
            
            text.append(indent, style: theme.plain)
            text.append(trimmed, style: theme.variable)
            text.append(":", style: theme.punctuation)
            
            let value = String(rest.dropFirst()).trimmingCharacters(in: .whitespaces)
            if !value.isEmpty {
                text.append(" ", style: theme.plain)
                if value.hasPrefix("\"") || value.hasPrefix("'") {
                    text.append(value, style: theme.string)
                } else if value == "true" || value == "false" || value == "null" || value == "~" {
                    text.append(value, style: theme.keyword)
                } else if Double(value) != nil {
                    text.append(value, style: theme.number)
                } else {
                    text.append(value, style: theme.string)
                }
            }
        } else {
            text.append(line, style: theme.plain)
        }
        
        return text
    }
    
    private func highlightBash(_ line: String) -> Text {
        let keywords = ["if", "then", "else", "elif", "fi", "for", "while", "do", "done",
                       "case", "esac", "function", "return", "exit", "export", "local",
                       "readonly", "declare", "typeset", "source", "alias", "unalias"]
        
        let builtins = ["echo", "printf", "read", "cd", "pwd", "ls", "cat", "grep", "sed",
                       "awk", "find", "xargs", "sort", "uniq", "wc", "head", "tail", "test"]
        
        var text = Text()
        
        // Check for comment
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            return Text(line, style: theme.comment)
        }
        
        // Simple tokenization
        let tokens = tokenize(line)
        for token in tokens {
            if keywords.contains(token) {
                text.append(token, style: theme.keyword)
            } else if builtins.contains(token) {
                text.append(token, style: theme.function)
            } else if token.hasPrefix("$") {
                text.append(token, style: theme.variable)
            } else if token.hasPrefix("\"") || token.hasPrefix("'") {
                text.append(token, style: theme.string)
            } else if token.hasPrefix("-") {
                text.append(token, style: theme.number)
            } else {
                text.append(token, style: theme.plain)
            }
        }
        
        return text
    }
    
    private func highlightSQL(_ line: String) -> Text {
        let keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "NOT", "IN", "LIKE", "BETWEEN",
                       "JOIN", "INNER", "LEFT", "RIGHT", "OUTER", "ON", "AS", "ORDER", "BY",
                       "GROUP", "HAVING", "LIMIT", "OFFSET", "INSERT", "INTO", "VALUES",
                       "UPDATE", "SET", "DELETE", "CREATE", "TABLE", "INDEX", "VIEW", "DROP",
                       "ALTER", "ADD", "COLUMN", "PRIMARY", "KEY", "FOREIGN", "REFERENCES",
                       "NULL", "NOT", "DEFAULT", "UNIQUE", "CHECK", "CONSTRAINT", "CASCADE",
                       "UNION", "ALL", "DISTINCT", "COUNT", "SUM", "AVG", "MIN", "MAX",
                       "CASE", "WHEN", "THEN", "ELSE", "END", "TRUE", "FALSE", "IS"]
        
        var text = Text()
        let tokens = tokenize(line)
        
        for token in tokens {
            if keywords.contains(token.uppercased()) {
                text.append(token, style: theme.keyword)
            } else if token.hasPrefix("'") || token.hasPrefix("\"") {
                text.append(token, style: theme.string)
            } else if Double(token) != nil {
                text.append(token, style: theme.number)
            } else if token.hasPrefix("--") {
                text.append(token, style: theme.comment)
            } else {
                text.append(token, style: theme.plain)
            }
        }
        
        return text
    }
    
    private func highlightXML(_ line: String) -> Text {
        var text = Text()
        var remaining = line[...]
        
        while !remaining.isEmpty {
            if remaining.hasPrefix("<!--") {
                // Comment
                if let endComment = remaining.range(of: "-->") {
                    let comment = String(remaining[..<endComment.upperBound])
                    text.append(comment, style: theme.comment)
                    remaining = remaining[endComment.upperBound...]
                } else {
                    text.append(String(remaining), style: theme.comment)
                    break
                }
            } else if remaining.hasPrefix("<") {
                // Tag
                if let endTag = remaining.firstIndex(of: ">") {
                    let tag = String(remaining[...endTag])
                    text.append(highlightXMLTag(tag))
                    remaining = remaining[remaining.index(after: endTag)...]
                } else {
                    text.append(String(remaining), style: theme.plain)
                    break
                }
            } else {
                // Content
                if let nextTag = remaining.firstIndex(of: "<") {
                    let content = String(remaining[..<nextTag])
                    text.append(content, style: theme.plain)
                    remaining = remaining[nextTag...]
                } else {
                    text.append(String(remaining), style: theme.plain)
                    break
                }
            }
        }
        
        return text
    }
    
    private func highlightXMLTag(_ tag: String) -> Text {
        var text = Text()
        text.append("<", style: theme.punctuation)
        
        let inner = String(tag.dropFirst().dropLast())
        let parts = inner.split(separator: " ", maxSplits: 1)
        
        if let tagName = parts.first {
            let name = String(tagName).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if inner.hasPrefix("/") {
                text.append("/", style: theme.punctuation)
            }
            text.append(name, style: theme.keyword)
            
            if parts.count > 1 {
                text.append(" ", style: theme.plain)
                // Attributes
                let attrs = String(parts[1])
                text.append(highlightXMLAttributes(attrs))
            }
            
            if inner.hasSuffix("/") && !inner.hasPrefix("/") {
                text.append("/", style: theme.punctuation)
            }
        }
        
        text.append(">", style: theme.punctuation)
        return text
    }
    
    private func highlightXMLAttributes(_ attrs: String) -> Text {
        var text = Text()
        var remaining = attrs[...]
        
        while !remaining.isEmpty {
            // Find attribute name
            if let eqIdx = remaining.firstIndex(of: "=") {
                let name = String(remaining[..<eqIdx]).trimmingCharacters(in: .whitespaces)
                text.append(name, style: theme.type)
                text.append("=", style: theme.punctuation)
                remaining = remaining[remaining.index(after: eqIdx)...]
                
                // Find value
                let trimmed = remaining.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("\"") {
                    if let endQuote = trimmed.dropFirst().firstIndex(of: "\"") {
                        let value = String(trimmed[...endQuote])
                        text.append(value, style: theme.string)
                        let afterQuote = trimmed.index(after: endQuote)
                        remaining = trimmed[afterQuote...]
                    }
                }
            } else {
                text.append(String(remaining), style: theme.plain)
                break
            }
        }
        
        return text
    }
    
    private func highlightCSS(_ line: String) -> Text {
        var text = Text()
        
        // Check for comment
        if line.contains("/*") || line.contains("*/") {
            text.append(line, style: theme.comment)
            return text
        }
        
        // Check for selector vs property
        if line.contains("{") || line.contains("}") {
            // Selector line
            let parts = line.components(separatedBy: "{")
            if parts.count > 1 {
                text.append(parts[0], style: theme.keyword)
                text.append("{", style: theme.punctuation)
                text.append(parts[1...].joined(separator: "{"), style: theme.plain)
            } else if line.contains("}") {
                text.append(line, style: theme.punctuation)
            } else {
                text.append(line, style: theme.keyword)
            }
        } else if line.contains(":") {
            // Property line
            let parts = line.components(separatedBy: ":")
            if parts.count >= 2 {
                text.append(parts[0], style: theme.type)
                text.append(":", style: theme.punctuation)
                let value = parts[1...].joined(separator: ":")
                text.append(value, style: theme.string)
            } else {
                text.append(line, style: theme.plain)
            }
        } else {
            text.append(line, style: theme.plain)
        }
        
        return text
    }
    
    // MARK: - Helpers
    
    private func highlightGeneric(_ line: String, keywords: [String], types: [String], commentPrefix: String = "//") -> Text {
        var text = Text()
        
        // Check for line comment
        if let commentIdx = line.range(of: commentPrefix) {
            let beforeComment = String(line[..<commentIdx.lowerBound])
            let comment = String(line[commentIdx.lowerBound...])
            text.append(highlightCode(beforeComment, keywords: keywords, types: types))
            text.append(comment, style: theme.comment)
            return text
        }
        
        return highlightCode(line, keywords: keywords, types: types)
    }
    
    private func highlightCode(_ line: String, keywords: [String], types: [String]) -> Text {
        var text = Text()
        let tokens = tokenize(line)
        
        for token in tokens {
            if keywords.contains(token) {
                text.append(token, style: theme.keyword)
            } else if types.contains(token) {
                text.append(token, style: theme.type)
            } else if token.hasPrefix("\"") || token.hasPrefix("'") || token.hasPrefix("`") {
                text.append(token, style: theme.string)
            } else if token.first?.isNumber == true {
                text.append(token, style: theme.number)
            } else if token.first?.isLetter == true && token.first?.isUppercase == true {
                // Likely a type
                text.append(token, style: theme.type)
            } else if ["(", ")", "[", "]", "{", "}", ",", ".", ";", ":"].contains(token) {
                text.append(token, style: theme.punctuation)
            } else if ["+", "-", "*", "/", "=", "<", ">", "!", "&", "|", "?", "%"].contains(where: { token.contains($0) }) {
                text.append(token, style: theme.operator_)
            } else {
                text.append(token, style: theme.plain)
            }
        }
        
        return text
    }
    
    private func tokenize(_ line: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inString: Character? = nil
        var escaped = false
        
        for char in line {
            if escaped {
                current.append(char)
                escaped = false
                continue
            }
            
            if char == "\\" && inString != nil {
                current.append(char)
                escaped = true
                continue
            }
            
            if inString != nil {
                current.append(char)
                if char == inString {
                    tokens.append(current)
                    current = ""
                    inString = nil
                }
                continue
            }
            
            if char == "\"" || char == "'" || char == "`" {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                current.append(char)
                inString = char
                continue
            }
            
            if char.isWhitespace {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                tokens.append(String(char))
                continue
            }
            
            if "()[]{},.;:".contains(char) {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                tokens.append(String(char))
                continue
            }
            
            current.append(char)
        }
        
        if !current.isEmpty {
            tokens.append(current)
        }
        
        return tokens
    }
}

// MARK: - Console Extension

extension Console {
    /// Print syntax-highlighted code
    public func print(
        _ code: String,
        language: Syntax.Language,
        theme: Syntax.Theme = .monokai,
        lineNumbers: Bool = false
    ) {
        let syntax = Syntax(code, language: language, theme: theme, lineNumbers: lineNumbers)
        print(syntax)
    }
}
