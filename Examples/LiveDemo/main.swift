import RichSwift
import Foundation

@main
struct LiveDemo {
    static func main() async throws {
        let console = Console()
        
        // Header
        console.rule("RichSwift Live Demo")
        console.print("[bold cyan]This demo shows animated/live features[/]")
        console.line()
        
        // Status spinner demo
        console.rule("Status Spinner")
        
        try await console.status("Loading configuration...") {
            try await Task.sleep(for: .seconds(1.5))
        }
        
        try await console.status("Connecting to server...") {
            try await Task.sleep(for: .seconds(1))
        }
        
        try await console.status("Downloading data...") {
            try await Task.sleep(for: .seconds(2))
        }
        
        console.line()
        
        // Progress tracking with multiple tasks
        console.rule("Multi-Task Progress")
        
        try await console.progress { progress in
            let task1 = await progress.addTask(description: "Downloading", total: 100)
            let task2 = await progress.addTask(description: "Processing", total: 50)
            let task3 = await progress.addTask(description: "Uploading", total: 75)
            
            // Simulate concurrent work
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for _ in 0..<100 {
                        await task1.advance()
                        try? await Task.sleep(for: .milliseconds(30))
                    }
                }
                group.addTask {
                    for _ in 0..<50 {
                        await task2.advance()
                        try? await Task.sleep(for: .milliseconds(50))
                    }
                }
                group.addTask {
                    for _ in 0..<75 {
                        await task3.advance()
                        try? await Task.sleep(for: .milliseconds(35))
                    }
                }
            }
        }
        
        console.line()
        
        // Simple progress iteration
        console.rule("Progress Iterator")
        
        var sum = 0
        for await item in console.progress(Array(1...50), description: "Computing") {
            sum += item
            try? await Task.sleep(for: .milliseconds(50))
        }
        console.print("Sum of 1-50: [bold green]\(sum)[/]")
        
        console.line()
        
        // Live display demo
        console.rule("Live Display")
        
        let live = Live(console: console)
        await live.start()
        
        for i in 1...10 {
            var text = Text()
            text.append("Counter: ", style: Style.bold)
            text.append("\(i)", style: Style(foreground: .cyan, bold: true))
            text.append(" / 10", style: Style(foreground: .brightBlack))
            
            // Add a visual bar
            text.append("\n")
            let filled = i * 4
            let empty = 40 - filled
            text.append(String(repeating: "█", count: filled), style: Style(foreground: .green))
            text.append(String(repeating: "░", count: empty), style: Style(foreground: .brightBlack))
            
            await live.update(text)
            try? await Task.sleep(for: .milliseconds(300))
        }
        
        await live.stop()
        
        console.line()
        console.rule()
        console.print("[bold green]✓[/] Live demo complete!")
    }
}
