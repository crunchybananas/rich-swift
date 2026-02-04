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

// Panel
console.print(Panel(
    "RichSwift brings beautiful terminal output to Swift!\n\nFeatures:\n• Styled text\n• Tables\n• Panels\n• Progress bars\n• Trees\n• Live updates",
    title: "Welcome",
    subtitle: "v0.2.0"
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

// Different table styles
console.rule("Box Styles")

let styles: [(String, Table.BoxStyle)] = [
    ("Rounded", .rounded),
    ("Square", .square),
    ("Heavy", .heavy),
    ("ASCII", .ascii),
]

for (name, boxStyle) in styles {
    let miniTable = Table(boxStyle: boxStyle)
        .addColumn(name)
        .addRow("Example")
    console.print(miniTable)
}
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
renderables.add("📄 Panel.swift", style: Style(foreground: .green))
renderables.add("📄 Tree.swift", style: Style(foreground: .green))
let tests = tree.add("📁 Tests", style: Style(foreground: .yellow))
tests.add("📄 RichSwiftTests.swift", style: Style(foreground: .green))
tree.add("📄 Package.swift", style: Style(foreground: .cyan))
tree.add("📄 README.md", style: Style(foreground: .cyan))

console.print(tree)
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

// Columns layout
console.rule("Columns Layout")
let col1 = Panel("Column 1\nWith content", title: "Left")
let col2 = Panel("Column 2\nMore content", title: "Middle")
let col3 = Panel("Column 3\nEven more!", title: "Right")
console.print(Columns([col1, col2, col3], padding: 2))
console.line()

// Terminal info
console.rule("Terminal Info")
let terminal = Terminal.shared
console.print("Size: [bold]\(terminal.width)[/]x[bold]\(terminal.height)[/]")
console.print("TTY: [bold]\(terminal.isTerminal ? "Yes" : "No")[/]")
console.print("Color support: [bold]\(terminal.supportsColor ? "Yes" : "No")[/]")
console.print("True color: [bold]\(terminal.supportsTrueColor ? "Yes" : "No")[/]")
console.line()

console.rule()
console.print("[dim]Static demo complete! Run LiveDemo for animated features.[/]")
