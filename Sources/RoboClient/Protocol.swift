public struct Vec2<Element> {
    public let x: Element
    public let y: Element
}

extension Vec2: Codable where Element: Codable {}

public enum MouseButton: String, Codable {
    case left = "Left"
    case middle = "Middle"
    case right = "Right"
}

public enum Action: Codable {
    case keySequence(text: String)
    case mouseMoveTo(point: Vec2<Int>)
    case mouseMoveBy(delta: Vec2<Int>)
    case mouseDown(button: MouseButton)
    case mouseUp(button: MouseButton)
    case mouseClick(button: MouseButton)
}
