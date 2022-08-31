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

public enum MouseButton: String, Codable, Hashable {
    case left = "Left"
    case middle = "Middle"
    case right = "Right"
}

public enum Action: Codable, Hashable {
    case keySequence(text: String)
    case mouseMoveTo(point: Vec2<Int>)
    case mouseMoveBy(delta: Vec2<Int>)
    case mouseDown(button: MouseButton)
    case mouseUp(button: MouseButton)
    case mouseClick(button: MouseButton)
}
