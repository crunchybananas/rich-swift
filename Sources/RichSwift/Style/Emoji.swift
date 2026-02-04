import Foundation

/// Emoji support with shortcode names and fallbacks
public struct Emoji {
    /// Get emoji by shortcode name
    public static func get(_ name: String) -> String {
        if let emoji = emojiMap[name.lowercased()] {
            return emoji
        }
        // Check with colons stripped
        let stripped = name.trimmingCharacters(in: CharacterSet(charactersIn: ":"))
        return emojiMap[stripped.lowercased()] ?? ":\(stripped):"
    }
    
    /// Replace :emoji: codes in text with actual emojis
    public static func emojify(_ text: String) -> String {
        var result = text
        let pattern = #":([a-zA-Z0-9_+-]+):"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, range: range)
        
        // Process matches in reverse to maintain string indices
        for match in matches.reversed() {
            guard let matchRange = Range(match.range, in: result),
                  let codeRange = Range(match.range(at: 1), in: result) else {
                continue
            }
            
            let code = String(result[codeRange])
            if let emoji = emojiMap[code.lowercased()] {
                result.replaceSubrange(matchRange, with: emoji)
            }
        }
        
        return result
    }
    
    /// Common emoji shortcodes
    private static let emojiMap: [String: String] = [
        // Faces
        "smile": "😊",
        "grin": "😁",
        "joy": "😂",
        "rofl": "🤣",
        "blush": "😊",
        "wink": "😉",
        "heart_eyes": "😍",
        "sunglasses": "😎",
        "thinking": "🤔",
        "neutral_face": "😐",
        "expressionless": "😑",
        "unamused": "😒",
        "sweat": "😓",
        "pensive": "😔",
        "confused": "😕",
        "disappointed": "😞",
        "worried": "😟",
        "angry": "😠",
        "rage": "😡",
        "cry": "😢",
        "sob": "😭",
        "scream": "😱",
        "skull": "💀",
        
        // Hands
        "wave": "👋",
        "raised_hand": "✋",
        "ok_hand": "👌",
        "thumbsup": "👍",
        "+1": "👍",
        "thumbsdown": "👎",
        "-1": "👎",
        "clap": "👏",
        "pray": "🙏",
        "muscle": "💪",
        "point_up": "☝️",
        "point_down": "👇",
        "point_left": "👈",
        "point_right": "👉",
        
        // Hearts
        "heart": "❤️",
        "red_heart": "❤️",
        "orange_heart": "🧡",
        "yellow_heart": "💛",
        "green_heart": "💚",
        "blue_heart": "💙",
        "purple_heart": "💜",
        "black_heart": "🖤",
        "white_heart": "🤍",
        "broken_heart": "💔",
        "sparkling_heart": "💖",
        
        // Status/Symbols
        "check": "✅",
        "white_check_mark": "✅",
        "heavy_check_mark": "✔️",
        "x": "❌",
        "cross_mark": "❌",
        "warning": "⚠️",
        "exclamation": "❗",
        "question": "❓",
        "info": "ℹ️",
        "star": "⭐",
        "star2": "🌟",
        "sparkles": "✨",
        "fire": "🔥",
        "zap": "⚡",
        "boom": "💥",
        "100": "💯",
        
        // Progress
        "hourglass": "⏳",
        "hourglass_done": "⌛",
        "clock": "🕐",
        "stopwatch": "⏱️",
        "timer": "⏲️",
        
        // Weather
        "sunny": "☀️",
        "sun": "☀️",
        "cloud": "☁️",
        "rain": "🌧️",
        "rainbow": "🌈",
        "snowflake": "❄️",
        "lightning": "⚡",
        
        // Objects
        "bulb": "💡",
        "lightbulb": "💡",
        "gear": "⚙️",
        "wrench": "🔧",
        "hammer": "🔨",
        "key": "🔑",
        "lock": "🔒",
        "unlock": "🔓",
        "bell": "🔔",
        "bookmark": "🔖",
        "link": "🔗",
        "paperclip": "📎",
        "scissors": "✂️",
        "pencil": "✏️",
        "pen": "🖊️",
        "memo": "📝",
        "clipboard": "📋",
        "calendar": "📅",
        "chart": "📊",
        "bar_chart": "📊",
        "chart_with_upwards_trend": "📈",
        "chart_with_downwards_trend": "📉",
        
        // Files/Folders
        "file_folder": "📁",
        "folder": "📁",
        "open_file_folder": "📂",
        "file": "📄",
        "page_facing_up": "📄",
        "package": "📦",
        "inbox": "📥",
        "outbox": "📤",
        
        // Communication
        "email": "📧",
        "envelope": "✉️",
        "speech_balloon": "💬",
        "thought_balloon": "💭",
        "phone": "📱",
        "computer": "💻",
        "desktop": "🖥️",
        "keyboard": "⌨️",
        
        // Arrows
        "arrow_up": "⬆️",
        "arrow_down": "⬇️",
        "arrow_left": "⬅️",
        "arrow_right": "➡️",
        "arrow_upper_right": "↗️",
        "arrow_lower_right": "↘️",
        "arrow_lower_left": "↙️",
        "arrow_upper_left": "↖️",
        "arrows_counterclockwise": "🔄",
        "leftwards_arrow_with_hook": "↩️",
        "arrow_right_hook": "↪️",
        
        // Tech
        "bug": "🐛",
        "robot": "🤖",
        "rocket": "🚀",
        "satellite": "🛰️",
        "telescope": "🔭",
        "microscope": "🔬",
        "dna": "🧬",
        "atom": "⚛️",
        
        // Nature
        "tree": "🌳",
        "evergreen_tree": "🌲",
        "palm_tree": "🌴",
        "seedling": "🌱",
        "flower": "🌸",
        "rose": "🌹",
        "sunflower": "🌻",
        "leaf": "🍃",
        "fallen_leaf": "🍂",
        "mushroom": "🍄",
        
        // Animals
        "dog": "🐕",
        "cat": "🐈",
        "mouse": "🐁",
        "rabbit": "🐇",
        "fox": "🦊",
        "bear": "🐻",
        "panda": "🐼",
        "koala": "🐨",
        "tiger": "🐯",
        "lion": "🦁",
        "unicorn": "🦄",
        "snake": "🐍",
        "bird": "🐦",
        "penguin": "🐧",
        "butterfly": "🦋",
        "bee": "🐝",
        "ant": "🐜",
        "spider": "🕷️",
        "crab": "🦀",
        "fish": "🐟",
        "whale": "🐳",
        "dolphin": "🐬",
        "octopus": "🐙",
        
        // Food
        "apple": "🍎",
        "green_apple": "🍏",
        "banana": "🍌",
        "orange": "🍊",
        "lemon": "🍋",
        "grapes": "🍇",
        "watermelon": "🍉",
        "strawberry": "🍓",
        "peach": "🍑",
        "pizza": "🍕",
        "burger": "🍔",
        "fries": "🍟",
        "taco": "🌮",
        "sushi": "🍣",
        "coffee": "☕",
        "tea": "🍵",
        "beer": "🍺",
        "wine": "🍷",
        "cake": "🍰",
        "cookie": "🍪",
        "chocolate": "🍫",
        "candy": "🍬",
        "ice_cream": "🍦",
        
        // Flags/Symbols
        "flag": "🚩",
        "checkered_flag": "🏁",
        "triangular_flag": "🚩",
        "white_flag": "🏳️",
        "rainbow_flag": "🏳️‍🌈",
        
        // Misc
        "tada": "🎉",
        "party": "🎉",
        "confetti": "🎊",
        "gift": "🎁",
        "trophy": "🏆",
        "medal": "🏅",
        "crown": "👑",
        "gem": "💎",
        "moneybag": "💰",
        "dollar": "💵",
        "credit_card": "💳",
    ]
}

// MARK: - String Extension

extension String {
    /// Replace emoji shortcodes with actual emojis
    public var emojified: String {
        Emoji.emojify(self)
    }
}

// MARK: - Text Extension

extension Text {
    /// Create text with emoji codes replaced
    public init(emojified string: String, style: Style = .none) {
        self.init(Emoji.emojify(string), style: style)
    }
}
