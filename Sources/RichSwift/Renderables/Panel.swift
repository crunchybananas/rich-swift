/// A panel for displaying content with a border and optional title
public struct Panel: Renderable, Sendable {
    public let content: String
    public let title: String?
    public let subtitle: String?
    public let boxStyle: Table.BoxStyle
    public let style: Style
    public let borderStyle: Style
    public let padding: (horizontal: Int, vertical: Int)
    public let expand: Bool
    
    public init(
        _ content: String,
        title: String? = nil,
        subtitle: String? = nil,
        boxStyle: Table.BoxStyle = .rounded,
        style: Style = .none,
        borderStyle: Style = Style(foreground: .blue),
        padding: (horizontal: Int, vertical: Int) = (2, 1),
        expand: Bool = false
    ) {
        self.content = content
        self.title = title
        self.subtitle = subtitle
        self.boxStyle = boxStyle
        self.style = style
        self.borderStyle = borderStyle
        self.padding = padding
        self.expand = expand
    }
    
    public func render(console: Console) -> Text {
        let box = boxStyle
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        // Calculate width
        var contentWidth = lines.map(\.count).max() ?? 0
        if let title = title {
            contentWidth = max(contentWidth, title.count + 4)
        }
        if expand {
            contentWidth = max(contentWidth, console.width - 4 - padding.horizontal * 2)
        }
        
        let innerWidth = contentWidth + padding.horizontal * 2
        
        var text = Text()
        
        // Top border with optional title
        text.append(String(box.topLeft), style: borderStyle)
        if let title = title {
            let titleText = " \(title) "
            let remainingWidth = innerWidth - titleText.count
            let leftWidth = remainingWidth / 2
            let rightWidth = remainingWidth - leftWidth
            text.append(String(repeating: box.horizontal, count: leftWidth), style: borderStyle)
            text.append(titleText, style: Style.bold)
            text.append(String(repeating: box.horizontal, count: rightWidth), style: borderStyle)
        } else {
            text.append(String(repeating: box.horizontal, count: innerWidth), style: borderStyle)
        }
        text.append(String(box.topRight), style: borderStyle)
        text.append("\n")
        
        // Top padding
        for _ in 0..<padding.vertical {
            text.append(String(box.vertical), style: borderStyle)
            text.append(String(repeating: " ", count: innerWidth))
            text.append(String(box.vertical), style: borderStyle)
            text.append("\n")
        }
        
        // Content lines
        for line in lines {
            text.append(String(box.vertical), style: borderStyle)
            text.append(String(repeating: " ", count: padding.horizontal))
            
            let paddedLine = line + String(repeating: " ", count: max(0, contentWidth - line.count))
            text.append(paddedLine, style: style)
            
            text.append(String(repeating: " ", count: padding.horizontal))
            text.append(String(box.vertical), style: borderStyle)
            text.append("\n")
        }
        
        // Bottom padding
        for _ in 0..<padding.vertical {
            text.append(String(box.vertical), style: borderStyle)
            text.append(String(repeating: " ", count: innerWidth))
            text.append(String(box.vertical), style: borderStyle)
            text.append("\n")
        }
        
        // Bottom border with optional subtitle
        text.append(String(box.bottomLeft), style: borderStyle)
        if let subtitle = subtitle {
            let subtitleText = " \(subtitle) "
            let remainingWidth = innerWidth - subtitleText.count
            let leftWidth = remainingWidth / 2
            let rightWidth = remainingWidth - leftWidth
            text.append(String(repeating: box.horizontal, count: leftWidth), style: borderStyle)
            text.append(subtitleText, style: Style.dim)
            text.append(String(repeating: box.horizontal, count: rightWidth), style: borderStyle)
        } else {
            text.append(String(repeating: box.horizontal, count: innerWidth), style: borderStyle)
        }
        text.append(String(box.bottomRight), style: borderStyle)
        
        return text
    }
}
