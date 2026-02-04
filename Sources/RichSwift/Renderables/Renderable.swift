/// Protocol for objects that can be rendered to the console
public protocol Renderable {
    /// Render this object to styled Text
    func render(console: Console) -> Text
}

// MARK: - String conformance

extension String: Renderable {
    public func render(console: Console) -> Text {
        return self.asMarkup
    }
}

// MARK: - Text conformance

extension Text: Renderable {
    public func render(console: Console) -> Text {
        return self
    }
}
