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
    "RichSwift brings beautiful terminal output to Swift!\n\nFeatures:\n• Styled text\n• Tables\n• Panels\n• Progress bars",
    title: "Welcome",
    subtitle: "v0.1.0"
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
console.line()

console.rule()
console.print("[dim]Demo complete![/]")
