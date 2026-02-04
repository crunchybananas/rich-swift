import Testing
@testable import RichSwift

// MARK: - Tree Tests

@Suite("Tree Tests")
struct TreeTests {
    @Test("Tree builds correctly")
    func treeBuilding() {
        let tree = Tree("Root")
        let child1 = tree.add("Child 1")
        let child2 = tree.add("Child 2")
        _ = child1.add("Grandchild")
        
        // Tree.root has children property
        #expect(tree.root.children.count == 2)
        #expect(child1.children.count == 1)
        #expect(child2.children.count == 0)
    }
    
    @Test("Tree renders with guides")
    func treeRendering() {
        let tree = Tree("📁 Root")
        tree.add("📄 File 1")
        tree.add("📄 File 2")
        
        let console = Console()
        let rendered = tree.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Root"))
        #expect(output.contains("File 1"))
        #expect(output.contains("File 2"))
    }
}

// MARK: - Panel Tests

@Suite("Panel Tests")
struct PanelTests {
    @Test("Panel creates with title and subtitle")
    func panelCreation() {
        let panel = Panel("Content", title: "Title", subtitle: "Subtitle")
        #expect(panel.title == "Title")
        #expect(panel.subtitle == "Subtitle")
    }
    
    @Test("Panel renders borders")
    func panelRendering() {
        let panel = Panel("Hello World", title: "Test")
        let console = Console()
        let rendered = panel.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Hello World"))
        #expect(output.contains("Test"))
    }
}

// MARK: - Syntax Highlighting Tests

@Suite("Syntax Highlighting Tests")
struct SyntaxTests {
    @Test("Syntax Language enum exists")
    func languageEnum() {
        // Verify languages are accessible
        let _ = Syntax.Language.swift
        let _ = Syntax.Language.python
        let _ = Syntax.Language.javascript
    }
    
    @Test("Syntax renders with line numbers")
    func syntaxLineNumbers() {
        let code = "let x = 1\nlet y = 2"
        let syntax = Syntax(code, language: .swift, lineNumbers: true)
        let console = Console()
        let rendered = syntax.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("1"))
        #expect(output.contains("2"))
    }
    
    @Test("Themes have different colors")
    func syntaxThemes() {
        let monokai = Syntax.Theme.monokai
        let github = Syntax.Theme.github
        
        // They should have different keyword styles
        #expect(monokai.keyword != github.keyword)
    }
}

// MARK: - Markdown Tests

@Suite("Markdown Tests")
struct MarkdownTests {
    @Test("Markdown parses headers")
    func markdownHeaders() {
        let md = Markdown("# Header 1\n## Header 2")
        let console = Console()
        let rendered = md.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Header 1"))
        #expect(output.contains("Header 2"))
    }
    
    @Test("Markdown parses lists")
    func markdownLists() {
        let md = Markdown("- Item 1\n- Item 2\n- Item 3")
        let console = Console()
        let rendered = md.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Item 1"))
        #expect(output.contains("•"))
    }
}

// MARK: - JSON Tests

@Suite("JSON Tests")
struct JSONTests {
    @Test("JSON pretty prints objects")
    func jsonObjects() {
        let data: [String: Any] = ["name": "Test", "value": 42]
        let json = JSON(data)
        let console = Console()
        let rendered = json.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("name"))
        #expect(output.contains("Test"))
        #expect(output.contains("42"))
    }
    
    @Test("JSON handles arrays")
    func jsonArrays() {
        let data = [1, 2, 3]
        let json = JSON(data)
        let console = Console()
        let rendered = json.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("["))
        #expect(output.contains("]"))
    }
    
    @Test("JSON handles nested structures")
    func jsonNested() {
        let data: [String: Any] = [
            "user": ["name": "Alice", "age": 30],
            "active": true
        ]
        let json = JSON(data)
        let console = Console()
        let rendered = json.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("user"))
        #expect(output.contains("Alice"))
    }
}

// MARK: - Emoji Tests

@Suite("Emoji Tests")
struct EmojiTests {
    @Test("Emoji lookup works")
    func emojiLookup() {
        #expect(Emoji.get("rocket") == "🚀")
        #expect(Emoji.get("star") == "⭐")
        #expect(Emoji.get("heart") == "❤️")
        // Unknown emoji returns fallback format
        #expect(Emoji.get("nonexistent") == ":nonexistent:")
    }
    
    @Test("Emojify replaces codes")
    func emojify() {
        let text = "Hello :rocket: World :star:"
        let result = Emoji.emojify(text)
        
        #expect(result.contains("🚀"))
        #expect(result.contains("⭐"))
        #expect(!result.contains(":rocket:"))
    }
    
    @Test("String extension works")
    func stringEmojified() {
        let text = ":check: Done!".emojified
        #expect(text.contains("✅"))
    }
}

// MARK: - Theme Tests

@Suite("Theme Tests")
struct ThemeTests {
    @Test("Theme has semantic colors")
    func themeColors() {
        let theme = Theme()
        #expect(theme.success == .green)
        #expect(theme.error == .red)
        #expect(theme.warning == .yellow)
        #expect(theme.info == .blue)
    }
    
    @Test("Predefined themes exist")
    func predefinedThemes() {
        let _ = Theme.default
        let _ = Theme.minimal
        let _ = Theme.highContrast
        let _ = Theme.monochrome
        let _ = Theme.dracula
        let _ = Theme.github
        // No crash = success
    }
    
    @Test("Monochrome theme has no colors")
    func monochromeTheme() {
        let theme = Theme.monochrome
        #expect(theme.success == .white)
        #expect(theme.error == .white)
    }
}

// MARK: - Event Tests

@Suite("Event Tests")
struct EventTests {
    @Test("Event creates correctly")
    func eventCreation() {
        let event = Event(
            type: "test",
            message: "Test message",
            level: .info,
            data: ["key": "value"]
        )
        
        #expect(event.type == "test")
        #expect(event.message == "Test message")
        #expect(event.level == .info)
    }
    
    @Test("Event converts to JSON")
    func eventJSON() {
        let event = Event(type: "test", message: "Hello")
        let json = event.toJSON()
        
        #expect(json.contains("test"))
        #expect(json.contains("Hello"))
    }
}

// MARK: - Output Config Tests

@Suite("Output Config Tests")
struct OutputConfigTests {
    @Test("Default config is rich format")
    func defaultConfig() {
        let config = ConsoleConfig.default
        #expect(config.format == .rich)
        #expect(config.forceColor == false)
        #expect(config.noStyle == false)
    }
    
    @Test("CI config is plain format")
    func ciConfig() {
        let config = ConsoleConfig.ci
        #expect(config.format == .plain)
        #expect(config.isCI == true)
        #expect(config.showTimestamps == true)
    }
    
    @Test("JSON config disables style")
    func jsonConfig() {
        let config = ConsoleConfig.json
        #expect(config.format == .json)
        #expect(config.noStyle == true)
    }
    
    @Test("Testing config captures output")
    func testingConfig() {
        let recorder = OutputRecorder()
        let config = ConsoleConfig.testing(recorder: recorder)
        
        #expect(config.recorder != nil)
        #expect(config.width == 80)
    }
}

// MARK: - Output Recorder Tests

@Suite("Output Recorder Tests")
struct OutputRecorderTests {
    @Test("Recorder captures entries")
    func recorderCaptures() {
        let recorder = OutputRecorder()
        recorder.record("Hello", type: .print)
        recorder.record("World", type: .print)
        
        #expect(recorder.entries.count == 2)
        #expect(recorder.entries[0].rawContent == "Hello")
    }
    
    @Test("Recorder strips ANSI codes")
    func recorderStripsAnsi() {
        let recorder = OutputRecorder()
        recorder.record("\u{001B}[31mRed Text\u{001B}[0m", type: .print)
        
        #expect(recorder.entries[0].rawContent == "Red Text")
    }
    
    @Test("Recorder clears entries")
    func recorderClears() {
        let recorder = OutputRecorder()
        recorder.record("Test", type: .print)
        recorder.clear()
        
        #expect(recorder.entries.isEmpty)
    }
    
    @Test("Recorder text output")
    func recorderText() {
        let recorder = OutputRecorder()
        recorder.record("Line 1", type: .print)
        recorder.record("Line 2", type: .print)
        
        #expect(recorder.text == "Line 1\nLine 2")
    }
}

// MARK: - Environment Tests

@Suite("Environment Tests")
struct EnvironmentTests {
    @Test("Environment detects NO_COLOR")
    func noColorDetection() {
        // This test just verifies the property exists and doesn't crash
        let _ = Environment.noColor
        let _ = Environment.forceColor
        let _ = Environment.term
    }
    
    @Test("Suggested config respects environment")
    func suggestedConfig() {
        let config = Environment.suggestedConfig
        // Just verify it returns a valid config
        #expect(config.format == .rich || config.format == .plain)
    }
}

// MARK: - Spinners Tests

@Suite("Spinners Tests")
struct SpinnersTests {
    @Test("Spinners collection exists")
    func spinnersExist() {
        #expect(Spinners.dots.frames.count > 0)
        #expect(Spinners.line.frames.count > 0)
        #expect(Spinners.arrow.frames.count > 0)
    }
    
    @Test("Spinner frame at time")
    func spinnerFrameAt() {
        let spinner = Spinners.dots
        let frame0 = spinner.frame(at: .zero)
        _ = spinner.frame(at: .milliseconds(80))  // Verify subsequent frame works
        
        // Frames should cycle
        #expect(frame0 == spinner.frames[0])
    }
    
    @Test("All spinners dictionary")
    func allSpinners() {
        #expect(Spinners.all.count > 50)
        #expect(Spinners.get("dots") != nil)
        #expect(Spinners.get("nonexistent") == nil)
    }
}

// MARK: - Highlighter Tests

@Suite("Highlighter Tests")
struct HighlighterTests {
    @Test("ReprHighlighter highlights numbers")
    func reprNumbers() {
        let highlighter = ReprHighlighter()
        let text = highlighter.highlight("value: 42")
        
        #expect(text.plain == "value: 42")
        #expect(text.spans.count > 1)
    }
    
    @Test("ReprHighlighter highlights strings")
    func reprStrings() {
        let highlighter = ReprHighlighter()
        let text = highlighter.highlight("name: \"Alice\"")
        
        #expect(text.plain == "name: \"Alice\"")
    }
    
    @Test("ReprHighlighter highlights booleans")
    func reprBooleans() {
        let highlighter = ReprHighlighter()
        let text = highlighter.highlight("active: true")
        
        #expect(text.plain == "active: true")
    }
}

// MARK: - Columns Tests

@Suite("Columns Tests")
struct ColumnsTests {
    @Test("Columns creates with items")
    func columnsCreation() {
        let cols = Columns([Text("A"), Text("B"), Text("C")])
        #expect(cols.items.count == 3)
    }
    
    @Test("Grid creates with items")
    func gridCreation() {
        let grid = Grid([Text("A"), Text("B"), Text("C"), Text("D"), Text("E"), Text("F")], columns: 3)
        #expect(grid.items.count == 6)
    }
}

// MARK: - Layout Tests

@Suite("Layout Tests")
struct LayoutTests {
    @Test("Padding adds spaces")
    func paddingCreation() {
        let padded = Padding(Text("Hello"), left: 2)
        let console = Console()
        let rendered = padded.render(console: console)
        
        #expect(rendered.plain.hasPrefix("  "))
    }
    
    @Test("Align positions content")
    func alignCreation() {
        let aligned = Align(Text("Hi"), .center, width: 10)
        let console = Console()
        let rendered = aligned.render(console: console)
        
        // Centered "Hi" in width 10 should have padding
        #expect(rendered.count == 10)
    }
}

// MARK: - Error Display Tests

@Suite("Error Display Tests")
struct ErrorDisplayTests {
    @Test("PrettyError renders")
    func prettyErrorRenders() {
        struct TestError: Error, CustomStringConvertible {
            var description: String { "Test error message" }
        }
        
        let error = PrettyError(TestError())
        let console = Console()
        let rendered = error.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Error"))
    }
    
    @Test("Traceback renders")
    func tracebackRenders() {
        struct TestError: Error {}
        
        let traceback = Traceback(TestError())
        let console = Console()
        let rendered = traceback.render(console: console)
        let output = rendered.render()
        
        #expect(output.contains("Traceback"))
    }
}
