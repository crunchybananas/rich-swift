import RichSwift

let console = Console()

// Header
console.rule("RichSwift Demo")
console.line()

// Basic styled output
console.print("[bold green]✓[/] Basic markup works!")
console.print("[bold red]Error:[/] Something went wrong (just kidding)")
console.print("[italic cyan]Tip:[/] You can combine [bold underline]multiple styles[/]")
console.line()

// Emoji support
console.rule("Emoji Support :rocket:")
console.print(":check: Emoji codes work! :tada: :star: :heart:".emojified)
console.print(":thumbsup: Use :emoji_name: syntax for shortcuts".emojified)
console.line()

// Panel
console.print(Panel(
    "RichSwift brings beautiful terminal output to Swift!\n\nFeatures:\n• Styled text\n• Tables\n• Panels\n• Progress bars\n• Trees\n• Syntax highlighting\n• Live updates",
    title: "Welcome",
    subtitle: "v0.3.0"
))
console.line()

// Table
console.rule("Tables")
let table = Table(title: "Star Wars Movies")
    .addColumn("Year", justify: .center)
    .addColumn("Title")
    .addColumn("Director", justify: .right)
    .addRow("1977", "A New Hope", "George Lucas")
    .addRow("1980", "The Empire Strikes Back", "Irvin Kershner")
    .addRow("1983", "Return of the Jedi", "Richard Marquand")
    .addRow("2015", "The Force Awakens", "J.J. Abrams")

console.print(table)
console.line()

// Tree view
console.rule("Tree View")
let tree = Tree("📁 RichSwift", style: Style.bold)
let src = tree.add("📁 Sources", style: Style(foreground: .yellow))
let richswift = src.add("📁 RichSwift")
richswift.add("📄 RichSwift.swift", style: Style(foreground: .green))
let consoleDir = richswift.add("📁 Console")
consoleDir.add("📄 Console.swift", style: Style(foreground: .green))
consoleDir.add("📄 Terminal.swift", style: Style(foreground: .green))
let renderables = richswift.add("📁 Renderables")
renderables.add("📄 Table.swift", style: Style(foreground: .green))
renderables.add("📄 Syntax.swift", style: Style(foreground: .green))
renderables.add("📄 Markdown.swift", style: Style(foreground: .green))
tree.add("📄 Package.swift", style: Style(foreground: .cyan))

console.print(tree)
console.line()

// Syntax highlighting
console.rule("Syntax Highlighting")
let swiftCode = """
import Foundation

struct User: Codable {
    let name: String
    let age: Int
    
    func greet() -> String {
        return "Hello, \\(name)!"
    }
}
"""
console.print(Syntax(swiftCode, language: .swift, theme: .monokai, lineNumbers: true))
console.line()

// JSON pretty printing
console.rule("JSON Pretty Print")
let jsonData: [String: Any] = [
    "name": "RichSwift",
    "version": "0.3.0",
    "features": ["tables", "trees", "syntax", "progress"],
    "awesome": true
]
console.printJSON(jsonData, sortKeys: true)
console.line()

// Markdown rendering
console.rule("Markdown")
let markdown = """
# Hello World

This is **bold** and this is *italic*.

- Item one
- Item two
- Item three

`inline code` and [links](https://github.com) work too!
"""
console.printMarkdown(markdown)
console.line()

// Progress bars
console.rule("Progress Bars")
for percent in stride(from: 0, through: 100, by: 25) {
    let bar = ProgressBar(completed: Double(percent), total: 100, width: 40)
    console.print(bar)
}
console.line()

// Colors
console.rule("Colors")
let colors: [Color] = [.red, .green, .yellow, .blue, .magenta, .cyan]
var colorText = Text()
for color in colors {
    colorText.append("████", style: Style(foreground: color))
}
console.print(colorText)

var brightText = Text()
for color: Color in [.brightRed, .brightGreen, .brightYellow, .brightBlue, .brightMagenta, .brightCyan] {
    brightText.append("████", style: Style(foreground: color))
}
console.print(brightText)
console.line()

// Terminal info
console.rule("Terminal Info")
let terminal = Terminal.shared
console.print("Size: [bold]\(terminal.width)[/]x[bold]\(terminal.height)[/]")
console.print("TTY: [bold]\(terminal.isTerminal ? "Yes" : "No")[/]")
console.print("Color support: [bold]\(terminal.supportsColor ? "Yes" : "No")[/]")
console.print("True color: [bold]\(terminal.supportsTrueColor ? "Yes" : "No")[/]")
console.print("Hyperlinks: [bold]\(terminal.supportsHyperlinks ? "Yes" : "No")[/]")
console.line()

console.rule()
console.print("[dim]Static demo complete! Run LiveDemo for animated features.[/]")
