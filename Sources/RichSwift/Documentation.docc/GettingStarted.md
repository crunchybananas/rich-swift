# Getting Started with RichSwift

Learn how to use RichSwift to create beautiful terminal interfaces.

## Overview

This guide walks you through the basics of RichSwift, from simple styled
output to complex interactive displays.

## Adding RichSwift to Your Project

Add RichSwift as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/rich-swift.git", from: "0.6.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["RichSwift"]
    )
]
```

## Basic Console Output

The ``Console`` class is your main entry point:

```swift
import RichSwift

let console = Console()

// Simple output
console.print("Hello, World!")

// Styled output using markup
console.print("[bold]Bold text[/bold]")
console.print("[red]Red text[/red]")
console.print("[bold green]Bold green text[/bold green]")
```

## Using Markup Syntax

RichSwift supports a BBCode-like markup syntax:

| Markup | Effect |
|--------|--------|
| `[bold]` | Bold text |
| `[italic]` | Italic text |
| `[underline]` | Underlined text |
| `[red]`, `[green]`, etc. | Foreground colors |
| `[on red]`, `[on green]`, etc. | Background colors |
| `[dim]` | Dimmed text |

You can also nest styles:

```swift
console.print("[bold [green]Hello[/green] World!]")
```

## Creating Tables

Tables are easy to create and customize:

```swift
let table = Table()
table.title = "User Directory"

table.addColumn("ID", style: Style(foreground: .cyan))
table.addColumn("Name")
table.addColumn("Email")

table.addRow(["1", "Alice", "alice@example.com"])
table.addRow(["2", "Bob", "bob@example.com"])

console.print(table)
```

## Progress Tracking

For long-running operations, use progress displays:

```swift
let progress = Progress()
await progress.start()

let taskId = await progress.addTask("Processing files", total: 100)

for i in 1...100 {
    // Do work...
    await progress.advance(taskId, by: 1)
}

await progress.stop()
```

## Next Steps

- Learn about <doc:StylingText> for advanced text formatting
- Explore <doc:TablesAndLayout> for complex layouts
- See <doc:HeadlessMode> for CI/CD integration
