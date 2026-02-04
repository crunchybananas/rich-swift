/// Represents styled text - a string with associated styling
public struct Text: Sendable {
    /// A segment of text with its style
    public struct Span: Sendable {
        public let text: String
        public let style: Style
        
        public init(_ text: String, style: Style = .none) {
            self.text = text
            self.style = style
        }
    }
    
    /// The spans that make up this text
    public private(set) var spans: [Span]
    
    /// Create empty text
    public init() {
        self.spans = []
    }
    
    /// Create text with a single unstyled string
    public init(_ text: String) {
        self.spans = [Span(text)]
    }
    
    /// Create text with a single styled string
    public init(_ text: String, style: Style) {
        self.spans = [Span(text, style: style)]
    }
    
    /// Create text from spans
    public init(spans: [Span]) {
        self.spans = spans
    }
    
    /// The plain text content without styling
    public var plain: String {
        spans.map(\.text).joined()
    }
    
    /// The length of the plain text
    public var count: Int {
        spans.reduce(0) { $0 + $1.text.count }
    }
    
    /// Append more text
    public mutating func append(_ text: String, style: Style = .none) {
        spans.append(Span(text, style: style))
    }
    
    /// Append another Text
    public mutating func append(_ other: Text) {
        spans.append(contentsOf: other.spans)
    }
    
    /// Render to a string with ANSI escape codes
    public func render(forTerminal: Bool = true) -> String {
        guard forTerminal else {
            return plain
        }
        
        var result = ""
        for span in spans {
            if span.style != .none {
                result += span.style.openSequence
                result += span.text
                result += Style.resetSequence
            } else {
                result += span.text
            }
        }
        return result
    }
}

// MARK: - Operators

extension Text {
    /// Concatenate two Text objects
    public static func + (lhs: Text, rhs: Text) -> Text {
        var result = lhs
        result.append(rhs)
        return result
    }
    
    /// Concatenate Text with a string
    public static func + (lhs: Text, rhs: String) -> Text {
        var result = lhs
        result.append(rhs)
        return result
    }
}

// MARK: - ExpressibleByStringLiteral

extension Text: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - CustomStringConvertible

extension Text: CustomStringConvertible {
    public var description: String {
        render(forTerminal: true)
    }
}
