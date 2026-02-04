# Tables and Layout

Create beautiful tables, panels, and layouts for organized output.

## Overview

RichSwift provides powerful layout primitives for organizing content
in the terminal, from simple tables to complex multi-column layouts.

## Tables

Create tables with ``Table``:

```swift
let table = Table()

// Add columns
table.addColumn("Name", style: Style(foreground: .cyan))
table.addColumn("Age", justify: .right)
table.addColumn("City")

// Add rows
table.addRow(["Alice", "30", "New York"])
table.addRow(["Bob", "25", "Los Angeles"])
table.addRow(["Charlie", "35", "Chicago"])

console.print(table)
```

### Table Options

```swift
let table = Table()
table.title = "Employee Directory"
table.caption = "As of 2024"
table.showHeader = true
table.showEdge = true
table.boxStyle = .rounded  // .ascii, .square, .rounded, etc.
```

### Box Styles

- `.ascii` - ASCII characters only
- `.square` - Sharp corners
- `.rounded` - Rounded corners
- `.minimal` - No side borders
- `.double` - Double-line borders
- `.heavy` - Thick borders

## Panels

Wrap content in a bordered panel:

```swift
let panel = Panel(
    "Important information here",
    title: "Notice",
    subtitle: "v1.0",
    borderStyle: Style(foreground: .blue)
)

console.print(panel)
```

### Panel Options

```swift
let panel = Panel(
    content,
    title: "Title",
    subtitle: "Subtitle",
    boxStyle: .rounded,
    padding: (horizontal: 2, vertical: 1),
    expand: true  // Fill console width
)
```

## Columns

Display items side by side:

```swift
let columns = Columns([
    Panel("First panel", title: "1"),
    Panel("Second panel", title: "2"),
    Panel("Third panel", title: "3")
], padding: 2)

console.print(columns)
```

## Grid

Arrange items in a grid:

```swift
let items = [
    Text("🍎 Apple"),
    Text("🍊 Orange"),
    Text("🍋 Lemon"),
    Text("🍇 Grape"),
    Text("🍓 Strawberry"),
    Text("🍑 Peach")
]

let grid = Grid(items, columns: 3, padding: 4)
console.print(grid)
```

## Padding

Add space around content:

```swift
// All sides
let padded = Padding(content, all: 2)

// Specific sides
let padded = Padding(content, top: 1, right: 2, bottom: 1, left: 2)

// Horizontal/vertical
let padded = Padding(content, horizontal: 4, vertical: 1)
```

## Alignment

Align content within a width:

```swift
// Center
let centered = Align(text, .center, width: 40)

// Right align
let rightAligned = Align(text, .right, width: 40)

// Static helpers
let centered = Align.center(text, width: 40)
```

## Tree Structure

Display hierarchical data:

```swift
let tree = Tree("📁 Project")
let src = tree.add("📁 src")
src.add("📄 main.swift")
src.add("📄 utils.swift")
tree.add("📄 Package.swift")
tree.add("📄 README.md")

console.print(tree)
```

Output:
```
📁 Project
├── 📁 src
│   ├── 📄 main.swift
│   └── 📄 utils.swift
├── 📄 Package.swift
└── 📄 README.md
```

## Rules

Draw horizontal dividers:

```swift
// Simple rule
console.rule()

// Rule with title
console.rule("Section Title")

// Custom style
console.rule("Title", style: Style(foreground: .magenta), character: "═")
```

## Next Steps

- <doc:ProgressDisplays> - Animated progress indicators
- <doc:RichContent> - Syntax highlighting and more
