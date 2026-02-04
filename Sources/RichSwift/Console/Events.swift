import Foundation

/// A structured event for machine-readable output
public struct Event: Sendable, Codable {
    
    /// Event type/category
    public let type: String
    
    /// Event message
    public let message: String
    
    /// Timestamp
    public let timestamp: Date
    
    /// Structured data payload
    public let data: [String: AnyCodable]?
    
    /// Severity level
    public let level: Level
    
    /// Source of the event (file, module, etc.)
    public let source: String?
    
    public enum Level: String, Sendable, Codable {
        case debug
        case info
        case warning
        case error
        case critical
    }
    
    public init(
        type: String,
        message: String,
        level: Level = .info,
        data: [String: Any]? = nil,
        source: String? = nil
    ) {
        self.type = type
        self.message = message
        self.timestamp = Date()
        self.level = level
        self.source = source
        self.data = data?.mapValues { AnyCodable($0) }
    }
    
    /// Convert to JSON string
    public func toJSON(pretty: Bool = false) -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        
        if let data = try? encoder.encode(self),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
}

/// Type-erased Codable wrapper for Any values
public struct AnyCodable: Sendable, Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map(\.value)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues(\.value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encode(String(describing: value))
        }
    }
}

/// Event emitter for structured output
public actor EventEmitter {
    
    public typealias EventHandler = @Sendable (Event) -> Void
    
    private var handlers: [EventHandler] = []
    private var history: [Event] = []
    private let maxHistory: Int
    
    public init(maxHistory: Int = 1000) {
        self.maxHistory = maxHistory
    }
    
    /// Add an event handler
    public func onEvent(_ handler: @escaping EventHandler) {
        handlers.append(handler)
    }
    
    /// Emit an event
    public func emit(_ event: Event) {
        history.append(event)
        if history.count > maxHistory {
            history.removeFirst()
        }
        
        for handler in handlers {
            handler(event)
        }
    }
    
    /// Emit a simple event
    public func emit(
        type: String,
        message: String,
        level: Event.Level = .info,
        data: [String: Any]? = nil
    ) {
        emit(Event(type: type, message: message, level: level, data: data))
    }
    
    /// Get recent events
    public func recentEvents(count: Int = 100) -> [Event] {
        Array(history.suffix(count))
    }
    
    /// Get events of a specific type
    public func events(ofType type: String) -> [Event] {
        history.filter { $0.type == type }
    }
    
    /// Clear history
    public func clearHistory() {
        history.removeAll()
    }
}

// MARK: - Console Event Integration

public extension Console {
    
    /// Emit a structured event
    func emit(
        _ type: String,
        message: String,
        level: Event.Level = .info,
        data: [String: Any]? = nil
    ) {
        let event = Event(type: type, message: message, level: level, data: data)
        
        // If JSON output mode, print JSON
        // Otherwise print rich formatted
        switch config?.format ?? .rich {
        case .json:
            Swift.print(event.toJSON())
        case .ndjson:
            Swift.print(event.toJSON(pretty: false))
        case .plain:
            let prefix = level == .error ? "ERROR" : level == .warning ? "WARN" : "INFO"
            Swift.print("[\(prefix)] \(type): \(message)")
        case .rich:
            // Rich formatted output
            let icon: String
            let color: Color
            switch level {
            case .debug: icon = "🔍"; color = .brightBlack
            case .info: icon = "ℹ️"; color = .blue
            case .warning: icon = "⚠️"; color = .yellow
            case .error: icon = "❌"; color = .red
            case .critical: icon = "🚨"; color = .brightRed
            }
            
            var text = Text()
            text.append("\(icon) ", style: .none)
            text.append("[\(type)] ", style: Style(foreground: color, bold: true))
            text.append(message, style: .none)
            
            if let data = data, !data.isEmpty {
                text.append(" ", style: .none)
                text.append(String(describing: data), style: Style(foreground: .brightBlack))
            }
            
            print(text)
        }
    }
    
    /// Emit a progress event
    func emitProgress(
        task: String,
        completed: Double,
        total: Double,
        message: String? = nil
    ) {
        emit(
            "progress",
            message: message ?? "Processing \(task)",
            data: [
                "task": task,
                "completed": completed,
                "total": total,
                "percentage": total > 0 ? (completed / total) * 100 : 0
            ]
        )
    }
    
    /// Emit a task completion event
    func emitComplete(task: String, duration: Duration? = nil, data: [String: Any]? = nil) {
        var eventData: [String: Any] = data ?? [:]
        eventData["task"] = task
        if let duration = duration {
            eventData["duration_ms"] = duration.components.seconds * 1000 + Int64(duration.components.attoseconds / 1_000_000_000_000_000)
        }
        
        emit("complete", message: "Completed: \(task)", data: eventData)
    }
}

/// Private storage for console config
private var consoleConfigKey: UInt8 = 0

public extension Console {
    /// Configuration for this console
    var config: ConsoleConfig? {
        get {
            objc_getAssociatedObject(self, &consoleConfigKey) as? ConsoleConfig
        }
        set {
            objc_setAssociatedObject(self, &consoleConfigKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Create a console with specific configuration
    convenience init(config: ConsoleConfig) {
        self.init()
        self.config = config
    }
}
