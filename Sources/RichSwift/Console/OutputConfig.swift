import Foundation

/// Output format options for machine-readable output
public enum OutputFormat: String, Sendable {
    case rich      // Default styled terminal output
    case plain     // Plain text without ANSI codes
    case json      // JSON output for parsing
    case ndjson    // Newline-delimited JSON (one object per line)
}

/// A recorder that captures console output for testing or logging
public final class OutputRecorder: @unchecked Sendable {
    
    /// Recorded entries
    public private(set) var entries: [Entry] = []
    
    /// An entry in the recording
    public struct Entry: Sendable {
        public let timestamp: Date
        public let type: EntryType
        public let content: String
        public let rawContent: String  // Without ANSI codes
        
        public enum EntryType: String, Sendable {
            case print
            case rule
            case table
            case panel
            case tree
            case progress
            case error
        }
    }
    
    private let lock = NSLock()
    
    public init() {}
    
    /// Record an entry
    func record(_ content: String, type: Entry.EntryType) {
        lock.lock()
        defer { lock.unlock() }
        
        entries.append(Entry(
            timestamp: Date(),
            type: type,
            content: content,
            rawContent: stripAnsi(content)
        ))
    }
    
    /// Clear all recorded entries
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        entries.removeAll()
    }
    
    /// Get all raw content as a single string
    public var text: String {
        lock.lock()
        defer { lock.unlock() }
        return entries.map(\.rawContent).joined(separator: "\n")
    }
    
    /// Get entries as JSON
    public var json: String {
        lock.lock()
        defer { lock.unlock() }
        
        let jsonEntries = entries.map { entry -> [String: Any] in
            [
                "timestamp": ISO8601DateFormatter().string(from: entry.timestamp),
                "type": entry.type.rawValue,
                "content": entry.rawContent
            ]
        }
        
        if let data = try? JSONSerialization.data(withJSONObject: jsonEntries, options: .prettyPrinted),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "[]"
    }
    
    /// Strip ANSI escape codes from a string
    private func stripAnsi(_ text: String) -> String {
        let pattern = #"\x1B\[[0-9;]*[a-zA-Z]|\x1B\]8;;[^\x1B]*\x1B\\|\x1B\]8;;\x1B\\"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        return regex.stringByReplacingMatches(
            in: text,
            range: NSRange(text.startIndex..., in: text),
            withTemplate: ""
        )
    }
}

/// Configuration for Console output behavior
public struct ConsoleConfig: Sendable {
    
    /// Output format
    public var format: OutputFormat
    
    /// Whether to force color output even when not a TTY
    public var forceColor: Bool
    
    /// Whether to disable all styling
    public var noStyle: Bool
    
    /// Width override (nil = auto-detect)
    public var width: Int?
    
    /// Whether this is running in CI environment
    public var isCI: Bool
    
    /// Whether to show timestamps
    public var showTimestamps: Bool
    
    /// Output recorder (for testing)
    public var recorder: OutputRecorder?
    
    /// Default configuration
    public static let `default` = ConsoleConfig(
        format: .rich,
        forceColor: false,
        noStyle: false,
        width: nil,
        isCI: ProcessInfo.processInfo.environment["CI"] != nil,
        showTimestamps: false,
        recorder: nil
    )
    
    /// Configuration for CI environments
    public static var ci: ConsoleConfig {
        var config = ConsoleConfig.default
        config.isCI = true
        config.format = .plain
        config.showTimestamps = true
        return config
    }
    
    /// Configuration for JSON output
    public static var json: ConsoleConfig {
        var config = ConsoleConfig.default
        config.format = .json
        config.noStyle = true
        return config
    }
    
    /// Configuration for testing (captures output)
    public static func testing(recorder: OutputRecorder = OutputRecorder()) -> ConsoleConfig {
        var config = ConsoleConfig.default
        config.recorder = recorder
        config.noStyle = true
        config.width = 80
        return config
    }
    
    public init(
        format: OutputFormat = .rich,
        forceColor: Bool = false,
        noStyle: Bool = false,
        width: Int? = nil,
        isCI: Bool = false,
        showTimestamps: Bool = false,
        recorder: OutputRecorder? = nil
    ) {
        self.format = format
        self.forceColor = forceColor
        self.noStyle = noStyle
        self.width = width
        self.isCI = isCI
        self.showTimestamps = showTimestamps
        self.recorder = recorder
    }
}

// MARK: - Environment Detection

public struct Environment {
    
    /// Check if running in a CI environment
    public static var isCI: Bool {
        let env = ProcessInfo.processInfo.environment
        return env["CI"] != nil ||
               env["CONTINUOUS_INTEGRATION"] != nil ||
               env["GITHUB_ACTIONS"] != nil ||
               env["GITLAB_CI"] != nil ||
               env["JENKINS_URL"] != nil ||
               env["TRAVIS"] != nil ||
               env["CIRCLECI"] != nil ||
               env["BUILDKITE"] != nil
    }
    
    /// Check if running in a container
    public static var isContainer: Bool {
        FileManager.default.fileExists(atPath: "/.dockerenv") ||
        ProcessInfo.processInfo.environment["KUBERNETES_SERVICE_HOST"] != nil
    }
    
    /// Check if NO_COLOR environment variable is set
    public static var noColor: Bool {
        ProcessInfo.processInfo.environment["NO_COLOR"] != nil
    }
    
    /// Check if FORCE_COLOR environment variable is set
    public static var forceColor: Bool {
        ProcessInfo.processInfo.environment["FORCE_COLOR"] != nil
    }
    
    /// Get the TERM environment variable
    public static var term: String? {
        ProcessInfo.processInfo.environment["TERM"]
    }
    
    /// Get the COLORTERM environment variable
    public static var colorTerm: String? {
        ProcessInfo.processInfo.environment["COLORTERM"]
    }
    
    /// Suggested console config based on environment
    public static var suggestedConfig: ConsoleConfig {
        var config = ConsoleConfig.default
        
        if isCI {
            config.isCI = true
            config.showTimestamps = true
        }
        
        if noColor {
            config.noStyle = true
        }
        
        if forceColor {
            config.forceColor = true
        }
        
        return config
    }
}
