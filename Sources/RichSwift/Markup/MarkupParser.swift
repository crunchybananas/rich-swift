/// Parses Rich-style markup like "[bold red]Hello[/]" into styled Text
public struct MarkupParser {
    public init() {}
    
    /// Parse markup string into styled Text
    public func parse(_ markup: String) -> Text {
        var text = Text()
        var styleStack: [Style] = []
        var currentText = ""
        var i = markup.startIndex
        
        while i < markup.endIndex {
            let char = markup[i]
            
            if char == "[" {
                // Check for escape sequence [[
                let nextIndex = markup.index(after: i)
                if nextIndex < markup.endIndex && markup[nextIndex] == "[" {
                    currentText.append("[")
                    i = markup.index(after: nextIndex)
                    continue
                }
                
                // Find closing bracket
                if let closeBracket = markup[i...].firstIndex(of: "]") {
                    // Check if the ] is escaped as ]]
                    let afterClose = markup.index(after: closeBracket)
                    if afterClose < markup.endIndex && markup[afterClose] == "]" {
                        // This is an escaped ], include content up to and including first ]
                        // Actually this means [text]] - not a valid tag, treat [ as literal
                        currentText.append(char)
                        i = markup.index(after: i)
                        continue
                    }
                    
                    // Flush current text with current style
                    if !currentText.isEmpty {
                        let style = styleStack.last ?? .none
                        text.append(currentText, style: style)
                        currentText = ""
                    }
                    
                    let tagStart = markup.index(after: i)
                    let tagContent = String(markup[tagStart..<closeBracket])
                    
                    if tagContent == "/" || tagContent.hasPrefix("/") {
                        // Closing tag - pop style
                        if !styleStack.isEmpty {
                            styleStack.removeLast()
                        }
                    } else {
                        // Opening tag - push new style
                        let newStyle = Style.parse(tagContent)
                        let mergedStyle = (styleStack.last ?? .none).merged(with: newStyle)
                        styleStack.append(mergedStyle)
                    }
                    
                    i = markup.index(after: closeBracket)
                    continue
                }
            } else if char == "]" {
                // Check for escape sequence ]]
                let nextIndex = markup.index(after: i)
                if nextIndex < markup.endIndex && markup[nextIndex] == "]" {
                    currentText.append("]")
                    i = markup.index(after: nextIndex)
                    continue
                }
            }
            
            currentText.append(char)
            i = markup.index(after: i)
        }
        
        // Flush remaining text
        if !currentText.isEmpty {
            let style = styleStack.last ?? .none
            text.append(currentText, style: style)
        }
        
        return text
    }
}

// MARK: - Convenience

extension String {
    /// Parse this string as Rich markup and return styled Text
    public var asMarkup: Text {
        MarkupParser().parse(self)
    }
}
