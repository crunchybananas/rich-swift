import Foundation

// MARK: - Prompt Utilities

extension Console {
    /// Prompt the user for text input
    public func prompt(
        _ message: String,
        default defaultValue: String? = nil,
        style: Style = Style(foreground: .cyan)
    ) -> String {
        var text = Text()
        text.append(message, style: style)
        
        if let defaultValue = defaultValue {
            text.append(" [\(defaultValue)]", style: Style(foreground: .brightBlack))
        }
        text.append(": ", style: style)
        
        write(text.render(forTerminal: useColor))
        
        guard let input = readLine() else {
            return defaultValue ?? ""
        }
        
        return input.isEmpty ? (defaultValue ?? "") : input
    }
    
    /// Prompt for a password (hidden input)
    public func password(
        _ message: String,
        style: Style = Style(foreground: .cyan)
    ) -> String {
        var text = Text()
        text.append(message, style: style)
        text.append(": ", style: style)
        
        write(text.render(forTerminal: useColor))
        
        // Disable echo
        var oldTermios = termios()
        tcgetattr(STDIN_FILENO, &oldTermios)
        var newTermios = oldTermios
        newTermios.c_lflag &= ~tcflag_t(ECHO)
        tcsetattr(STDIN_FILENO, TCSANOW, &newTermios)
        
        defer {
            // Restore echo
            tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios)
            write("\n")
        }
        
        return readLine() ?? ""
    }
    
    /// Prompt for confirmation (yes/no)
    public func confirm(
        _ message: String,
        default defaultValue: Bool = false,
        style: Style = Style(foreground: .cyan)
    ) -> Bool {
        let hint = defaultValue ? "[Y/n]" : "[y/N]"
        
        var text = Text()
        text.append(message, style: style)
        text.append(" \(hint) ", style: Style(foreground: .brightBlack))
        
        write(text.render(forTerminal: useColor))
        
        guard let input = readLine()?.lowercased() else {
            return defaultValue
        }
        
        if input.isEmpty {
            return defaultValue
        }
        
        return input == "y" || input == "yes" || input == "true" || input == "1"
    }
    
    /// Prompt for integer input
    public func promptInt(
        _ message: String,
        default defaultValue: Int? = nil,
        min: Int? = nil,
        max: Int? = nil,
        style: Style = Style(foreground: .cyan)
    ) -> Int? {
        while true {
            var text = Text()
            text.append(message, style: style)
            
            if let defaultValue = defaultValue {
                text.append(" [\(defaultValue)]", style: Style(foreground: .brightBlack))
            }
            
            if min != nil || max != nil {
                let minStr = min.map { String($0) } ?? ""
                let maxStr = max.map { String($0) } ?? ""
                text.append(" (\(minStr)..\(maxStr))", style: Style(foreground: .brightBlack))
            }
            
            text.append(": ", style: style)
            
            write(text.render(forTerminal: useColor))
            
            guard let input = readLine() else {
                return defaultValue
            }
            
            if input.isEmpty {
                return defaultValue
            }
            
            guard let value = Int(input) else {
                print("[bold red]Error:[/] Please enter a valid number")
                continue
            }
            
            if let min = min, value < min {
                print("[bold red]Error:[/] Value must be at least \(min)")
                continue
            }
            
            if let max = max, value > max {
                print("[bold red]Error:[/] Value must be at most \(max)")
                continue
            }
            
            return value
        }
    }
    
    /// Display a selection menu and return the chosen item
    public func select<T: CustomStringConvertible>(
        _ message: String,
        choices: [T],
        default defaultIndex: Int = 0,
        style: Style = Style(foreground: .cyan)
    ) -> T? {
        guard !choices.isEmpty else { return nil }
        
        var selectedIndex = min(defaultIndex, choices.count - 1)
        
        // Check if we have a real terminal for interactive mode
        guard terminal.isTerminal else {
            // Fallback to numbered list
            return selectNumbered(message, choices: choices, default: defaultIndex, style: style)
        }
        
        // Hide cursor
        write("\u{001B}[?25l")
        
        // Save cursor position
        write("\u{001B}7")
        
        defer {
            // Show cursor
            write("\u{001B}[?25h")
        }
        
        // Enter raw mode
        var oldTermios = termios()
        tcgetattr(STDIN_FILENO, &oldTermios)
        var newTermios = oldTermios
        newTermios.c_lflag &= ~tcflag_t(ICANON | ECHO)
        newTermios.c_cc.0 = 1  // VMIN
        newTermios.c_cc.1 = 0  // VTIME
        tcsetattr(STDIN_FILENO, TCSANOW, &newTermios)
        
        defer {
            tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios)
        }
        
        func renderMenu() {
            // Restore cursor position
            write("\u{001B}8")
            
            // Clear from cursor to end of screen
            write("\u{001B}[J")
            
            var text = Text()
            text.append(message, style: style)
            text.append("\n")
            
            for (index, choice) in choices.enumerated() {
                if index == selectedIndex {
                    text.append("❯ ", style: Style(foreground: .green, bold: true))
                    text.append(choice.description, style: Style(foreground: .green, bold: true))
                } else {
                    text.append("  ", style: .none)
                    text.append(choice.description, style: Style(foreground: .brightBlack))
                }
                text.append("\n")
            }
            
            text.append("\n", style: .none)
            text.append("(↑/↓ to move, Enter to select, q to cancel)", style: Style(foreground: .brightBlack))
            
            write(text.render(forTerminal: useColor))
        }
        
        renderMenu()
        
        while true {
            var char: UInt8 = 0
            let bytesRead = read(STDIN_FILENO, &char, 1)
            
            guard bytesRead == 1 else { continue }
            
            switch char {
            case 0x1B: // Escape sequence
                var seq: [UInt8] = [0, 0]
                _ = read(STDIN_FILENO, &seq, 2)
                
                if seq[0] == 0x5B { // [
                    switch seq[1] {
                    case 0x41: // Up arrow
                        selectedIndex = (selectedIndex - 1 + choices.count) % choices.count
                        renderMenu()
                    case 0x42: // Down arrow
                        selectedIndex = (selectedIndex + 1) % choices.count
                        renderMenu()
                    default:
                        break
                    }
                }
                
            case 0x0D, 0x0A: // Enter
                // Clear menu
                write("\u{001B}8")
                write("\u{001B}[J")
                
                // Show selection
                var result = Text()
                result.append(message, style: style)
                result.append(" ")
                result.append(choices[selectedIndex].description, style: Style(foreground: .green))
                result.append("\n")
                write(result.render(forTerminal: useColor))
                
                return choices[selectedIndex]
                
            case 0x71, 0x03: // q or Ctrl+C
                // Clear menu
                write("\u{001B}8")
                write("\u{001B}[J")
                return nil
                
            case 0x6B, 0x70: // k or p (vim-like up)
                selectedIndex = (selectedIndex - 1 + choices.count) % choices.count
                renderMenu()
                
            case 0x6A, 0x6E: // j or n (vim-like down)
                selectedIndex = (selectedIndex + 1) % choices.count
                renderMenu()
                
            default:
                break
            }
        }
    }
    
    /// Fallback selection for non-interactive terminals
    private func selectNumbered<T: CustomStringConvertible>(
        _ message: String,
        choices: [T],
        default defaultIndex: Int,
        style: Style
    ) -> T? {
        print(message, style: style)
        
        for (index, choice) in choices.enumerated() {
            let marker = index == defaultIndex ? ">" : " "
            print("\(marker) \(index + 1). \(choice.description)")
        }
        
        let selected = promptInt(
            "Enter number",
            default: defaultIndex + 1,
            min: 1,
            max: choices.count
        )
        
        guard let idx = selected else { return nil }
        return choices[idx - 1]
    }
    
    /// Multiple selection menu
    public func multiSelect<T: CustomStringConvertible>(
        _ message: String,
        choices: [T],
        defaults: Set<Int> = [],
        style: Style = Style(foreground: .cyan)
    ) -> [T] {
        guard !choices.isEmpty else { return [] }
        guard terminal.isTerminal else {
            // Fallback
            return multiSelectNumbered(message, choices: choices, defaults: defaults, style: style)
        }
        
        var selectedIndices = defaults
        var cursorIndex = 0
        
        // Hide cursor
        write("\u{001B}[?25l")
        write("\u{001B}7")
        
        defer {
            write("\u{001B}[?25h")
        }
        
        var oldTermios = termios()
        tcgetattr(STDIN_FILENO, &oldTermios)
        var newTermios = oldTermios
        newTermios.c_lflag &= ~tcflag_t(ICANON | ECHO)
        newTermios.c_cc.0 = 1
        newTermios.c_cc.1 = 0
        tcsetattr(STDIN_FILENO, TCSANOW, &newTermios)
        
        defer {
            tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios)
        }
        
        func renderMenu() {
            write("\u{001B}8")
            write("\u{001B}[J")
            
            var text = Text()
            text.append(message, style: style)
            text.append("\n")
            
            for (index, choice) in choices.enumerated() {
                let isSelected = selectedIndices.contains(index)
                let isCursor = index == cursorIndex
                
                let checkbox = isSelected ? "◉" : "○"
                let checkStyle = isSelected ? Style(foreground: .green) : Style(foreground: .brightBlack)
                
                if isCursor {
                    text.append("❯ ", style: Style(foreground: .cyan))
                } else {
                    text.append("  ", style: .none)
                }
                
                text.append(checkbox, style: checkStyle)
                text.append(" ", style: .none)
                
                let textStyle = isCursor ? Style(bold: true) : .none
                text.append(choice.description, style: textStyle)
                text.append("\n")
            }
            
            text.append("\n", style: .none)
            text.append("(↑/↓ move, Space toggle, Enter confirm, q cancel)", style: Style(foreground: .brightBlack))
            
            write(text.render(forTerminal: useColor))
        }
        
        renderMenu()
        
        while true {
            var char: UInt8 = 0
            guard read(STDIN_FILENO, &char, 1) == 1 else { continue }
            
            switch char {
            case 0x1B:
                var seq: [UInt8] = [0, 0]
                _ = read(STDIN_FILENO, &seq, 2)
                
                if seq[0] == 0x5B {
                    switch seq[1] {
                    case 0x41: // Up
                        cursorIndex = (cursorIndex - 1 + choices.count) % choices.count
                        renderMenu()
                    case 0x42: // Down
                        cursorIndex = (cursorIndex + 1) % choices.count
                        renderMenu()
                    default:
                        break
                    }
                }
                
            case 0x20: // Space - toggle
                if selectedIndices.contains(cursorIndex) {
                    selectedIndices.remove(cursorIndex)
                } else {
                    selectedIndices.insert(cursorIndex)
                }
                renderMenu()
                
            case 0x0D, 0x0A: // Enter
                write("\u{001B}8")
                write("\u{001B}[J")
                
                var result = Text()
                result.append(message, style: style)
                result.append(" ")
                let selectedChoices = selectedIndices.sorted().map { choices[$0].description }
                result.append(selectedChoices.joined(separator: ", "), style: Style(foreground: .green))
                result.append("\n")
                write(result.render(forTerminal: useColor))
                
                return selectedIndices.sorted().map { choices[$0] }
                
            case 0x71, 0x03: // q or Ctrl+C
                write("\u{001B}8")
                write("\u{001B}[J")
                return []
                
            default:
                break
            }
        }
    }
    
    private func multiSelectNumbered<T: CustomStringConvertible>(
        _ message: String,
        choices: [T],
        defaults: Set<Int>,
        style: Style
    ) -> [T] {
        print(message, style: style)
        
        for (index, choice) in choices.enumerated() {
            let marker = defaults.contains(index) ? "[x]" : "[ ]"
            print("\(marker) \(index + 1). \(choice.description)")
        }
        
        let input = prompt("Enter numbers separated by commas")
        let numbers = input.split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 >= 1 && $0 <= choices.count }
            .map { $0 - 1 }
        
        return numbers.map { choices[$0] }
    }
    
    // MARK: - Private Helpers
    
    private func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            FileHandle.standardOutput.write(data)
        }
    }
}
