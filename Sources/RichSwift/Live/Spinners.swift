import Foundation

/// Collection of spinner animations
public struct Spinners {
    /// A spinner animation definition
    public struct Spinner: Sendable {
        public let frames: [String]
        public let interval: Duration
        
        public init(frames: [String], interval: Duration = .milliseconds(80)) {
            self.frames = frames
            self.interval = interval
        }
        
        /// Get frame at given time
        public func frame(at elapsed: Duration) -> String {
            let ms = elapsed.components.seconds * 1000 + Int64(elapsed.components.attoseconds / 1_000_000_000_000_000)
            let intervalMs = interval.components.seconds * 1000 + Int64(interval.components.attoseconds / 1_000_000_000_000_000)
            let index = Int(ms / intervalMs) % frames.count
            return frames[index]
        }
    }
    
    // MARK: - Dots
    public static let dots = Spinner(frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])
    public static let dots2 = Spinner(frames: ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"])
    public static let dots3 = Spinner(frames: ["⠋", "⠙", "⠚", "⠞", "⠖", "⠦", "⠴", "⠲", "⠳", "⠓"])
    public static let dots4 = Spinner(frames: ["⠄", "⠆", "⠇", "⠋", "⠙", "⠸", "⠰", "⠠", "⠰", "⠸", "⠙", "⠋", "⠇", "⠆"])
    public static let dots5 = Spinner(frames: ["⠋", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋"])
    public static let dots6 = Spinner(frames: ["⠁", "⠉", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠤", "⠄", "⠄", "⠤", "⠴", "⠲", "⠒", "⠂", "⠂", "⠒", "⠚", "⠙", "⠉", "⠁"])
    public static let dots7 = Spinner(frames: ["⠈", "⠉", "⠋", "⠓", "⠒", "⠐", "⠐", "⠒", "⠖", "⠦", "⠤", "⠠", "⠠", "⠤", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋", "⠉", "⠈"])
    public static let dots8 = Spinner(frames: ["⠁", "⠁", "⠉", "⠙", "⠚", "⠒", "⠂", "⠂", "⠒", "⠲", "⠴", "⠤", "⠄", "⠄", "⠤", "⠠", "⠠", "⠤", "⠦", "⠖", "⠒", "⠐", "⠐", "⠒", "⠓", "⠋", "⠉", "⠈", "⠈"])
    public static let dots9 = Spinner(frames: ["⢹", "⢺", "⢼", "⣸", "⣇", "⡧", "⡗", "⡏"])
    public static let dots10 = Spinner(frames: ["⢄", "⢂", "⢁", "⡁", "⡈", "⡐", "⡠"])
    public static let dots11 = Spinner(frames: ["⠁", "⠂", "⠄", "⡀", "⢀", "⠠", "⠐", "⠈"])
    public static let dots12 = Spinner(frames: ["⢀⠀", "⡀⠀", "⠄⠀", "⢂⠀", "⡂⠀", "⠅⠀", "⢃⠀", "⡃⠀", "⠍⠀", "⢋⠀", "⡋⠀", "⠍⠁", "⢋⠁", "⡋⠁", "⠍⠉", "⠋⠉", "⠋⠉", "⠉⠙", "⠉⠙", "⠉⠩", "⠈⢙", "⠈⡙", "⢈⠩", "⡂⢐", "⠅⡐", "⢃⠨", "⡃⢐", "⠍⡐", "⢋⠨", "⡋⢐", "⠍⡐", "⢋⠨", "⡋⡐", "⠍⠨", "⢋⠠", "⡋⠠", "⠍⠠", "⠋⠠", "⠋⠠", "⠉⠠", "⠉⠠", "⠉⡠", "⠈⢠", "⠈⡠", "⠈⠠", "⠀⢠", "⠀⡠", "⠀⠠", "⠀⢀", "⠀⡀"])
    
    // MARK: - Lines
    public static let line = Spinner(frames: ["-", "\\", "|", "/"])
    public static let line2 = Spinner(frames: ["⠂", "-", "–", "—", "–", "-"])
    
    // MARK: - Arrows
    public static let arrow = Spinner(frames: ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"])
    public static let arrow2 = Spinner(frames: ["⬆️ ", "↗️ ", "➡️ ", "↘️ ", "⬇️ ", "↙️ ", "⬅️ ", "↖️ "])
    public static let arrow3 = Spinner(frames: ["▹▹▹▹▹", "▸▹▹▹▹", "▹▸▹▹▹", "▹▹▸▹▹", "▹▹▹▸▹", "▹▹▹▹▸"])
    
    // MARK: - Bouncing
    public static let bouncingBar = Spinner(frames: ["[    ]", "[=   ]", "[==  ]", "[=== ]", "[ ===]", "[  ==]", "[   =]", "[    ]", "[   =]", "[  ==]", "[ ===]", "[====]", "[=== ]", "[==  ]", "[=   ]"])
    public static let bouncingBall = Spinner(frames: ["( ●    )", "(  ●   )", "(   ●  )", "(    ● )", "(     ●)", "(    ● )", "(   ●  )", "(  ●   )", "( ●    )", "(●     )"])
    
    // MARK: - Progress
    public static let pipe = Spinner(frames: ["┤", "┘", "┴", "└", "├", "┌", "┬", "┐"])
    public static let simpleDots = Spinner(frames: [".  ", ".. ", "...", "   "])
    public static let simpleDotsScrolling = Spinner(frames: [".  ", ".. ", "...", " ..", "  .", "   "])
    
    // MARK: - Shapes
    public static let star = Spinner(frames: ["✶", "✸", "✹", "✺", "✹", "✷"])
    public static let star2 = Spinner(frames: ["+", "x", "*"])
    public static let flip = Spinner(frames: ["_", "_", "_", "-", "`", "`", "'", "´", "-", "_", "_", "_"])
    public static let hamburger = Spinner(frames: ["☱", "☲", "☴"])
    public static let growVertical = Spinner(frames: ["▁", "▃", "▄", "▅", "▆", "▇", "▆", "▅", "▄", "▃"])
    public static let growHorizontal = Spinner(frames: ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "▊", "▋", "▌", "▍", "▎"])
    public static let balloon = Spinner(frames: [" ", ".", "o", "O", "@", "*", " "])
    public static let balloon2 = Spinner(frames: [".", "o", "O°", "O°o", "Oo", ".", " "])
    public static let noise = Spinner(frames: ["▓", "▒", "░"])
    public static let bounce = Spinner(frames: ["⠁", "⠂", "⠄", "⠂"])
    public static let boxBounce = Spinner(frames: ["▖", "▘", "▝", "▗"])
    public static let boxBounce2 = Spinner(frames: ["▌", "▀", "▐", "▄"])
    public static let triangle = Spinner(frames: ["◢", "◣", "◤", "◥"])
    public static let arc = Spinner(frames: ["◜", "◠", "◝", "◞", "◡", "◟"])
    public static let circle = Spinner(frames: ["◡", "⊙", "◠"])
    public static let circleQuarters = Spinner(frames: ["◴", "◷", "◶", "◵"])
    public static let circleHalves = Spinner(frames: ["◐", "◓", "◑", "◒"])
    public static let squish = Spinner(frames: ["╫", "╪"])
    public static let toggle = Spinner(frames: ["⊶", "⊷"])
    public static let toggle2 = Spinner(frames: ["▫", "▪"])
    public static let toggle3 = Spinner(frames: ["□", "■"])
    public static let toggle4 = Spinner(frames: ["■", "□", "▪", "▫"])
    public static let toggle5 = Spinner(frames: ["▮", "▯"])
    public static let toggle6 = Spinner(frames: ["ဝ", "၀"])
    public static let toggle7 = Spinner(frames: ["⦾", "⦿"])
    public static let toggle8 = Spinner(frames: ["◍", "◌"])
    public static let toggle9 = Spinner(frames: ["◉", "◎"])
    public static let toggle10 = Spinner(frames: ["㊂", "㊀", "㊁"])
    public static let toggle11 = Spinner(frames: ["⧇", "⧆"])
    public static let toggle12 = Spinner(frames: ["☗", "☖"])
    public static let toggle13 = Spinner(frames: ["=", "*", "-"])
    
    // MARK: - Clock
    public static let clock = Spinner(frames: ["🕛 ", "🕐 ", "🕑 ", "🕒 ", "🕓 ", "🕔 ", "🕕 ", "🕖 ", "🕗 ", "🕘 ", "🕙 ", "🕚 "])
    
    // MARK: - Emoji
    public static let earth = Spinner(frames: ["🌍 ", "🌎 ", "🌏 "])
    public static let moon = Spinner(frames: ["🌑 ", "🌒 ", "🌓 ", "🌔 ", "🌕 ", "🌖 ", "🌗 ", "🌘 "])
    public static let runner = Spinner(frames: ["🚶 ", "🏃 "])
    public static let pong = Spinner(frames: ["▐⠂       ▌", "▐⠈       ▌", "▐ ⠂      ▌", "▐ ⠠      ▌", "▐  ⡀     ▌", "▐  ⠠     ▌", "▐   ⠂    ▌", "▐   ⠈    ▌", "▐    ⠂   ▌", "▐    ⠠   ▌", "▐     ⡀  ▌", "▐     ⠠  ▌", "▐      ⠂ ▌", "▐      ⠈ ▌", "▐       ⠂▌", "▐       ⠠▌", "▐       ⡀▌", "▐      ⠠ ▌", "▐      ⠂ ▌", "▐     ⠈  ▌", "▐     ⠂  ▌", "▐    ⠠   ▌", "▐    ⡀   ▌", "▐   ⠠    ▌", "▐   ⠂    ▌", "▐  ⠈     ▌", "▐  ⠂     ▌", "▐ ⠠      ▌", "▐ ⡀      ▌", "▐⠠       ▌"])
    public static let shark = Spinner(frames: ["▐|\\____________▌", "▐_|\\___________▌", "▐__|\\__________▌", "▐___|\\_________▌", "▐____|\\________▌", "▐_____|\\_______▌", "▐______|\\______▌", "▐_______|\\_____▌", "▐________|\\____▌", "▐_________|\\___▌", "▐__________|\\__▌", "▐___________|\\_▌", "▐____________|\\▌", "▐____________/|▌", "▐___________/|_▌", "▐__________/|__▌", "▐_________/|___▌", "▐________/|____▌", "▐_______/|_____▌", "▐______/|______▌", "▐_____/|_______▌", "▐____/|________▌", "▐___/|_________▌", "▐__/|__________▌", "▐_/|___________▌", "▐/|____________▌"])
    public static let dqpb = Spinner(frames: ["d", "q", "p", "b"])
    public static let weather = Spinner(frames: ["☀️ ", "☀️ ", "☀️ ", "🌤 ", "⛅️ ", "🌥 ", "☁️ ", "🌧 ", "🌨 ", "🌧 ", "🌨 ", "🌧 ", "🌨 ", "⛈ ", "🌨 ", "🌧 ", "🌨 ", "☁️ ", "🌥 ", "⛅️ ", "🌤 ", "☀️ ", "☀️ "])
    public static let christmas = Spinner(frames: ["🌲", "🎄"])
    public static let grenade = Spinner(frames: ["،   ", "′   ", " ´ ", " ‾ ", "  ⸌", "  ⸊", "  |", "  ⁎", "  ⁕", " ෴ ", "  ⁓", "   ", "   ", "   "])
    public static let point = Spinner(frames: ["∙∙∙", "●∙∙", "∙●∙", "∙∙●", "∙∙∙"])
    public static let layer = Spinner(frames: ["-", "=", "≡"])
    public static let betaWave = Spinner(frames: ["ρββββββ", "βρβββββ", "ββρββββ", "βββρβββ", "ββββρββ", "βββββρβ", "ββββββρ"])
    
    /// All available spinners
    public static let all: [String: Spinner] = [
        "dots": dots,
        "dots2": dots2,
        "dots3": dots3,
        "dots4": dots4,
        "dots5": dots5,
        "dots6": dots6,
        "dots7": dots7,
        "dots8": dots8,
        "dots9": dots9,
        "dots10": dots10,
        "dots11": dots11,
        "dots12": dots12,
        "line": line,
        "line2": line2,
        "arrow": arrow,
        "arrow2": arrow2,
        "arrow3": arrow3,
        "bouncingBar": bouncingBar,
        "bouncingBall": bouncingBall,
        "pipe": pipe,
        "simpleDots": simpleDots,
        "simpleDotsScrolling": simpleDotsScrolling,
        "star": star,
        "star2": star2,
        "flip": flip,
        "hamburger": hamburger,
        "growVertical": growVertical,
        "growHorizontal": growHorizontal,
        "balloon": balloon,
        "balloon2": balloon2,
        "noise": noise,
        "bounce": bounce,
        "boxBounce": boxBounce,
        "boxBounce2": boxBounce2,
        "triangle": triangle,
        "arc": arc,
        "circle": circle,
        "circleQuarters": circleQuarters,
        "circleHalves": circleHalves,
        "squish": squish,
        "toggle": toggle,
        "toggle2": toggle2,
        "toggle3": toggle3,
        "toggle4": toggle4,
        "toggle5": toggle5,
        "toggle6": toggle6,
        "toggle7": toggle7,
        "toggle8": toggle8,
        "toggle9": toggle9,
        "toggle10": toggle10,
        "toggle11": toggle11,
        "toggle12": toggle12,
        "toggle13": toggle13,
        "clock": clock,
        "earth": earth,
        "moon": moon,
        "runner": runner,
        "pong": pong,
        "shark": shark,
        "dqpb": dqpb,
        "weather": weather,
        "christmas": christmas,
        "grenade": grenade,
        "point": point,
        "layer": layer,
        "betaWave": betaWave
    ]
    
    /// Get a spinner by name
    public static func get(_ name: String) -> Spinner? {
        all[name]
    }
}
