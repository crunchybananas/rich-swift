import Foundation

/// Pretty-print JSON with syntax highlighting
public struct JSON: Renderable, Sendable {
    public let data: Any
    public let indent: Int
    public let theme: Syntax.Theme
    public let sortKeys: Bool
    
    /// Create from Any (dictionary, array, etc.)
    public init(
        _ data: Any,
        indent: Int = 2,
        theme: Syntax.Theme = .monokai,
        sortKeys: Bool = false
    ) {
        self.data = data
        self.indent = indent
        self.theme = theme
        self.sortKeys = sortKeys
    }
    
    /// Create from JSON string
    public static func parse(_ jsonString: String, indent: Int = 2, theme: Syntax.Theme = .monokai) -> JSON? {
        guard let data = jsonString.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        return JSON(parsed, indent: indent, theme: theme)
    }
    
    /// Create from Encodable
    public static func from<T: Encodable>(_ value: T, indent: Int = 2, theme: Syntax.Theme = .monokai) -> JSON? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        guard let data = try? encoder.encode(value),
              let parsed = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }
        return JSON(parsed, indent: indent, theme: theme)
    }
    
    public func render(console: Console) -> Text {
        var text = Text()
        renderValue(data, indent: 0, into: &text)
        return text
    }
    
    private func renderValue(_ value: Any, indent level: Int, into text: inout Text) {
        let indentStr = String(repeating: " ", count: level * indent)
        
        switch value {
        case let dict as [String: Any]:
            renderObject(dict, indent: level, into: &text)
            
        case let array as [Any]:
            renderArray(array, indent: level, into: &text)
            
        case let string as String:
            text.append("\"\(escapeString(string))\"", style: theme.string)
            
        case let number as NSNumber:
            // Check if it's a boolean
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                let boolValue = number.boolValue
                text.append(boolValue ? "true" : "false", style: theme.keyword)
            } else {
                text.append("\(number)", style: theme.number)
            }
            
        case let int as Int:
            text.append("\(int)", style: theme.number)
            
        case let double as Double:
            text.append("\(double)", style: theme.number)
            
        case let bool as Bool:
            text.append(bool ? "true" : "false", style: theme.keyword)
            
        case is NSNull:
            text.append("null", style: theme.keyword)
            
        default:
            text.append("\(value)", style: theme.plain)
        }
    }
    
    private func renderObject(_ dict: [String: Any], indent level: Int, into text: inout Text) {
        let indentStr = String(repeating: " ", count: level * indent)
        let innerIndent = String(repeating: " ", count: (level + 1) * indent)
        
        text.append("{", style: theme.punctuation)
        
        if dict.isEmpty {
            text.append("}", style: theme.punctuation)
            return
        }
        
        text.append("\n")
        
        let keys = sortKeys ? dict.keys.sorted() : Array(dict.keys)
        
        for (index, key) in keys.enumerated() {
            text.append(innerIndent)
            text.append("\"\(key)\"", style: theme.variable)
            text.append(": ", style: theme.punctuation)
            
            if let value = dict[key] {
                renderValue(value, indent: level + 1, into: &text)
            }
            
            if index < keys.count - 1 {
                text.append(",", style: theme.punctuation)
            }
            text.append("\n")
        }
        
        text.append(indentStr)
        text.append("}", style: theme.punctuation)
    }
    
    private func renderArray(_ array: [Any], indent level: Int, into text: inout Text) {
        let indentStr = String(repeating: " ", count: level * indent)
        let innerIndent = String(repeating: " ", count: (level + 1) * indent)
        
        text.append("[", style: theme.punctuation)
        
        if array.isEmpty {
            text.append("]", style: theme.punctuation)
            return
        }
        
        // Check if all elements are simple (numbers, strings, bools)
        let isSimple = array.allSatisfy { element in
            switch element {
            case is String, is Int, is Double, is Bool, is NSNumber, is NSNull:
                return true
            default:
                return false
            }
        }
        
        if isSimple && array.count <= 5 {
            // Inline array
            for (index, element) in array.enumerated() {
                renderValue(element, indent: level, into: &text)
                if index < array.count - 1 {
                    text.append(", ", style: theme.punctuation)
                }
            }
        } else {
            // Multi-line array
            text.append("\n")
            
            for (index, element) in array.enumerated() {
                text.append(innerIndent)
                renderValue(element, indent: level + 1, into: &text)
                
                if index < array.count - 1 {
                    text.append(",", style: theme.punctuation)
                }
                text.append("\n")
            }
            
            text.append(indentStr)
        }
        
        text.append("]", style: theme.punctuation)
    }
    
    private func escapeString(_ string: String) -> String {
        var result = ""
        for char in string {
            switch char {
            case "\"": result += "\\\""
            case "\\": result += "\\\\"
            case "\n": result += "\\n"
            case "\r": result += "\\r"
            case "\t": result += "\\t"
            default: result.append(char)
            }
        }
        return result
    }
}

// MARK: - Console Extension

extension Console {
    /// Print pretty JSON
    public func printJSON(_ data: Any, indent: Int = 2, sortKeys: Bool = false) {
        print(JSON(data, indent: indent, sortKeys: sortKeys))
    }
    
    /// Print and highlight a JSON string
    public func printJSON(_ jsonString: String) {
        if let json = JSON.parse(jsonString) {
            print(json)
        } else {
            print(jsonString)
        }
    }
}
