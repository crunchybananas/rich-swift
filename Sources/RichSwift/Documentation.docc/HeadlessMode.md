# Headless Mode and CI Integration

Configure RichSwift for automated environments and machine-readable output.

## Overview

RichSwift is designed to work seamlessly in both interactive terminals and 
headless environments like CI/CD pipelines, Docker containers, and automated
scripts. This guide covers how to configure output for these scenarios.

## Environment Detection

RichSwift automatically detects its environment:

```swift
// Check if running in CI
if Environment.isCI {
    // Running in GitHub Actions, GitLab CI, etc.
}

// Check for NO_COLOR standard
if Environment.noColor {
    // User has requested no color output
}

// Check if in a container
if Environment.isContainer {
    // Running in Docker, Kubernetes, etc.
}
```

## Output Formats

Configure the output format based on your needs:

### Rich Mode (Default)
Full color and Unicode support for interactive terminals:
```swift
let config = ConsoleConfig.default  // .rich format
```

### Plain Mode
No colors or special characters:
```swift
let config = ConsoleConfig(format: .plain)
```

### JSON Mode
Structured output for parsing:
```swift
let config = ConsoleConfig.json
```

### NDJSON Mode
Newline-delimited JSON for streaming:
```swift
let config = ConsoleConfig(format: .ndjson)
```

## Structured Events

Emit machine-readable events alongside human-readable output:

```swift
let console = Console()

// Emit structured events
console.emit("build.started", message: "Starting build", data: [
    "project": "MyApp",
    "target": "release"
])

// Progress events
console.emitProgress(
    task: "compile",
    completed: 45,
    total: 100,
    message: "Compiling sources..."
)

// Completion events
console.emitComplete(task: "build", duration: .seconds(30))
```

## Task Queuing

For complex batch operations:

```swift
let queue = TaskQueue(maxConcurrent: 4)

// Register a handler
await queue.registerHandler(pattern: "build") { task in
    // Build logic...
    return QueuedTask.Result(success: true)
}

// Enqueue tasks
await queue.enqueue(name: "build", priority: .high)
await queue.enqueue(name: "test", priority: .normal)

// Process queue
await queue.start()
```

## Progress Persistence

Progress that survives process restarts:

```swift
let store = ProgressStore()

// Resume or create progress
let progress = await store.getOrCreate(
    id: "build-123",
    label: "Building project",
    total: 100
)

// Update progress
await store.increment(id: "build-123", by: 10)

// Complete or fail
await store.complete(id: "build-123", message: "Build succeeded")
```

## CI-Specific Configuration

Pre-configured settings for CI environments:

```swift
// Use CI-optimized config
let console = Console()
console.config = ConsoleConfig.ci

// Features:
// - Plain output format
// - Timestamps enabled
// - isCI flag set
// - Progress updates throttled
```

## Best Practices

1. **Always check `Environment.suggestedConfig`** - Let RichSwift auto-detect
2. **Use events for automation** - Parse JSON output in pipelines
3. **Persist long-running progress** - Resume after interruptions
4. **Queue batch operations** - Respect concurrency limits
5. **Test both modes** - Verify output in interactive and headless modes
