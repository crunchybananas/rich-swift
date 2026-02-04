# Peel Prompt: RichSwift AI Terminal Integration

Copy this prompt when starting a Peel session:

---

I'm working on integrating RichSwift's AI Terminal into Peel. Here's the context:

## What RichSwift AI Terminal Does

RichSwift (github.com/crunchybananas/rich-swift) has an AI Terminal feature that:

1. **ShellAdapter** - Converts bash commands to zsh automatically:
   - `echo -e` → `echo` (zsh interprets escapes by default)
   - Backticks → `$()` command substitution
   - `read -p "prompt" var` → `read "var?prompt"`
   - Heredocs → escaped quoted strings (critical for `gh issue comment`)

2. **CommandSanitizer** - Analyzes commands for safety:
   - Risk levels: safe, low, medium, high, critical
   - Blocks: `rm -rf /`, fork bombs, `curl | sh`, etc.
   - Warns: sudo, network requests, file deletions

3. **AITerminal** - Actor that combines both with structured output:
   - Returns JSON with stdout, stderr, exitCode, wasAdapted, warnings
   - Perfect for AI agent parsing

## The Problem We're Solving

AI agents (including you!) generate bash commands that fail in zsh:
- `gh issue comment 123 --body "$(cat <<EOF\n...\nEOF\n)"` - heredoc escaping fails
- Backticks inside heredocs get corrupted
- Various syntax differences cause silent failures

## GitHub Issues

- #1: Add MCP Server for AI Terminal with Shell Adaptation
- #2: VS Code Extension: AI-Safe Terminal with Shell Adaptation

## What I Want to Build

1. **MCP Server** - Expose `run_command` and `analyze_command` tools
   - You would call `mcp_richswift_run_command` instead of `run_in_terminal`
   - Automatic adaptation and safety checks

2. **Peel Integration** - Make this the default for terminal commands
   - Could be opt-in per chain or global setting

## Key Files

The code is at `/Users/coryloken/code/rich-swift`:
- `Sources/RichSwift/Terminal/ShellAdapter.swift` - Bash→zsh conversion
- `Sources/RichSwift/Terminal/AITerminal.swift` - Actor with run/analyze
- `Examples/AITerminal/Sources/main.swift` - Demo showing features

## What I Need Help With

1. Understand how Peel's MCP tool system works
2. Design the integration approach  
3. Start implementing the MCP server in Swift

---

## Quick Reference

### ShellAdapter Transformations

| Bash | Zsh | Change Type |
|------|-----|-------------|
| `echo -e "text\n"` | `echo "text\n"` | echoEscape |
| `` `date` `` | `$(date)` | commandSubstitution |
| `read -p "Name:" var` | `read "var?Name:"` | readCommand |
| `${arr[*]}` | `${(j: :)arr}` | arrayExpansion |
| `$(cat <<EOF...EOF)` | `"escaped\nstring"` | heredoc |

### CommandSanitizer Risk Levels

| Level | Examples | Action |
|-------|----------|--------|
| safe | `ls`, `pwd`, `echo` | Allow |
| low | `curl`, `wget` | Allow + warn |
| medium | `rm file`, `sudo` | Allow + warn |
| high | `rm -rf dir` | Allow + strong warn |
| critical | `rm -rf /`, fork bomb | Block |

### AITerminal Output

```json
{
  "command": "original command",
  "adapted_command": "zsh-compatible version",
  "was_adapted": true,
  "stdout": "...",
  "stderr": "...",
  "exit_code": 0,
  "success": true,
  "warnings": ["Network request"],
  "duration_ms": 42
}
```
