/// Display content in multiple columns side by side
public struct Columns: Renderable {
    public let items: [Renderable]
    public let padding: Int
    public let equalWidth: Bool
    public let expand: Bool
    
    public init(
        _ items: [Renderable],
        padding: Int = 2,
        equalWidth: Bool = false,
        expand: Bool = false
    ) {
        // Store as any Sendable to satisfy the protocol
        self.items = items
        self.padding = padding
        self.equalWidth = equalWidth
        self.expand = expand
    }
    
    public init(
        _ items: Renderable...,
        padding: Int = 2,
        equalWidth: Bool = false,
        expand: Bool = false
    ) {
        self.items = items
        self.padding = padding
        self.equalWidth = equalWidth
        self.expand = expand
    }
    
    public func render(console: Console) -> Text {
        guard !items.isEmpty else { return Text() }
        
        // Render each item to get their text
        let renderedItems = items.map { $0.render(console: console) }
        
        // Split each item into lines
        let itemLines: [[String]] = renderedItems.map { item in
            item.plain.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        }
        
        // Calculate column widths
        var columnWidths: [Int]
        if equalWidth {
            let totalPadding = padding * (items.count - 1)
            let availableWidth = console.width - totalPadding
            let width = availableWidth / items.count
            columnWidths = Array(repeating: width, count: items.count)
        } else {
            columnWidths = itemLines.map { lines in
                lines.map(\.count).max() ?? 0
            }
        }
        
        // If expand, adjust widths to fill console
        if expand {
            let currentTotal = columnWidths.reduce(0, +) + padding * (items.count - 1)
            if currentTotal < console.width {
                let extra = console.width - currentTotal
                let extraPerColumn = extra / items.count
                columnWidths = columnWidths.map { $0 + extraPerColumn }
            }
        }
        
        // Find max number of lines
        let maxLines = itemLines.map(\.count).max() ?? 0
        
        var text = Text()
        
        for lineIndex in 0..<maxLines {
            for (colIndex, lines) in itemLines.enumerated() {
                let line = lineIndex < lines.count ? lines[lineIndex] : ""
                let width = columnWidths[colIndex]
                
                // Pad the line to width
                let paddedLine = line.padding(toLength: width, withPad: " ", startingAt: 0)
                text.append(paddedLine)
                
                // Add spacing between columns (not after last)
                if colIndex < itemLines.count - 1 {
                    text.append(String(repeating: " ", count: padding))
                }
            }
            
            if lineIndex < maxLines - 1 {
                text.append("\n")
            }
        }
        
        return text
    }
}

// MARK: - Grid (alternative layout)

/// Display items in a grid with automatic wrapping
public struct Grid: Renderable {
    public let items: [Renderable]
    public let columns: Int?
    public let padding: Int
    
    public init(
        _ items: [Renderable],
        columns: Int? = nil,
        padding: Int = 2
    ) {
        self.items = items
        self.columns = columns
        self.padding = padding
    }
    
    public func render(console: Console) -> Text {
        guard !items.isEmpty else { return Text() }
        
        // Render items to determine width
        let renderedItems = items.map { $0.render(console: console) }
        let maxItemWidth = renderedItems.map { $0.plain.count }.max() ?? 10
        
        // Calculate number of columns
        let numColumns = columns ?? max(1, (console.width + padding) / (maxItemWidth + padding))
        let columnWidth = (console.width - padding * (numColumns - 1)) / numColumns
        
        var text = Text()
        
        for (index, item) in renderedItems.enumerated() {
            let col = index % numColumns
            let plain = item.plain
            
            // Truncate or pad to column width
            let content = plain.padding(toLength: columnWidth, withPad: " ", startingAt: 0)
            text.append(content)
            
            if col < numColumns - 1 && index < renderedItems.count - 1 {
                text.append(String(repeating: " ", count: padding))
            }
            
            // New line after last column or last item
            if col == numColumns - 1 && index < renderedItems.count - 1 {
                text.append("\n")
            }
        }
        
        return text
    }
}
