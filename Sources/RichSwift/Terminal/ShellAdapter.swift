import Foundation

/// Shell compatibility layer that intercepts and adapts commands between shell dialects
public struct ShellAdapter: Sendable {
    
    public enum ShellType: String, Sendable {
        case bash
        case zsh
        case sh
        
        public static var current: ShellType {
            let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
            if shell.contains("zsh") { return .zsh }
            if shell.contains("bash") { return .bash }
            return .sh
        }
    }
    
    public let targetShell: ShellType
    
    public init(targetShell: ShellType = .current) {
        self.targetShell = targetShell
    }
    
    // MARK: - Command Adaptation
    
    /// Adapt a command for the target shell
    public func adapt(_ command: String) -> AdaptedCommand {
        var adapted = command
        var changes: [CommandChange] = []
        
        // Apply transformations based on target shell
        if targetShell == .zsh {
            (adapted, changes) = bashToZsh(adapted)
        } else if targetShell == .bash {
            (adapted, changes) = zshToBash(adapted)
        }
        
        return AdaptedCommand(
            original: command,
            adapted: adapted,
            changes: changes,
            targetShell: targetShell
        )
    }
    
    // MARK: - Bash to Zsh Transformations
    
    private func bashToZsh(_ command: String) -> (String, [CommandChange]) {
        var result = command
        var changes: [CommandChange] = []
        
        // 1. Fix $'...' ANSI-C quoting (zsh handles differently)
        if let (newCmd, change) = fixAnsiCQuoting(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 2. Fix array syntax: ${array[@]} works but ${array[*]} differs
        if let (newCmd, change) = fixArrayExpansion(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 3. Fix echo -e (zsh echo handles escapes by default)
        if let (newCmd, change) = fixEchoEscape(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 4. Fix read command differences
        if let (newCmd, change) = fixReadCommand(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 5. Fix [[ ]] regex matching (=~ behaves differently)
        if let (newCmd, change) = fixRegexMatching(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 6. Fix source vs . (both work but precedence differs)
        if let (newCmd, change) = fixSourceCommand(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 7. Fix command substitution with special chars
        if let (newCmd, change) = fixCommandSubstitution(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 8. Fix here-string quoting
        if let (newCmd, change) = fixHereString(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 9. Fix brace expansion differences
        if let (newCmd, change) = fixBraceExpansion(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 10. Fix function definition syntax
        if let (newCmd, change) = fixFunctionSyntax(result) {
            result = newCmd
            changes.append(change)
        }
        
        return (result, changes)
    }
    
    private func zshToBash(_ command: String) -> (String, [CommandChange]) {
        var result = command
        var changes: [CommandChange] = []
        
        // Zsh-specific features that need bash equivalents
        
        // 1. Fix glob qualifiers (zsh-only)
        if let (newCmd, change) = removeGlobQualifiers(result) {
            result = newCmd
            changes.append(change)
        }
        
        // 2. Fix parameter expansion flags
        if let (newCmd, change) = fixParameterFlags(result) {
            result = newCmd
            changes.append(change)
        }
        
        return (result, changes)
    }
    
    // MARK: - Specific Transformations
    
    private func fixAnsiCQuoting(_ cmd: String) -> (String, CommandChange)? {
        // $'string' with escape sequences - zsh needs different handling for some escapes
        let pattern = #"\$'([^'\\]|\\.)*'"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              regex.firstMatch(in: cmd, range: NSRange(cmd.startIndex..., in: cmd)) != nil else {
            return nil
        }
        
        // For most cases, $'...' works in zsh, but we should ensure proper escaping
        return nil // Usually compatible, but flag for review
    }
    
    private func fixArrayExpansion(_ cmd: String) -> (String, CommandChange)? {
        // Bash: ${arr[*]} joins with first char of IFS
        // Zsh: ${arr[*]} joins with spaces regardless of IFS
        let pattern = #"\$\{(\w+)\[\*\]\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(cmd.startIndex..., in: cmd)
        guard regex.firstMatch(in: cmd, range: range) != nil else { return nil }
        
        // Convert to ${(j: :)arr} for explicit join in zsh
        let result = regex.stringByReplacingMatches(
            in: cmd,
            range: range,
            withTemplate: #"${\(j: :)$1}"#
        )
        
        return (result, CommandChange(
            type: .arrayExpansion,
            description: "Converted ${arr[*]} to zsh explicit join syntax",
            original: cmd,
            replacement: result
        ))
    }
    
    private func fixEchoEscape(_ cmd: String) -> (String, CommandChange)? {
        // Bash: echo -e "text\n" enables escape interpretation
        // Zsh: echo interprets escapes by default, -e is not needed
        guard cmd.contains("echo -e ") else { return nil }
        
        let result = cmd.replacingOccurrences(of: "echo -e ", with: "echo ")
        
        return (result, CommandChange(
            type: .echoEscape,
            description: "Removed -e flag from echo (zsh interprets escapes by default)",
            original: "echo -e",
            replacement: "echo"
        ))
    }
    
    private func fixReadCommand(_ cmd: String) -> (String, CommandChange)? {
        // Bash: read -p "prompt" var
        // Zsh: read "var?prompt" or use vared
        let pattern = #"read\s+-p\s+([\"'][^\"']*[\"'])\s+(\w+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(cmd.startIndex..., in: cmd)
        guard let match = regex.firstMatch(in: cmd, range: range) else { return nil }
        
        // Extract prompt and variable
        guard let promptRange = Range(match.range(at: 1), in: cmd),
              let varRange = Range(match.range(at: 2), in: cmd) else { return nil }
        
        let prompt = String(cmd[promptRange]).trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
        let variable = String(cmd[varRange])
        
        let result = cmd.replacingCharacters(
            in: Range(match.range, in: cmd)!,
            with: "read \"\(variable)?\(prompt)\""
        )
        
        return (result, CommandChange(
            type: .readCommand,
            description: "Converted bash read -p syntax to zsh read var?prompt syntax",
            original: String(cmd[Range(match.range, in: cmd)!]),
            replacement: "read \"\(variable)?\(prompt)\""
        ))
    }
    
    private func fixRegexMatching(_ cmd: String) -> (String, CommandChange)? {
        // Bash: [[ $var =~ pattern ]] - pattern is unquoted
        // Zsh: [[ $var =~ pattern ]] - may need setopt RE_MATCH_PCRE
        guard cmd.contains("=~") else { return nil }
        
        // Check if it's a complex regex that might need PCRE
        let complexPatterns = ["(?", "\\d", "\\w", "\\s", "+?", "*?"]
        let needsPCRE = complexPatterns.contains { cmd.contains($0) }
        
        if needsPCRE {
            let result = "setopt RE_MATCH_PCRE 2>/dev/null; " + cmd
            return (result, CommandChange(
                type: .regexMatching,
                description: "Added setopt RE_MATCH_PCRE for PCRE regex compatibility",
                original: cmd,
                replacement: result
            ))
        }
        
        return nil
    }
    
    private func fixSourceCommand(_ cmd: String) -> (String, CommandChange)? {
        // Both work, but be explicit for clarity
        return nil
    }
    
    private func fixCommandSubstitution(_ cmd: String) -> (String, CommandChange)? {
        // Backtick command substitution: `cmd`
        // Convert to $(cmd) for consistency
        guard cmd.contains("`") else { return nil }
        
        // Simple backtick replacement (doesn't handle nested)
        var result = cmd
        var inBacktick = false
        var start = result.startIndex
        var ranges: [(Range<String.Index>, String)] = []
        
        for i in result.indices {
            if result[i] == "`" {
                if inBacktick {
                    let content = String(result[result.index(after: start)..<i])
                    let endIndex = result.index(after: i)
                    ranges.append((start..<endIndex, "$(\(content))"))
                } else {
                    start = i
                }
                inBacktick.toggle()
            }
        }
        
        // Apply replacements in reverse
        for (range, replacement) in ranges.reversed() {
            result.replaceSubrange(range, with: replacement)
        }
        
        if result != cmd {
            return (result, CommandChange(
                type: .commandSubstitution,
                description: "Converted backtick command substitution to $()",
                original: cmd,
                replacement: result
            ))
        }
        
        return nil
    }
    
    private func fixHereString(_ cmd: String) -> (String, CommandChange)? {
        // <<< "string" works in both, but quoting behavior differs
        return nil
    }
    
    private func fixBraceExpansion(_ cmd: String) -> (String, CommandChange)? {
        // {1..10} works in both
        // {a,b,c} works in both
        // But zsh has more features like {1..10..2} for step
        return nil
    }
    
    private func fixFunctionSyntax(_ cmd: String) -> (String, CommandChange)? {
        // Bash: function name { } or name() { }
        // Zsh: Both work, but function keyword has different scoping
        return nil
    }
    
    private func removeGlobQualifiers(_ cmd: String) -> (String, CommandChange)? {
        // Zsh glob qualifiers like *(.) for files only
        // Need to convert to find or explicit tests in bash
        return nil
    }
    
    private func fixParameterFlags(_ cmd: String) -> (String, CommandChange)? {
        // Zsh: ${(U)var} for uppercase
        // Bash: ${var^^}
        let pattern = #"\$\{\(([UuLlC])\)(\w+)\}"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        
        let range = NSRange(cmd.startIndex..., in: cmd)
        guard let match = regex.firstMatch(in: cmd, range: range),
              let flagRange = Range(match.range(at: 1), in: cmd),
              let varRange = Range(match.range(at: 2), in: cmd) else { return nil }
        
        let flag = String(cmd[flagRange])
        let variable = String(cmd[varRange])
        
        let bashEquivalent: String
        switch flag {
        case "U": bashEquivalent = "${\(variable)^^}"  // uppercase
        case "u": bashEquivalent = "${\(variable)^}"   // capitalize first
        case "L": bashEquivalent = "${\(variable),,}"  // lowercase
        case "l": bashEquivalent = "${\(variable),}"   // lowercase first
        default: return nil
        }
        
        let result = cmd.replacingCharacters(
            in: Range(match.range, in: cmd)!,
            with: bashEquivalent
        )
        
        return (result, CommandChange(
            type: .parameterExpansion,
            description: "Converted zsh parameter flag to bash equivalent",
            original: String(cmd[Range(match.range, in: cmd)!]),
            replacement: bashEquivalent
        ))
    }
}

// MARK: - Supporting Types

public struct AdaptedCommand: Sendable {
    public let original: String
    public let adapted: String
    public let changes: [CommandChange]
    public let targetShell: ShellAdapter.ShellType
    
    public var wasModified: Bool {
        original != adapted
    }
    
    public var description: String {
        if changes.isEmpty {
            return "No changes needed"
        }
        return changes.map { "• \($0.description)" }.joined(separator: "\n")
    }
}

public struct CommandChange: Sendable {
    public enum ChangeType: String, Sendable {
        case arrayExpansion
        case echoEscape
        case readCommand
        case regexMatching
        case commandSubstitution
        case parameterExpansion
        case globQualifier
        case quoting
        case other
    }
    
    public let type: ChangeType
    public let description: String
    public let original: String
    public let replacement: String
}

// MARK: - Dangerous Command Detection

public struct CommandSanitizer: Sendable {
    
    public struct SanitizationResult: Sendable {
        public let isAllowed: Bool
        public let warnings: [String]
        public let blockedReason: String?
        public let riskLevel: RiskLevel
    }
    
    public enum RiskLevel: Int, Sendable, Comparable {
        case safe = 0
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
        
        public static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    public init() {}
    
    /// Analyze a command for safety
    public func analyze(_ command: String) -> SanitizationResult {
        var warnings: [String] = []
        var riskLevel: RiskLevel = .safe
        var blockedReason: String? = nil
        
        let lowercased = command.lowercased()
        
        // Critical: Commands that should never run automatically
        let criticalPatterns = [
            ("rm -rf /", "Attempted to delete root filesystem"),
            ("rm -rf ~", "Attempted to delete home directory"),
            ("rm -rf /*", "Attempted to delete all files"),
            (":(){:|:&};:", "Fork bomb detected"),
            ("mkfs.", "Filesystem formatting detected"),
            ("dd if=/dev/zero", "Disk overwrite detected"),
            ("chmod -R 777 /", "Dangerous permission change"),
            ("> /dev/sda", "Direct disk write detected"),
        ]
        
        for (pattern, reason) in criticalPatterns {
            if lowercased.contains(pattern.lowercased()) {
                return SanitizationResult(
                    isAllowed: false,
                    warnings: [reason],
                    blockedReason: reason,
                    riskLevel: .critical
                )
            }
        }
        
        // Critical: Piped remote script execution (curl/wget ... | sh/bash)
        let pipedScriptPatterns = [
            (#"curl\s+.+\|\s*sh"#, "Piped remote script execution (curl | sh)"),
            (#"curl\s+.+\|\s*bash"#, "Piped remote script execution (curl | bash)"),
            (#"wget\s+.+\|\s*sh"#, "Piped remote script execution (wget | sh)"),
            (#"wget\s+.+\|\s*bash"#, "Piped remote script execution (wget | bash)"),
        ]
        
        for (pattern, reason) in pipedScriptPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               regex.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)) != nil {
                return SanitizationResult(
                    isAllowed: false,
                    warnings: [reason],
                    blockedReason: reason,
                    riskLevel: .critical
                )
            }
        }
        
        // High risk patterns
        let highRiskPatterns = [
            ("sudo rm", "Elevated privilege file deletion"),
            ("sudo chmod", "Elevated privilege permission change"),
            ("sudo chown", "Elevated privilege ownership change"),
            ("> /etc/", "Writing to system config"),
            ("rm -rf", "Recursive force deletion"),
            ("| sh", "Piping to shell"),
            ("| bash", "Piping to shell"),
            ("eval ", "Dynamic code execution"),
            ("$( )", "Command substitution"),
        ]
        
        for (pattern, warning) in highRiskPatterns {
            if lowercased.contains(pattern.lowercased()) {
                warnings.append(warning)
                riskLevel = max(riskLevel, .high)
            }
        }
        
        // Medium risk patterns
        let mediumRiskPatterns = [
            ("sudo ", "Uses elevated privileges"),
            ("rm ", "File deletion"),
            ("mv ", "File move/rename"),
            ("chmod ", "Permission change"),
            ("chown ", "Ownership change"),
            ("kill ", "Process termination"),
            ("pkill ", "Process termination by name"),
            ("export ", "Environment modification"),
        ]
        
        for (pattern, warning) in mediumRiskPatterns {
            if lowercased.contains(pattern.lowercased()) {
                warnings.append(warning)
                riskLevel = max(riskLevel, .medium)
            }
        }
        
        // Low risk but notable
        let lowRiskPatterns = [
            ("curl ", "Network request"),
            ("wget ", "Network download"),
            ("git push", "Remote repository change"),
            ("npm publish", "Package publication"),
            ("pip install", "Package installation"),
        ]
        
        for (pattern, warning) in lowRiskPatterns {
            if lowercased.contains(pattern.lowercased()) {
                warnings.append(warning)
                riskLevel = max(riskLevel, .low)
            }
        }
        
        return SanitizationResult(
            isAllowed: riskLevel < .critical,
            warnings: warnings,
            blockedReason: blockedReason,
            riskLevel: riskLevel
        )
    }
}
