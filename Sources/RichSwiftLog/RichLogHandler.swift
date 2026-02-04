import Logging
import RichSwift
import Foundation

/// A LogHandler that outputs beautifully formatted logs using RichSwift
public struct RichLogHandler: LogHandler {
    public var metadata: Logger.Metadata = [:]
    public var logLevel: Logger.Level = .info
    
    private let label: String
    private let console: Console
    private let showTimestamp: Bool
    private let showLabel: Bool
    private let showMetadata: Bool
    
    /// Create a new RichLogHandler
    public init(
        label: String,
        console: Console = .shared,
        showTimestamp: Bool = true,
        showLabel: Bool = true,
        showMetadata: Bool = true
    ) {
        self.label = label
        self.console = console
        self.showTimestamp = showTimestamp
        self.showLabel = showLabel
        self.showMetadata = showMetadata
    }
    
    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }
    
    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        var text = Text()
        
        // Timestamp
        if showTimestamp {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            text.append("[\(timestamp)] ", style: Style(foreground: .brightBlack))
        }
        
        // Level badge
        let (levelText, levelStyle) = formatLevel(level)
        text.append(levelText, style: levelStyle)
        text.append(" ")
        
        // Label
        if showLabel {
            text.append("[\(label)] ", style: Style(foreground: .cyan))
        }
        
        // Message
        text.append(String(describing: message), style: .none)
        
        // Metadata
        let mergedMetadata = self.metadata.merging(metadata ?? [:]) { _, new in new }
        if showMetadata && !mergedMetadata.isEmpty {
            text.append(" ")
            text.append(formatMetadata(mergedMetadata))
        }
        
        // Source location for debug/trace
        if level <= .debug {
            let filename = (file as NSString).lastPathComponent
            text.append(" ", style: .none)
            text.append("(\(filename):\(line))", style: Style(foreground: .brightBlack))
        }
        
        console.print(text)
    }
    
    private func formatLevel(_ level: Logger.Level) -> (String, Style) {
        switch level {
        case .trace:
            return ("TRACE", Style(foreground: .brightBlack))
        case .debug:
            return ("DEBUG", Style(foreground: .cyan))
        case .info:
            return (" INFO", Style(foreground: .green))
        case .notice:
            return ("NOTIC", Style(foreground: .blue))
        case .warning:
            return (" WARN", Style(foreground: .yellow, bold: true))
        case .error:
            return ("ERROR", Style(foreground: .red, bold: true))
        case .critical:
            return (" CRIT", Style(foreground: .white, background: .red, bold: true))
        }
    }
    
    private func formatMetadata(_ metadata: Logger.Metadata) -> Text {
        var text = Text()
        text.append("{", style: Style(foreground: .brightBlack))
        
        let items = metadata.map { key, value in
            "\(key)=\(value)"
        }
        text.append(items.joined(separator: ", "), style: Style(foreground: .brightBlack))
        
        text.append("}", style: Style(foreground: .brightBlack))
        return text
    }
}

// MARK: - Bootstrap Helper

extension RichLogHandler {
    /// Bootstrap the logging system with RichSwift
    public static func bootstrap(
        console: Console = .shared,
        level: Logger.Level = .info,
        showTimestamp: Bool = true,
        showLabel: Bool = true,
        showMetadata: Bool = true
    ) {
        LoggingSystem.bootstrap { label in
            var handler = RichLogHandler(
                label: label,
                console: console,
                showTimestamp: showTimestamp,
                showLabel: showLabel,
                showMetadata: showMetadata
            )
            handler.logLevel = level
            return handler
        }
    }
}
