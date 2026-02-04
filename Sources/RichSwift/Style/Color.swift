import Foundation

/// Represents a color for terminal output
public enum Color: Equatable, Sendable {
    // Standard colors (3-bit)
    case black
    case red
    case green
    case yellow
    case blue
    case magenta
    case cyan
    case white
    
    // Bright variants
    case brightBlack
    case brightRed
    case brightGreen
    case brightYellow
    case brightBlue
    case brightMagenta
    case brightCyan
    case brightWhite
    
    // 256 color palette
    case palette(UInt8)
    
    // True color (24-bit RGB)
    case rgb(r: UInt8, g: UInt8, b: UInt8)
    
    // Hex color
    case hex(String)
    
    /// The default/reset color
    case `default`
    
    /// ANSI code for foreground color
    var foregroundCode: String {
        switch self {
        case .black: return "30"
        case .red: return "31"
        case .green: return "32"
        case .yellow: return "33"
        case .blue: return "34"
        case .magenta: return "35"
        case .cyan: return "36"
        case .white: return "37"
        case .brightBlack: return "90"
        case .brightRed: return "91"
        case .brightGreen: return "92"
        case .brightYellow: return "93"
        case .brightBlue: return "94"
        case .brightMagenta: return "95"
        case .brightCyan: return "96"
        case .brightWhite: return "97"
        case .palette(let n): return "38;5;\(n)"
        case .rgb(let r, let g, let b): return "38;2;\(r);\(g);\(b)"
        case .hex(let hex): 
            let rgb = Color.hexToRGB(hex)
            return "38;2;\(rgb.r);\(rgb.g);\(rgb.b)"
        case .default: return "39"
        }
    }
    
    /// ANSI code for background color
    var backgroundCode: String {
        switch self {
        case .black: return "40"
        case .red: return "41"
        case .green: return "42"
        case .yellow: return "43"
        case .blue: return "44"
        case .magenta: return "45"
        case .cyan: return "46"
        case .white: return "47"
        case .brightBlack: return "100"
        case .brightRed: return "101"
        case .brightGreen: return "102"
        case .brightYellow: return "103"
        case .brightBlue: return "104"
        case .brightMagenta: return "105"
        case .brightCyan: return "106"
        case .brightWhite: return "107"
        case .palette(let n): return "48;5;\(n)"
        case .rgb(let r, let g, let b): return "48;2;\(r);\(g);\(b)"
        case .hex(let hex):
            let rgb = Color.hexToRGB(hex)
            return "48;2;\(rgb.r);\(rgb.g);\(rgb.b)"
        case .default: return "49"
        }
    }
    
    /// Convert hex string to RGB values
    private static func hexToRGB(_ hex: String) -> (r: UInt8, g: UInt8, b: UInt8) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        return (
            r: UInt8((rgb & 0xFF0000) >> 16),
            g: UInt8((rgb & 0x00FF00) >> 8),
            b: UInt8(rgb & 0x0000FF)
        )
    }
}

// MARK: - Named Color Lookup

extension Color {
    /// Create a color from a name string
    public static func named(_ name: String) -> Color? {
        switch name.lowercased() {
        case "black": return .black
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        case "blue": return .blue
        case "magenta": return .magenta
        case "cyan": return .cyan
        case "white": return .white
        case "bright_black", "brightblack", "grey", "gray": return .brightBlack
        case "bright_red", "brightred": return .brightRed
        case "bright_green", "brightgreen": return .brightGreen
        case "bright_yellow", "brightyellow": return .brightYellow
        case "bright_blue", "brightblue": return .brightBlue
        case "bright_magenta", "brightmagenta": return .brightMagenta
        case "bright_cyan", "brightcyan": return .brightCyan
        case "bright_white", "brightwhite": return .brightWhite
        default:
            // Check if it's a hex color
            if name.hasPrefix("#") {
                return .hex(name)
            }
            return nil
        }
    }
}
