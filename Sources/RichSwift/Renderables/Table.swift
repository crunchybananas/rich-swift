/// A table for displaying data in rows and columns
public final class Table: Renderable, @unchecked Sendable {
    
    /// Box drawing characters for different table styles
    public struct BoxStyle: Sendable {
        let topLeft: Character
        let topRight: Character
        let bottomLeft: Character
        let bottomRight: Character
        let horizontal: Character
        let vertical: Character
        let leftT: Character
        let rightT: Character
        let topT: Character
        let bottomT: Character
        let cross: Character
        
        /// Simple ASCII box style
        public static let ascii = BoxStyle(
            topLeft: "+", topRight: "+", bottomLeft: "+", bottomRight: "+",
            horizontal: "-", vertical: "|",
            leftT: "+", rightT: "+", topT: "+", bottomT: "+", cross: "+"
        )
        
        /// Unicode rounded corners
        public static let rounded = BoxStyle(
            topLeft: "╭", topRight: "╮", bottomLeft: "╰", bottomRight: "╯",
            horizontal: "─", vertical: "│",
            leftT: "├", rightT: "┤", topT: "┬", bottomT: "┴", cross: "┼"
        )
        
        /// Unicode square corners
        public static let square = BoxStyle(
            topLeft: "┌", topRight: "┐", bottomLeft: "└", bottomRight: "┘",
            horizontal: "─", vertical: "│",
            leftT: "├", rightT: "┤", topT: "┬", bottomT: "┴", cross: "┼"
        )
        
        /// Heavy Unicode box
        public static let heavy = BoxStyle(
            topLeft: "┏", topRight: "┓", bottomLeft: "┗", bottomRight: "┛",
            horizontal: "━", vertical: "┃",
            leftT: "┣", rightT: "┫", topT: "┳", bottomT: "┻", cross: "╋"
        )
        
        /// Double line box
        public static let double = BoxStyle(
            topLeft: "╔", topRight: "╗", bottomLeft: "╚", bottomRight: "╝",
            horizontal: "═", vertical: "║",
            leftT: "╠", rightT: "╣", topT: "╦", bottomT: "╩", cross: "╬"
        )
        
        /// Minimal - no borders
        public static let minimal = BoxStyle(
            topLeft: " ", topRight: " ", bottomLeft: " ", bottomRight: " ",
            horizontal: " ", vertical: " ",
            leftT: " ", rightT: " ", topT: " ", bottomT: " ", cross: " "
        )
    }
    
    /// Column definition
    public struct Column: Sendable {
        public var header: String
        public var style: Style
        public var headerStyle: Style
        public var justify: Justify
        public var width: Int?
        public var minWidth: Int?
        public var maxWidth: Int?
        
        public enum Justify: Sendable {
            case left
            case center
            case right
        }
        
        public init(
            header: String,
            style: Style = .none,
            headerStyle: Style = Style.bold,
            justify: Justify = .left,
            width: Int? = nil,
            minWidth: Int? = nil,
            maxWidth: Int? = nil
        ) {
            self.header = header
            self.style = style
            self.headerStyle = headerStyle
            self.justify = justify
            self.width = width
            self.minWidth = minWidth
            self.maxWidth = maxWidth
        }
    }
    
    /// Row data
    public typealias Row = [String]
    
    // MARK: - Properties
    
    public var title: String?
    public var titleStyle: Style
    public var columns: [Column]
    public var rows: [Row]
    public var boxStyle: BoxStyle
    public var borderStyle: Style
    public var showHeader: Bool
    public var padding: Int
    
    // MARK: - Initialization
    
    public init(
        title: String? = nil,
        titleStyle: Style = Style(foreground: .cyan, bold: true),
        boxStyle: BoxStyle = .rounded,
        borderStyle: Style = Style(foreground: .brightBlack),
        showHeader: Bool = true,
        padding: Int = 1
    ) {
        self.title = title
        self.titleStyle = titleStyle
        self.columns = []
        self.rows = []
        self.boxStyle = boxStyle
        self.borderStyle = borderStyle
        self.showHeader = showHeader
        self.padding = padding
    }
    
    // MARK: - Building
    
    /// Add a column to the table
    @discardableResult
    public func addColumn(
        _ header: String,
        style: Style = .none,
        headerStyle: Style = Style.bold,
        justify: Column.Justify = .left,
        width: Int? = nil
    ) -> Self {
        columns.append(Column(
            header: header,
            style: style,
            headerStyle: headerStyle,
            justify: justify,
            width: width
        ))
        return self
    }
    
    /// Add a row to the table
    @discardableResult
    public func addRow(_ values: String...) -> Self {
        rows.append(values)
        return self
    }
    
    /// Add a row from an array
    @discardableResult
    public func addRow(_ values: [String]) -> Self {
        rows.append(values)
        return self
    }
    
    // MARK: - Rendering
    
    public func render(console: Console) -> Text {
        guard !columns.isEmpty else {
            return Text()
        }
        
        // Calculate column widths
        let widths = calculateColumnWidths(maxWidth: console.width)
        
        var text = Text()
        let box = boxStyle
        let pad = String(repeating: " ", count: padding)
        
        // Title
        if let title = title {
            let totalWidth = widths.reduce(0, +) + (columns.count + 1) + (padding * 2 * columns.count)
            let centered = centerString(title, width: totalWidth)
            text.append(centered, style: titleStyle)
            text.append("\n")
        }
        
        // Top border
        text.append(renderHorizontalBorder(widths: widths, position: .top), style: borderStyle)
        text.append("\n")
        
        // Header row
        if showHeader {
            text.append(String(box.vertical), style: borderStyle)
            for (i, column) in columns.enumerated() {
                let cellContent = pad + justify(column.header, width: widths[i], justify: column.justify) + pad
                text.append(cellContent, style: column.headerStyle)
                text.append(String(box.vertical), style: borderStyle)
            }
            text.append("\n")
            
            // Header separator
            text.append(renderHorizontalBorder(widths: widths, position: .middle), style: borderStyle)
            text.append("\n")
        }
        
        // Data rows
        for row in rows {
            text.append(String(box.vertical), style: borderStyle)
            for (i, column) in columns.enumerated() {
                let value = i < row.count ? row[i] : ""
                let cellContent = pad + justify(value, width: widths[i], justify: column.justify) + pad
                text.append(cellContent, style: column.style)
                text.append(String(box.vertical), style: borderStyle)
            }
            text.append("\n")
        }
        
        // Bottom border
        text.append(renderHorizontalBorder(widths: widths, position: .bottom), style: borderStyle)
        
        return text
    }
    
    // MARK: - Private Helpers
    
    private enum BorderPosition {
        case top, middle, bottom
    }
    
    private func renderHorizontalBorder(widths: [Int], position: BorderPosition) -> String {
        let box = boxStyle
        let (left, mid, right): (Character, Character, Character)
        
        switch position {
        case .top:
            left = box.topLeft
            mid = box.topT
            right = box.topRight
        case .middle:
            left = box.leftT
            mid = box.cross
            right = box.rightT
        case .bottom:
            left = box.bottomLeft
            mid = box.bottomT
            right = box.bottomRight
        }
        
        var line = String(left)
        for (i, width) in widths.enumerated() {
            line += String(repeating: box.horizontal, count: width + padding * 2)
            line += String(i < widths.count - 1 ? mid : right)
        }
        return line
    }
    
    private func calculateColumnWidths(maxWidth: Int) -> [Int] {
        var widths = [Int]()
        
        for (i, column) in columns.enumerated() {
            if let fixedWidth = column.width {
                widths.append(fixedWidth)
            } else {
                var maxContent = column.header.count
                for row in rows {
                    if i < row.count {
                        maxContent = max(maxContent, row[i].count)
                    }
                }
                widths.append(maxContent)
            }
        }
        
        return widths
    }
    
    private func justify(_ string: String, width: Int, justify: Column.Justify) -> String {
        let length = string.count
        guard length < width else { return String(string.prefix(width)) }
        
        let padding = width - length
        
        switch justify {
        case .left:
            return string + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + string
        case .center:
            let leftPad = padding / 2
            let rightPad = padding - leftPad
            return String(repeating: " ", count: leftPad) + string + String(repeating: " ", count: rightPad)
        }
    }
    
    private func centerString(_ string: String, width: Int) -> String {
        justify(string, width: width, justify: .center)
    }
}
