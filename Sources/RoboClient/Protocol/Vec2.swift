/// A 2D vector for use in protocol types.
public struct Vec2<Element> {
    public let x: Element
    public let y: Element

    public init(x: Element, y: Element) {
        self.x = x
        self.y = y
    }
}

extension Vec2: Codable where Element: Codable {}
extension Vec2: Equatable where Element: Equatable {}
extension Vec2: Hashable where Element: Hashable {}
