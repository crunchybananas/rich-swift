# Styling Text

Learn about the powerful text styling system in RichSwift.

## Overview

RichSwift provides multiple ways to style text, from simple inline markup
to programmatic style composition.

## Markup Syntax

The easiest way to style text is with markup:

```swift
let console = Console()

// Basic styles
console.print("[bold]Bold text[/bold]")
console.print("[italic]Italic text[/italic]")
console.print("[underline]Underlined[/underline]")
console.print("[dim]Dimmed text[/dim]")

// Colors
console.print("[red]Red[/red] [green]Green[/green] [blue]Blue[/blue]")

// Background colors
console.print("[on yellow]Highlighted[/on yellow]")

// Combined styles
console.print("[bold red on white]Bold red on white[/bold red on white]")
```

## Available Colors

Standard ANSI colors:
- `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`

Bright variants:
- `bright_black`, `bright_red`, `bright_green`, etc.

## Custom Colors

Use RGB colors for precise control:

```swift
// RGB color
let style = Style(foreground: .rgb(r: 255, g: 128, b: 0))

// 256-color palette
let style = Style(foreground: .color256(208))

// Hex colors (if supported)
let text = Text("Orange", style: Style(foreground: .rgb(r: 255, g: 165, b: 0)))
```

## Programmatic Styling

Build styles programmatically with ``Style``:

```swift
// Create a style
let errorStyle = Style(
    foreground: .red,
    background: .white,
    bold: true
)

// Apply to text
let text = Text("Error!", style: errorStyle)

// Merge styles
let combinedStyle = baseStyle.merged(with: overrideStyle)
```

## Text Composition

Build complex text with ``Text``:

```swift
var text = Text()
text.append("Hello ", style: Style(foreground: .blue))
text.append("World", style: Style(foreground: .green, bold: true))
text.append("!")

console.print(text)
```

## Themes

Use themes for consistent styling:

```swift
// Set a theme
Console.theme = Theme.dracula

// Use semantic styles
console.success("Build passed")  // Uses theme's success color
console.warning("Deprecated API")  // Uses theme's warning color
console.error("Build failed")  // Uses theme's error color
```

Available themes:
- `Theme.default` - Standard colors
- `Theme.minimal` - Subtle styling
- `Theme.highContrast` - Maximum visibility
- `Theme.monochrome` - No colors
- `Theme.dracula` - Popular dark theme colors
- `Theme.github` - GitHub-inspired colors

## Emoji Support

Add emojis by name:

```swift
// Inline emoji codes
console.print(":rocket: Launching...")
console.print(":check: Complete!")

// Programmatic
let rocket = Emoji.get("rocket")  // "🚀"
```

## Next Steps

- <doc:TablesAndLayout> - Complex layout options
- <doc:ProgressDisplays> - Live progress tracking
