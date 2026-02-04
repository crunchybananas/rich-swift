import Testing
@testable import RichSwift

@Suite("Color Tests")
struct ColorTests {
    @Test("Standard colors have correct ANSI codes")
    func standardColors() {
        #expect(Color.red.foregroundCode == "31")
        #expect(Color.green.foregroundCode == "32")
        #expect(Color.blue.foregroundCode == "34")
        
        #expect(Color.red.backgroundCode == "41")
        #expect(Color.green.backgroundCode == "42")
    }
    
    @Test("Bright colors have correct ANSI codes")
    func brightColors() {
        #expect(Color.brightRed.foregroundCode == "91")
        #expect(Color.brightGreen.foregroundCode == "92")
    }
    
    @Test("RGB colors format correctly")
    func rgbColors() {
        let color = Color.rgb(r: 255, g: 128, b: 64)
        #expect(color.foregroundCode == "38;2;255;128;64")
    }
    
    @Test("Named color lookup works")
    func namedColors() {
        #expect(Color.named("red") == .red)
        #expect(Color.named("GREEN") == .green)
        #expect(Color.named("bright_blue") == .brightBlue)
        #expect(Color.named("#ff0000") == .hex("#ff0000"))
        #expect(Color.named("invalid") == nil)
    }
}

@Suite("Style Tests")
struct StyleTests {
    @Test("Style generates correct ANSI codes")
    func styleAnsiCodes() {
        let style = Style(foreground: .red, bold: true)
        #expect(style.ansiCodes.contains("1"))
        #expect(style.ansiCodes.contains("31"))
    }
    
    @Test("Style parsing works")
    func styleParsing() {
        let style = Style.parse("bold red on white")
        #expect(style.bold == true)
        #expect(style.foreground == .red)
        #expect(style.background == .white)
    }
    
    @Test("Style merging works")
    func styleMerging() {
        let base = Style(foreground: .red, bold: true)
        let overlay = Style(foreground: .blue, italic: true)
        let merged = base.merged(with: overlay)
        
        #expect(merged.foreground == .blue)
        #expect(merged.bold == true)
        #expect(merged.italic == true)
    }
}

@Suite("Text Tests")
struct TextTests {
    @Test("Text concatenation works")
    func textConcatenation() {
        var text = Text("Hello")
        text.append(", ", style: .none)
        text.append("World", style: Style(foreground: .green))
        
        #expect(text.plain == "Hello, World")
        #expect(text.spans.count == 3)
    }
    
    @Test("Text count is accurate")
    func textCount() {
        let text = Text("Hello World")
        #expect(text.count == 11)
    }
}

@Suite("Markup Parser Tests")
struct MarkupParserTests {
    @Test("Basic markup parsing")
    func basicMarkup() {
        let text = "[bold]Hello[/]".asMarkup
        #expect(text.spans.count == 1)
        #expect(text.spans[0].style.bold == true)
        #expect(text.spans[0].text == "Hello")
    }
    
    @Test("Nested markup parsing")
    func nestedMarkup() {
        let text = "[bold][red]Hello[/][/]".asMarkup
        #expect(text.spans[0].style.bold == true)
        #expect(text.spans[0].style.foreground == .red)
    }
    
    @Test("Mixed content parsing")
    func mixedContent() {
        let text = "Hello [bold]World[/]!".asMarkup
        #expect(text.spans.count == 3)
        #expect(text.spans[0].text == "Hello ")
        #expect(text.spans[1].text == "World")
        #expect(text.spans[2].text == "!")
    }
    
    @Test("Escape sequence handling")
    func escapeSequences() {
        let text = "[[bold]]".asMarkup
        #expect(text.plain == "[bold]")
    }
}

@Suite("Table Tests")
struct TableTests {
    @Test("Table builds correctly")
    func tableBuilding() {
        let table = Table(title: "Test")
            .addColumn("Name")
            .addColumn("Value")
            .addRow("A", "1")
            .addRow("B", "2")
        
        #expect(table.columns.count == 2)
        #expect(table.rows.count == 2)
    }
}

@Suite("Progress Bar Tests")
struct ProgressBarTests {
    @Test("Progress percentage calculation")
    func progressPercentage() {
        let bar = ProgressBar(completed: 50, total: 100)
        #expect(bar.percentage == 0.5)
        
        let finished = ProgressBar(completed: 100, total: 100)
        #expect(finished.isFinished == true)
    }
    
    @Test("Progress handles edge cases")
    func progressEdgeCases() {
        let zero = ProgressBar(completed: 0, total: 0)
        #expect(zero.percentage == 0)
        
        let overflow = ProgressBar(completed: 150, total: 100)
        #expect(overflow.percentage == 1.0)
    }
}
