/// A control action to be carried out by the server.
public enum Action: Codable, Hashable {
    case keySequence(text: String)
    case mouseMoveTo(point: Vec2<Int>)
    case mouseMoveBy(delta: Vec2<Int>)
    case mouseDown(button: MouseButton)
    case mouseUp(button: MouseButton)
    case mouseClick(button: MouseButton)
}
