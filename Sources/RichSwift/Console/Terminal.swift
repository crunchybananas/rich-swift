#if os(Windows)
import WinSDK
#else
import Foundation
#endif

/// Provides information about and interaction with the terminal
public struct Terminal: Sendable {
    /// Shared terminal instance
    public static let shared = Terminal()
    
    private init() {}
    
    /// Check if stdout is connected to a terminal (TTY)
    public var isTerminal: Bool {
        #if os(Windows)
        return _isatty(_fileno(stdout)) != 0
        #else
        return isatty(STDOUT_FILENO) == 1
        #endif
    }
    
    /// Check if the terminal supports colors
    public var supportsColor: Bool {
        guard isTerminal else { return false }
        
        // Check common environment variables
        if let colorTerm = ProcessInfo.processInfo.environment["COLORTERM"] {
            if colorTerm == "truecolor" || colorTerm == "24bit" {
                return true
            }
        }
        
        if let term = ProcessInfo.processInfo.environment["TERM"] {
            let colorTerms = ["xterm", "xterm-256color", "screen", "screen-256color", 
                             "vt100", "ansi", "linux", "rxvt", "cygwin"]
            for colorTerm in colorTerms {
                if term.contains(colorTerm) {
                    return true
                }
            }
        }
        
        // Check for NO_COLOR (standard for disabling color)
        if ProcessInfo.processInfo.environment["NO_COLOR"] != nil {
            return false
        }
        
        // Check FORCE_COLOR
        if ProcessInfo.processInfo.environment["FORCE_COLOR"] != nil {
            return true
        }
        
        #if os(macOS)
        // macOS Terminal.app and iTerm2 support colors
        return true
        #else
        return false
        #endif
    }
    
    /// Check if the terminal supports true color (24-bit)
    public var supportsTrueColor: Bool {
        guard supportsColor else { return false }
        
        if let colorTerm = ProcessInfo.processInfo.environment["COLORTERM"] {
            return colorTerm == "truecolor" || colorTerm == "24bit"
        }
        
        if let term = ProcessInfo.processInfo.environment["TERM"] {
            return term.contains("256color") || term.contains("24bit")
        }
        
        return false
    }
    
    /// Get the terminal width in columns
    public var width: Int {
        #if os(Windows)
        var csbi = CONSOLE_SCREEN_BUFFER_INFO()
        if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi) {
            return Int(csbi.srWindow.Right - csbi.srWindow.Left + 1)
        }
        return 80
        #else
        var size = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 {
            return Int(size.ws_col)
        }
        
        // Try COLUMNS environment variable
        if let columns = ProcessInfo.processInfo.environment["COLUMNS"],
           let width = Int(columns) {
            return width
        }
        
        return 80 // Default fallback
        #endif
    }
    
    /// Get the terminal height in rows
    public var height: Int {
        #if os(Windows)
        var csbi = CONSOLE_SCREEN_BUFFER_INFO()
        if GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi) {
            return Int(csbi.srWindow.Bottom - csbi.srWindow.Top + 1)
        }
        return 24
        #else
        var size = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 {
            return Int(size.ws_row)
        }
        
        // Try LINES environment variable
        if let lines = ProcessInfo.processInfo.environment["LINES"],
           let height = Int(lines) {
            return height
        }
        
        return 24 // Default fallback
        #endif
    }
    
    /// Get the terminal size as (width, height)
    public var size: (width: Int, height: Int) {
        (width, height)
    }
}
