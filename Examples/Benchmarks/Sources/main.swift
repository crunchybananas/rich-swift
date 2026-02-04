import Foundation
import RichSwift

/// Benchmark harness for RichSwift performance testing
@main
struct BenchmarkRunner {
    static func main() async {
        let console = Console()
        
        console.rule("RichSwift Performance Benchmarks")
        console.print("")
        
        var results: [(String, TimeInterval)] = []
        
        // Run benchmarks
        results.append(("Text Rendering (1K iterations)", await benchmarkTextRendering()))
        results.append(("Markup Parsing (1K iterations)", await benchmarkMarkupParsing()))
        results.append(("Table Building (100 rows)", await benchmarkTableBuilding()))
        results.append(("Large Table (1000 rows)", await benchmarkLargeTable()))
        results.append(("Progress Bar Rendering", await benchmarkProgressBar()))
        results.append(("Syntax Highlighting", await benchmarkSyntaxHighlighting()))
        results.append(("Tree Building (100 nodes)", await benchmarkTreeBuilding()))
        results.append(("JSON Rendering", await benchmarkJSON()))
        
        // Display results
        console.print("")
        console.rule("Results")
        console.print("")
        
        let table = Table()
        table.addColumn("Benchmark", style: Style(foreground: .cyan))
        table.addColumn("Time", justify: .right)
        table.addColumn("Ops/sec", justify: .right)
        
        for (name, duration) in results {
            let opsPerSec: Double
            if name.contains("1K") {
                opsPerSec = 1000.0 / duration
            } else if name.contains("100 ") {
                opsPerSec = 100.0 / duration
            } else if name.contains("1000 ") {
                opsPerSec = 1000.0 / duration
            } else {
                opsPerSec = 1.0 / duration
            }
            
            let timeStr = String(format: "%.3fms", duration * 1000)
            let opsStr = String(format: "%.0f", opsPerSec)
            table.addRow([name, timeStr, opsStr])
        }
        
        console.print(table)
        console.print("")
        console.success("Benchmarks complete!")
    }
    
    // MARK: - Benchmarks
    
    static func benchmarkTextRendering() async -> TimeInterval {
        let iterations = 1000
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            var text = Text()
            text.append("Hello ", style: Style(foreground: .blue, bold: true))
            text.append("World", style: Style(foreground: .green))
            text.append("!", style: Style(foreground: .yellow))
            _ = text.render(forTerminal: true)
        }
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkMarkupParsing() async -> TimeInterval {
        let iterations = 1000
        let parser = MarkupParser()
        let markup = "[bold blue]Hello[/bold blue] [italic green]World[/italic green] [underline red]Test[/underline red]!"
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<iterations {
            _ = parser.parse(markup)
        }
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkTableBuilding() async -> TimeInterval {
        let console = Console()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let table = Table()
        table.addColumn("ID")
        table.addColumn("Name")
        table.addColumn("Email")
        table.addColumn("Status")
        
        for i in 0..<100 {
            table.addRow([
                "\(i)",
                "User \(i)",
                "user\(i)@example.com",
                i % 2 == 0 ? "[green]Active[/green]" : "[red]Inactive[/red]"
            ])
        }
        
        _ = table.render(console: console)
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkLargeTable() async -> TimeInterval {
        let console = Console()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let table = Table()
        for col in 0..<10 {
            table.addColumn("Column \(col)")
        }
        
        for row in 0..<1000 {
            var rowData: [String] = []
            for col in 0..<10 {
                rowData.append("R\(row)C\(col)")
            }
            table.addRow(rowData)
        }
        
        _ = table.render(console: console)
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkProgressBar() async -> TimeInterval {
        let console = Console()
        let iterations = 1000
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for i in 0..<iterations {
            let bar = ProgressBar(completed: Double(i), total: Double(iterations), width: 40)
            _ = bar.render(console: console)
        }
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkSyntaxHighlighting() async -> TimeInterval {
        let console = Console()
        let code = """
        import Foundation
        
        public class Example {
            private var value: Int = 42
            
            public init(value: Int) {
                self.value = value
            }
            
            public func process() async throws -> String {
                let result = await fetchData()
                return "Result: \\(result)"
            }
            
            private func fetchData() async -> Int {
                return value * 2
            }
        }
        """
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            let syntax = Syntax(code, language: .swift, lineNumbers: true)
            _ = syntax.render(console: console)
        }
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkTreeBuilding() async -> TimeInterval {
        let console = Console()
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let tree = Tree("Root")
        
        for i in 0..<10 {
            let level1 = tree.add("Level 1 - Node \(i)")
            for j in 0..<10 {
                _ = level1.add("Level 2 - Node \(j)")
            }
        }
        
        _ = tree.render(console: console)
        
        return CFAbsoluteTimeGetCurrent() - start
    }
    
    static func benchmarkJSON() async -> TimeInterval {
        let console = Console()
        
        // Build a complex nested structure
        var data: [String: Any] = [:]
        for i in 0..<50 {
            data["key\(i)"] = [
                "name": "Item \(i)",
                "value": i * 100,
                "active": i % 2 == 0,
                "tags": ["tag1", "tag2", "tag3"],
                "metadata": [
                    "created": "2024-01-01",
                    "updated": "2024-06-01"
                ]
            ]
        }
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            let json = JSON(data)
            _ = json.render(console: console)
        }
        
        return CFAbsoluteTimeGetCurrent() - start
    }
}
