import Foundation

/// Typealias to avoid collision with Spinner.Style
public typealias TextStyle = Style

/// A progress bar for showing completion status
public struct ProgressBar: Renderable, Sendable {
    public let completed: Double
    public let total: Double
    public let width: Int?
    public let completeStyle: Style
    public let incompleteStyle: Style
    public let finishedStyle: Style
    public let pulseStyle: Style
    public let completeChar: Character
    public let incompleteChar: Character
    
    public init(
        completed: Double,
        total: Double = 100,
        width: Int? = nil,
        completeStyle: Style = Style(foreground: .magenta),
        incompleteStyle: Style = Style(foreground: .brightBlack),
        finishedStyle: Style = Style(foreground: .green),
        pulseStyle: Style = Style(foreground: .cyan),
        completeChar: Character = "━",
        incompleteChar: Character = "━"
    ) {
        self.completed = completed
        self.total = total
        self.width = width
        self.completeStyle = completeStyle
        self.incompleteStyle = incompleteStyle
        self.finishedStyle = finishedStyle
        self.pulseStyle = pulseStyle
        self.completeChar = completeChar
        self.incompleteChar = incompleteChar
    }
    
    public var percentage: Double {
        guard total > 0 else { return 0 }
        return min(1.0, max(0.0, completed / total))
    }
    
    public var isFinished: Bool {
        completed >= total
    }
    
    public func render(console: Console) -> Text {
        let barWidth = width ?? max(20, console.width - 20)
        let filledWidth = Int(Double(barWidth) * percentage)
        let emptyWidth = barWidth - filledWidth
        
        var text = Text()
        
        let style = isFinished ? finishedStyle : completeStyle
        text.append(String(repeating: completeChar, count: filledWidth), style: style)
        text.append(String(repeating: incompleteChar, count: emptyWidth), style: incompleteStyle)
        
        // Add percentage
        let percentText = String(format: " %3.0f%%", percentage * 100)
        text.append(percentText, style: isFinished ? finishedStyle : .none)
        
        return text
    }
}

// MARK: - Spinner

/// An animated spinner for indeterminate progress
public struct Spinner: Sendable {
    public enum Style: Sendable {
        case dots
        case line
        case arrows
        case bounce
        case custom([String])
        
        var frames: [String] {
            switch self {
            case .dots:
                return ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
            case .line:
                return ["-", "\\", "|", "/"]
            case .arrows:
                return ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"]
            case .bounce:
                return ["⠁", "⠂", "⠄", "⡀", "⢀", "⠠", "⠐", "⠈"]
            case .custom(let frames):
                return frames
            }
        }
    }
    
    public let style: Style
    public let text: String
    public let textStyle: TextStyle
    public let spinnerStyle: TextStyle
    
    private var frameIndex: Int = 0
    
    public init(
        style: Style = .dots,
        text: String = "",
        textStyle: TextStyle = .none,
        spinnerStyle: TextStyle = TextStyle(foreground: .cyan)
    ) {
        self.style = style
        self.text = text
        self.textStyle = textStyle
        self.spinnerStyle = spinnerStyle
    }
    
    /// Get the current frame and advance
    public mutating func nextFrame() -> Text {
        let frames = style.frames
        let frame = frames[frameIndex % frames.count]
        frameIndex += 1
        
        var result = Text(frame, style: spinnerStyle)
        if !text.isEmpty {
            result.append(" ")
            result.append(text, style: textStyle)
        }
        return result
    }
}

