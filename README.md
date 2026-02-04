# RichSwift

A powerful, Swift-native terminal UI framework for building beautiful command-line applications. Originally inspired by Python's [Rich](https://github.com/Textualize/rich), RichSwift has evolved into a production-ready library designed for real-world Swift CLI tools, automation scripts, and headless applications.

## Why RichSwift?

- **Swift-First Design** - Built with Swift's type system, async/await, and actors
- **Production Ready** - Designed for use in real applications, not just demos
- **Composable** - Mix and match components to build complex interfaces
- **Modern Concurrency** - Full async/await support for live updates and progress tracking
- **Extensible** - Protocol-based architecture makes it easy to add custom renderables

## Features

### Display & Formatting
- 🎨 **Styled text** - Bold, italic, underline, strikethrough, colors (16, 256, TrueColor)
- 📊 **Tables** - Beautiful ASCII/Unicode tables with multiple box styles
- 🌳 **Tree views** - File trees, hierarchies with custom styles
- 🖼️ **Panels** - Bordered content boxes with titles and subtitles
- 💻 **Syntax highlighting** - 15+ languages with themes (Monokai, GitHub, Dracula)
- 📝 **Markdown** - Render markdown to styled terminal output
- 📊 **JSON** - Pretty printed with syntax highlighting
- 🔗 **Hyperlinks** - Clickable links in supported terminals (OSC 8)
- 😀 **Emoji** - Shortcode support (`:rocket:` → 🚀)

### Live & Interactive
- 📈 **Progress bars** - Static and animated with async/await
- 🎯 **Live updates** - 70+ spinner animations, status indicators
- ⏳ **Multi-progress** - Track multiple concurrent tasks with ETA
- 📋 **Prompts** - Interactive input, passwords, confirmation dialogs
- 🎛️ **Select menus** - Arrow key navigation, single and multi-select

### Integration
- 📜 **Swift-log** - Drop-in `LogHandler` with colored, formatted output
- 🔧 **Headless mode** - Run without TTY for CI/CD and automation
- 🖥️ **Terminal detection** - Auto-detect capabilities (color, size, hyperlinks)

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

- ✅ macOS 13+
- ✅ Linux (Ubuntu, Debian, Fedora)
- 🚧 Windows (planned)

## Use Cases

RichSwift is designed for:

- **CLI Tools** - Build polished command-line applications with rich output
- **Automation Scripts** - Pretty progress tracking and status updates
- **Headless Services** - Structured logging and diagnostics for server apps
- **Developer Tools** - Syntax highlighting, tree views for code analysis
- **AI/ML Pipelines** - Track training progress, display model outputs

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

### v0.6.0 - Production Ready ✅
- [x] Theme system (semantic colors, predefined themes)
- [x] Structured events for machine-readable output
- [x] Environment detection (CI, containers, NO_COLOR)
- [x] Output configuration (rich, plain, JSON modes)
- [x] Output recording for testing
- [x] 70+ spinner animations

### v1.0.0 - Release Candidate
- [ ] Comprehensive test suite
- [ ] DocC documentation
- [ ] Performance optimization
- [ ] Windows Terminal support
- [ ] Published to Swift Package Index

### Future
- [ ] Diff display (side-by-side, unified)
- [ ] YAML pretty printing
- [ ] Layout engine for complex UIs
- [ ] Plugin system for custom themes
- [ ] Accessibility improvements (screen reader hints)

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

Contributions are welcome! Areas where help is especially appreciated:

1. **Windows support** - Testing on Windows Terminal and ConPTY
2. **Performance** - Profiling and optimizing large table/tree rendering
3. **Accessibility** - Screen reader compatibility and semantic output
4. **Documentation** - DocC documentation and examples
5. **Testing** - Unit tests and snapshot tests for renderables

## Acknowledgments

RichSwift was inspired by these excellent projects:

- [Rich (Python)](https://github.com/Textualize/rich) - The original inspiration
- [Chalk (Node.js)](https://github.com/chalk/chalk) - Terminal styling patterns
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Swift CLI best practices
- [Textual (Python)](https://github.com/Textualize/textual) - TUI application framework

## License

MIT
