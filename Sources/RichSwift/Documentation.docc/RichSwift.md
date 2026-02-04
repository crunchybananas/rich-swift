# ``RichSwift``

A powerful Swift framework for building beautiful terminal interfaces.

## Overview

RichSwift is a comprehensive terminal UI framework that provides:

- **Rich Text Rendering**: ANSI-styled text with colors, bold, italic, and more
- **Tables & Layout**: Beautiful tables, panels, columns, and grids
- **Progress Indicators**: Animated progress bars and spinners
- **Syntax Highlighting**: Code highlighting for 15+ languages
- **Markdown Rendering**: Parse and display markdown in the terminal
- **Live Updates**: Real-time updating displays
- **Headless Support**: JSON/NDJSON output for CI/CD and automation

### Quick Start

```swift
import RichSwift

let console = Console()

// Styled text with markup
console.print("[bold blue]Hello[/bold blue] [green]World![/green]")

// Beautiful tables
let table = Table()
table.addColumn("Name")
table.addColumn("Status")
table.addRow(["Build", "[green]✓ Passed[/green]"])
console.print(table)

// Progress tracking
let progress = Progress()
let taskId = await progress.addTask("Processing", total: 100)
for i in 1...100 {
    await progress.advance(taskId, by: 1)
}
await progress.stop()
```

## Topics

### Essentials

- ``Console``
- ``Text``
- ``Style``
- ``Color``

### Markup & Styling

- ``MarkupParser``
- ``Theme``

### Tables & Layout

- ``Table``
- ``Panel``
- ``Columns``
- ``Grid``
- ``Padding``
- ``Align``

### Progress & Live

- ``Progress``
- ``Live``
- ``ProgressBar``
- ``Spinners``

### Rich Content

- ``Syntax``
- ``Markdown``
- ``JSON``
- ``Tree``
- ``Emoji``

### Headless & Production

- ``TaskQueue``
- ``ProgressStore``
- ``BatchProcessor``
- ``EventEmitter``
- ``ConsoleConfig``
- ``OutputFormat``
