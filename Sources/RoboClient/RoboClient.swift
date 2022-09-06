import Foundation
import Logging
import NIO
import WebSocketKit

private let log = Logger(label: "RoboClient")

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

    /// Connects to the Robo server at the given URL using traditional callbacks.
    public static func connect(to url: URL, continuation: @escaping (Result<RoboClient, Error>) -> Void) {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        WebSocket.connect(to: url, on: eventLoopGroup) { ws in
            // TODO: Register other listeners
            continuation(.success(Self(eventLoopGroup: eventLoopGroup, webSocket: ws)))
        }.whenFailure { error in
            continuation(.failure(error))
        }
    }

    /// Connects to the Robo server at the given URL asynchronously.
    @available(iOS 13, *)
    public static func connect(to url: URL) async throws -> RoboClient {
        try await withCheckedThrowingContinuation { continuation in
            Self.connect(to: url) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Sends an action to the server.
    public func send(action: Action, continuation: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(action)
            guard let json = String(data: data, encoding: .utf8) else {
                throw RoboClientError.couldNotEncode(data)
            }
            send(raw: json, continuation: continuation)
        } catch {
            continuation(.failure(error))
        }
    }

    /// Sends an action to the server asynchronously.
    @available(iOS 13, *)
    public func send(action: Action) async throws {
        try await withCheckedThrowingContinuation { continuation in
            send(action: action) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Sends textual data to the server.
    private func send(raw: String, continuation: @escaping (Result<Void, Error>) -> Void) {
        let promise = eventLoopGroup.next().makePromise(of: Void.self)
        webSocket.send(raw, promise: promise)
        promise.futureResult.whenComplete(continuation)
    }
}
