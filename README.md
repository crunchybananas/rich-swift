# RichSwift

A Swift port of Python's [Rich](https://github.com/Textualize/rich) library for beautiful terminal output.

## Features

- 🎨 **Styled text** - Bold, italic, underline, colors, and more
- 📊 **Tables** - Beautiful ASCII/Unicode tables
- 📈 **Progress bars** - Animated progress indicators
- 🖨️ **Console** - Smart terminal output with automatic width detection
- ✨ **Markup** - Simple markup syntax like `[bold red]Hello[/]`

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/rich-swift.git", from: "0.1.0")
]
```

## Quick Start

```swift
import RichSwift

let console = Console()

// Simple styled output
console.print("Hello, [bold green]World[/]!")

// Tables
let table = Table(title: "Star Wars Movies")
table.addColumn("Released")
table.addColumn("Title")
table.addRow("1977", "A New Hope")
table.addRow("1980", "The Empire Strikes Back")
console.print(table)

// Progress bars
for await _ in console.progress(total: 100) {
    // do work
}
```

## Platforms

- ✅ macOS
- ✅ Linux
- 🚧 Windows (planned)

## Roadmap

### v0.1.0 - Foundation (Current)
- [x] Core styling system (colors, attributes)
- [x] Rich-style markup parser `[bold red]text[/]`
- [x] Text rendering with ANSI escape codes
- [x] Tables with multiple box styles
- [x] Panels with titles/subtitles
- [x] Progress bars (static)
- [x] Terminal detection (size, color support)
- [x] Cross-platform structure (SPM)

### v0.2.0 - Live Output
- [ ] Live display context (update in place)
- [ ] Animated progress bars with async/await
- [ ] Spinner animations
- [ ] Status indicators
- [ ] Multi-progress (multiple concurrent bars)

### v0.3.0 - Rich Content
- [ ] Syntax highlighting for code blocks
- [ ] Markdown rendering
- [ ] Tree view (file trees, hierarchies)
- [ ] Columns/grid layout
- [ ] Padding and alignment utilities

### v0.4.0 - Developer Experience
- [ ] Swift-log integration (`LogHandler`)
- [ ] Prompt/input utilities
- [ ] Confirmation dialogs
- [ ] Select menus (arrow key navigation)
- [ ] Pretty exception/error display

### v0.5.0 - Advanced Features
- [ ] Emoji support with fallbacks
- [ ] Box drawing with custom styles
- [ ] JSON/YAML pretty printing
- [ ] Diff display (side-by-side, unified)
- [ ] Hyperlinks (OSC 8 terminals)

### v1.0.0 - Production Ready
- [ ] Windows Terminal support
- [ ] Comprehensive documentation
- [ ] Performance optimization
- [ ] 100% API documentation coverage
- [ ] Published to Swift Package Index

## Next Steps

If you're picking this up, here's the suggested order of development:

### 1. Live Display (High Impact)
The killer feature of Rich is live updating. Start with:

```swift
// Goal API:
let live = console.live()
live.update(progressBar)  // Updates in place
live.stop()

// Or with async/await:
for await progress in console.track(items) {
    // Automatically shows/updates progress
}
```

Key files to create:
- `Sources/RichSwift/Live/LiveDisplay.swift`
- `Sources/RichSwift/Live/RefreshThread.swift`

### 2. Syntax Highlighting
Would make this invaluable for CLI dev tools:

```swift
console.print(Code(source, language: .swift))
```

Consider using tree-sitter bindings or a simple regex-based highlighter.

### 3. Swift-Log Integration
Easy win for adoption:

```swift
import Logging
LoggingSystem.bootstrap { label in
    RichLogHandler(label: label, console: .shared)
}
```

### 4. Input/Prompts
Interactive CLI apps need this:

```swift
let name = console.prompt("What is your name?")
let confirmed = console.confirm("Continue?")
let choice = console.select("Pick one:", choices: ["A", "B", "C"])
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
