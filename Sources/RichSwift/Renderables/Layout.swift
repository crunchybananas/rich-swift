/// Adds padding around content
public struct Padding: Renderable {
    public let content: Renderable
    public let top: Int
    public let right: Int
    public let bottom: Int
    public let left: Int
    
    public init(
        _ content: Renderable,
        top: Int = 0,
        right: Int = 0,
        bottom: Int = 0,
        left: Int = 0
    ) {
        self.content = content
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
    }
    
    /// Create padding with same value for all sides
    public init(_ content: Renderable, all: Int) {
        self.content = content
        self.top = all
        self.right = all
        self.bottom = all
        self.left = all
    }
    
    /// Create padding with horizontal and vertical values
    public init(_ content: Renderable, horizontal: Int = 0, vertical: Int = 0) {
        self.content = content
        self.top = vertical
        self.right = horizontal
        self.bottom = vertical
        self.left = horizontal
    }
    
    public func render(console: Console) -> Text {
        let rendered = content.render(console: console)
        let lines = rendered.plain.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        let maxWidth = lines.map(\.count).max() ?? 0
        let totalWidth = maxWidth + left + right
        
        var text = Text()
        
        // Top padding
        for _ in 0..<top {
            text.append(String(repeating: " ", count: totalWidth))
            text.append("\n")
        }
        
        // Content with left/right padding
        let leftPad = String(repeating: " ", count: left)
        let rightPad = String(repeating: " ", count: right)
        
        for (index, line) in lines.enumerated() {
            text.append(leftPad)
            text.append(line)
            text.append(String(repeating: " ", count: max(0, maxWidth - line.count)))
            text.append(rightPad)
            
            if index < lines.count - 1 {
                text.append("\n")
            }
        }
        
        // Bottom padding
        for _ in 0..<bottom {
            text.append("\n")
            text.append(String(repeating: " ", count: totalWidth))
        }
        
        return text
    }
}

// MARK: - Align (text alignment wrapper)

/// Aligns content within a specified width
public struct Align: Renderable {
    public enum Alignment: Sendable {
        case left
        case center
        case right
    }
    
    public let content: Renderable
    public let alignment: Alignment
    public let width: Int?
    
    public init(_ content: Renderable, _ alignment: Alignment, width: Int? = nil) {
        self.content = content
        self.alignment = alignment
        self.width = width
    }
    
    public static func left(_ content: Renderable, width: Int? = nil) -> Align {
        Align(content, .left, width: width)
    }
    
    public static func center(_ content: Renderable, width: Int? = nil) -> Align {
        Align(content, .center, width: width)
    }
    
    public static func right(_ content: Renderable, width: Int? = nil) -> Align {
        Align(content, .right, width: width)
    }
    
    public func render(console: Console) -> Text {
        let rendered = content.render(console: console)
        let lines = rendered.plain.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        let targetWidth = width ?? console.width
        
        var text = Text()
        
        for (index, line) in lines.enumerated() {
            let lineWidth = line.count
            let paddingTotal = max(0, targetWidth - lineWidth)
            
            switch alignment {
            case .left:
                text.append(line)
                text.append(String(repeating: " ", count: paddingTotal))
            case .center:
                let leftPad = paddingTotal / 2
                let rightPad = paddingTotal - leftPad
                text.append(String(repeating: " ", count: leftPad))
                text.append(line)
                text.append(String(repeating: " ", count: rightPad))
            case .right:
                text.append(String(repeating: " ", count: paddingTotal))
                text.append(line)
            }
            
            if index < lines.count - 1 {
                text.append("\n")
            }
        }
        
        return text
    }
}

// MARK: - Group (renders multiple items)

/// Groups multiple renderables together
public struct Group: Renderable {
    public let items: [Renderable]
    public let separator: String
    
    public init(_ items: [Renderable], separator: String = "\n") {
        self.items = items
        self.separator = separator
    }
    
    public init(_ items: Renderable..., separator: String = "\n") {
        self.items = items
        self.separator = separator
    }
    
    public func render(console: Console) -> Text {
        var text = Text()
        
        for (index, item) in items.enumerated() {
            text.append(item.render(console: console))
            
            if index < items.count - 1 {
                text.append(separator)
            }
        }
        
        return text
    }
}
