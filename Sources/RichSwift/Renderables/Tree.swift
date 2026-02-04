/// A tree structure for displaying hierarchical data
public final class Tree: Renderable, @unchecked Sendable {
    /// A node in the tree
    public final class Node: @unchecked Sendable {
        public let label: String
        public let style: Style
        public var children: [Node]
        
        public init(_ label: String, style: Style = .none, children: [Node] = []) {
            self.label = label
            self.style = style
            self.children = children
        }
        
        /// Add a child node
        @discardableResult
        public func add(_ label: String, style: Style = .none) -> Node {
            let child = Node(label, style: style)
            children.append(child)
            return child
        }
        
        /// Add an existing node as child
        @discardableResult
        public func add(_ node: Node) -> Node {
            children.append(node)
            return node
        }
    }
    
    /// Guide characters for tree drawing
    public struct Guide: Sendable {
        let vertical: String
        let branch: String
        let lastBranch: String
        let horizontal: String
        
        /// ASCII style guides
        public static let ascii = Guide(
            vertical: "|   ",
            branch: "|-- ",
            lastBranch: "`-- ",
            horizontal: "    "
        )
        
        /// Unicode rounded style
        public static let rounded = Guide(
            vertical: "│   ",
            branch: "├── ",
            lastBranch: "╰── ",
            horizontal: "    "
        )
        
        /// Unicode square style
        public static let square = Guide(
            vertical: "│   ",
            branch: "├── ",
            lastBranch: "└── ",
            horizontal: "    "
        )
        
        /// Bold/heavy Unicode style
        public static let heavy = Guide(
            vertical: "┃   ",
            branch: "┣━━ ",
            lastBranch: "┗━━ ",
            horizontal: "    "
        )
    }
    
    // MARK: - Properties
    
    public let root: Node
    public let guide: Guide
    public let guideStyle: Style
    public let hideRoot: Bool
    
    // MARK: - Initialization
    
    public init(
        _ label: String,
        style: Style = Style.bold,
        guide: Guide = .rounded,
        guideStyle: Style = Style(foreground: .brightBlack),
        hideRoot: Bool = false
    ) {
        self.root = Node(label, style: style)
        self.guide = guide
        self.guideStyle = guideStyle
        self.hideRoot = hideRoot
    }
    
    public init(
        root: Node,
        guide: Guide = .rounded,
        guideStyle: Style = Style(foreground: .brightBlack),
        hideRoot: Bool = false
    ) {
        self.root = root
        self.guide = guide
        self.guideStyle = guideStyle
        self.hideRoot = hideRoot
    }
    
    /// Add a child to the root
    @discardableResult
    public func add(_ label: String, style: Style = .none) -> Node {
        root.add(label, style: style)
    }
    
    /// Add a node to the root
    @discardableResult
    public func add(_ node: Node) -> Node {
        root.add(node)
    }
    
    // MARK: - Rendering
    
    public func render(console: Console) -> Text {
        var text = Text()
        
        if !hideRoot {
            text.append(root.label, style: root.style)
            text.append("\n")
        }
        
        let children = root.children
        for (index, child) in children.enumerated() {
            let isLast = index == children.count - 1
            renderNode(child, prefix: "", isLast: isLast, into: &text)
        }
        
        // Remove trailing newline
        if text.plain.hasSuffix("\n") {
            // We leave it for now as it matches typical tree output
        }
        
        return text
    }
    
    private func renderNode(_ node: Node, prefix: String, isLast: Bool, into text: inout Text) {
        // Draw the branch line
        let branch = isLast ? guide.lastBranch : guide.branch
        text.append(prefix, style: guideStyle)
        text.append(branch, style: guideStyle)
        text.append(node.label, style: node.style)
        text.append("\n")
        
        // Draw children
        let newPrefix = prefix + (isLast ? guide.horizontal : guide.vertical)
        for (index, child) in node.children.enumerated() {
            let childIsLast = index == node.children.count - 1
            renderNode(child, prefix: newPrefix, isLast: childIsLast, into: &text)
        }
    }
}

// MARK: - Convenience builders

extension Tree.Node {
    /// Build a subtree with a closure
    @discardableResult
    public func subtree(_ label: String, style: Style = .none, @TreeBuilder _ builder: () -> [Tree.Node]) -> Tree.Node {
        let node = Tree.Node(label, style: style, children: builder())
        children.append(node)
        return node
    }
}

/// A result builder for creating tree structures
@resultBuilder
public struct TreeBuilder {
    public static func buildBlock(_ components: Tree.Node...) -> [Tree.Node] {
        components
    }
    
    public static func buildArray(_ components: [[Tree.Node]]) -> [Tree.Node] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [Tree.Node]?) -> [Tree.Node] {
        component ?? []
    }
    
    public static func buildEither(first component: [Tree.Node]) -> [Tree.Node] {
        component
    }
    
    public static func buildEither(second component: [Tree.Node]) -> [Tree.Node] {
        component
    }
}

/// String literal support for tree nodes
extension Tree.Node: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
