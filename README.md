# RichSwift

A Swift port of Python's [Rich](https://github.com/Textualize/rich) library for beautiful terminal output.

## Features

- 🎨 **Styled text** - Bold, italic, underline, colors, and more
- 📊 **Tables** - Beautiful ASCII/Unicode tables with multiple box styles
- 📈 **Progress bars** - Static and animated with async/await
- 🌳 **Tree views** - File trees, hierarchies with custom styles
- 🖼️ **Panels** - Bordered content boxes with titles
- 💻 **Syntax highlighting** - Code blocks with themes (Monokai, GitHub, Dracula)
- 📝 **Markdown** - Render markdown to styled terminal output
- 🎯 **Live updates** - Spinners, status indicators, multi-progress tracking
- 📋 **Prompts** - Interactive input, confirmation, select menus
- 🔗 **Hyperlinks** - Clickable links in supported terminals (OSC 8)
- 😀 **Emoji** - Shortcode support (`:rocket:` → 🚀)
- 📊 **JSON** - Pretty printed with syntax highlighting
- 📜 **Logging** - Swift-log integration with colored output

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/rich-swift.git", from: "0.3.0")
]
```

## Quick Start

```swift
import RichSwift

let console = Console()

// Simple styled output
console.print("Hello, [bold green]World[/]!")

// Emoji support
console.print(":rocket: Launching! :star:".emojified)

// Tables
let table = Table(title: "Star Wars Movies")
    .addColumn("Released")
    .addColumn("Title")
    .addRow("1977", "A New Hope")
    .addRow("1980", "The Empire Strikes Back")
console.print(table)

// Tree views
let tree = Tree("📁 Project")
tree.add("📄 README.md")
tree.add("📁 Sources").add("📄 main.swift")
console.print(tree)

// Syntax highlighting
let code = """
func greet(name: String) {
    print("Hello, \\(name)!")
}
"""
console.print(Syntax(code, language: .swift, lineNumbers: true))

// Markdown
console.printMarkdown("# Hello\n\nThis is **bold** and *italic*.")

// JSON pretty printing
console.printJSON(["name": "RichSwift", "version": "0.3.0"])

// Progress with async/await
try await console.status("Loading...") {
    try await Task.sleep(for: .seconds(2))
}

// Multi-task progress tracking
try await console.progress { progress in
    let task = await progress.addTask(description: "Downloading", total: 100)
    for _ in 0..<100 {
        await task.advance()
        try await Task.sleep(for: .milliseconds(50))
    }
}

// Interactive prompts
let name = console.prompt("What is your name?")
let confirmed = console.confirm("Continue?")
let choice = console.select("Pick one:", choices: ["Option A", "Option B", "Option C"])
```

### Swift-Log Integration

```swift
import Logging
import RichSwiftLog

LoggingSystem.bootstrap { label in
    RichLogHandler(label: label, console: Console.shared)
}

let logger = Logger(label: "com.example.app")
logger.info("Application started")
logger.error("Something went wrong!")
```

## Platforms

- ✅ macOS
- ✅ Linux
- 🚧 Windows (planned)

## Roadmap

### v0.1.0 - Foundation ✅
- [x] Core styling system (colors, attributes)
- [x] Rich-style markup parser `[bold red]text[/]`
- [x] Text rendering with ANSI escape codes
- [x] Tables with multiple box styles
- [x] Panels with titles/subtitles
- [x] Progress bars (static)
- [x] Terminal detection (size, color support)
- [x] Cross-platform structure (SPM)

### v0.2.0 - Live Output ✅
- [x] Live display context (update in place)
- [x] Animated progress bars with async/await
- [x] Spinner animations
- [x] Status indicators
- [x] Multi-progress (multiple concurrent bars)

### v0.3.0 - Rich Content ✅
- [x] Tree view (file trees, hierarchies)
- [x] Columns/grid layout
- [x] Padding and alignment utilities
- [x] Syntax highlighting for code blocks
- [x] Markdown rendering

### v0.4.0 - Developer Experience ✅
- [x] Swift-log integration (`LogHandler`)
- [x] Prompt/input utilities
- [x] Confirmation dialogs
- [x] Select menus (arrow key navigation)
- [x] Pretty exception/error display

### v0.5.0 - Advanced Features ✅
- [x] Emoji support with shortcodes
- [x] JSON pretty printing
- [x] Hyperlinks (OSC 8 terminals)
- [ ] Diff display (side-by-side, unified)
- [ ] YAML pretty printing

### v1.0.0 - Production Ready
- [ ] Windows Terminal support
- [ ] Comprehensive documentation
- [ ] Performance optimization
- [ ] 100% API documentation coverage
- [ ] Published to Swift Package Index

## Running the Demos

```bash
# Static demo (tables, panels, trees, syntax, etc.)
swift run Demo

# Live/animated demo (spinners, progress bars)
swift run LiveDemo
```

## API Reference

### Console

```swift
let console = Console()

// Output
console.print("Text")                    // Print styled text
console.print(table)                     // Print any Renderable
console.printMarkdown(string)            // Render markdown
console.printJSON(object)                // Pretty print JSON
console.rule("Title")                    // Horizontal rule
console.line()                           // Blank line

// Input
console.prompt("Name?")                  // Text input
console.promptInt("Age?")                // Integer input
console.password("Password:")            // Hidden input
console.confirm("Continue?")             // Yes/no
console.select("Choice:", choices: [...])// Single select
console.multiSelect("Pick:", choices: [...]) // Multi select
```

### Renderables

```swift
// Table
Table(title: "Title", boxStyle: .rounded)
    .addColumn("Header")
    .addRow("Cell")

// Panel
Panel("Content", title: "Title", subtitle: "Subtitle")

// Tree
let tree = Tree("Root")
tree.add("Child").add("Grandchild")

// Syntax
Syntax(code, language: .swift, theme: .monokai, lineNumbers: true)

// Progress
ProgressBar(completed: 50, total: 100, width: 40)
```

### Styles

```swift
// Text with styles
var text = Text()
text.append("Bold", style: .bold)
text.append("Red", style: Style(foreground: .red))
text.appendLink("Click", url: "https://example.com")

// Colors
Color.red, .green, .blue, .rgb(255, 128, 0), .hex("#ff8000")
```

## Contributing

This is a learning project! Areas where help is welcome:

1. **Windows support** - Need testing on Windows Terminal
2. **Performance** - Profiling large table rendering
3. **Accessibility** - Screen reader compatibility
4. **Documentation** - DocC documentation site

## Inspiration

- [Rich (Python)](https://github.com/Textualize/rich) - The original
- [Chalk (Node.js)](https://github.com/chalk/chalk) - Terminal styling
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - CLI patterns

## License

MIT
