import Foundation
import NIO
import WebSocketKit

/// A connection to a Robo server.
public final class RoboClient {
    private let eventLoopGroup: any EventLoopGroup
    private let webSocket: WebSocket

    private init(
        eventLoopGroup: any EventLoopGroup,
        webSocket: WebSocket
    ) {
        self.eventLoopGroup = eventLoopGroup
        self.webSocket = webSocket
    }

    deinit {
        try! webSocket.close().wait()
        try! eventLoopGroup.syncShutdownGracefully()
    }

    /// Connects to the Robo server at the given URL.
    public static func connect(to url: URL) async throws -> Self {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let webSocket = try await withCheckedThrowingContinuation { cont in
            WebSocket.connect(to: url, on: eventLoopGroup) { ws in
                cont.resume(returning: ws)
            }.whenFailure { error in
                cont.resume(throwing: error)
            }
        }
        
        // TODO: Register listeners

        return Self(eventLoopGroup: eventLoopGroup, webSocket: webSocket)
    }

    /// Sends an action to the server.
    public func send(action: Action) async throws {
        let data = try JSONEncoder().encode(action)
        guard let json = String(data: data, encoding: .utf8) else {
            throw RoboClientError.couldNotEncode(data)
        }
        try await send(raw: json)
    }

    /// Sends textual data to the server.
    private func send(raw: String) async throws {
        webSocket.send(raw)
    }
}
