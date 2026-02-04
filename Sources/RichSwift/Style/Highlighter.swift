import Foundation

/// Protocol for text highlighters
public protocol Highlighter {
    /// Highlight the given text
    func highlight(_ text: String) -> Text
}

/// Highlights representations of Python-like objects (numbers, strings, etc.)
public struct ReprHighlighter: Highlighter {
    public init() {}
    
    public func highlight(_ text: String) -> Text {
        var result = Text()
        var remaining = text[...]
        
        while !remaining.isEmpty {
            // Try to match patterns
            if let match = matchNumber(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .cyan))
                remaining = remaining[match.range.upperBound...]
            } else if let match = matchString(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .green))
                remaining = remaining[match.range.upperBound...]
            } else if let match = matchBoolean(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .magenta, italic: true))
                remaining = remaining[match.range.upperBound...]
            } else if let match = matchNil(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .magenta, italic: true))
                remaining = remaining[match.range.upperBound...]
            } else if let match = matchURL(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .blue, underline: true))
                remaining = remaining[match.range.upperBound...]
            } else if let match = matchUUID(in: remaining) {
                result.append(String(remaining[..<match.range.lowerBound]))
                result.append(match.text, style: Style(foreground: .yellow))
                remaining = remaining[match.range.upperBound...]
            } else {
                // No match, consume one character
                result.append(String(remaining.prefix(1)))
                remaining = remaining.dropFirst()
            }
        }
        
        return result
    }
    
    private struct Match {
        let text: String
        let range: Range<Substring.Index>
    }
    
    private func matchNumber(in text: Substring) -> Match? {
        // Match integers, floats, hex, binary
        let patterns = [
            #"^-?0x[0-9a-fA-F]+"#,      // Hex
            #"^-?0b[01]+"#,              // Binary
            #"^-?0o[0-7]+"#,             // Octal
            #"^-?\d+\.\d+([eE][+-]?\d+)?"#, // Float with optional exponent
            #"^-?\d+[eE][+-]?\d+"#,      // Integer with exponent
            #"^-?\d+"#                    // Integer
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
                let matchRange = Range(match.range, in: text)!
                return Match(text: String(text[matchRange]), range: matchRange)
            }
        }
        return nil
    }
    
    private func matchString(in text: Substring) -> Match? {
        // Match quoted strings
        let patterns = [
            #"^"[^"\\]*(?:\\.[^"\\]*)*""#,   // Double quoted
            #"^'[^'\\]*(?:\\.[^'\\]*)*'"#     // Single quoted
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
                let matchRange = Range(match.range, in: text)!
                return Match(text: String(text[matchRange]), range: matchRange)
            }
        }
        return nil
    }
    
    private func matchBoolean(in text: Substring) -> Match? {
        let pattern = #"^(true|false|True|False|TRUE|FALSE)\b"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
            let matchRange = Range(match.range, in: text)!
            return Match(text: String(text[matchRange]), range: matchRange)
        }
        return nil
    }
    
    private func matchNil(in text: Substring) -> Match? {
        let pattern = #"^(nil|null|None|NULL)\b"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
            let matchRange = Range(match.range, in: text)!
            return Match(text: String(text[matchRange]), range: matchRange)
        }
        return nil
    }
    
    private func matchURL(in text: Substring) -> Match? {
        let pattern = #"^https?://[^\s<>\"']+"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
            let matchRange = Range(match.range, in: text)!
            return Match(text: String(text[matchRange]), range: matchRange)
        }
        return nil
    }
    
    private func matchUUID(in text: Substring) -> Match? {
        let pattern = #"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: String(text), range: NSRange(text.startIndex..., in: text)) {
            let matchRange = Range(match.range, in: text)!
            return Match(text: String(text[matchRange]), range: matchRange)
        }
        return nil
    }
}

/// Highlights ISO timestamps
public struct ISOHighlighter: Highlighter {
    public init() {}
    
    public func highlight(_ text: String) -> Text {
        var result = Text()
        var remaining = text[...]
        
        // ISO 8601 pattern
        let pattern = #"\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?"#
        
        while !remaining.isEmpty {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: String(remaining), range: NSRange(remaining.startIndex..., in: remaining)),
               let matchRange = Range(match.range, in: remaining) {
                
                result.append(String(remaining[..<matchRange.lowerBound]))
                result.append(String(remaining[matchRange]), style: Style(foreground: .magenta))
                remaining = remaining[matchRange.upperBound...]
            } else {
                result.append(String(remaining))
                break
            }
        }
        
        return result
    }
}

/// Highlights regex patterns with custom styles
public struct RegexHighlighter: Highlighter {
    public let rules: [(pattern: String, style: Style)]
    
    public init(rules: [(pattern: String, style: Style)]) {
        self.rules = rules
    }
    
    public func highlight(_ text: String) -> Text {
        var result = Text()
        var remaining = text[...]
        
        while !remaining.isEmpty {
            var matched = false
            
            for (pattern, style) in rules {
                if let regex = try? NSRegularExpression(pattern: "^" + pattern),
                   let match = regex.firstMatch(in: String(remaining), range: NSRange(remaining.startIndex..., in: remaining)),
                   let matchRange = Range(match.range, in: remaining) {
                    
                    if matchRange.lowerBound == remaining.startIndex {
                        result.append(String(remaining[matchRange]), style: style)
                        remaining = remaining[matchRange.upperBound...]
                        matched = true
                        break
                    }
                }
            }
            
            if !matched {
                result.append(String(remaining.prefix(1)))
                remaining = remaining.dropFirst()
            }
        }
        
        return result
    }
}

// MARK: - Console Extension
public extension Console {
    /// Print text with automatic repr highlighting
    func printRepr(_ text: String) {
        let highlighter = ReprHighlighter()
        print(highlighter.highlight(text))
    }
}
