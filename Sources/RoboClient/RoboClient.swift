import Foundation
import Logging
import NIO
import WebSocketKit

private let log = Logger(label: "RoboClient")

/// A connection to a Robo server.
public final class RoboClient<Security> where Security: SecurityLayer {
    private let eventLoopGroup: any EventLoopGroup
    private let webSocket: WebSocket
    private let security: Security
    private var closeHandlers: [() -> Void] = []

    /// The URL of the connected server.
    public let url: URL

    private init(
        url: URL,
        eventLoopGroup: any EventLoopGroup,
        webSocket: WebSocket,
        security: Security
    ) {
        self.url = url
        self.eventLoopGroup = eventLoopGroup
        self.webSocket = webSocket
        self.security = security

        webSocket.onClose.whenComplete { [weak self] _ in
            for closeHandler in self?.closeHandlers ?? [] {
                closeHandler()
            }
        }
    }

    deinit {
        _ = webSocket.close()
        eventLoopGroup.shutdownGracefully { error in
            guard let error = error else { return }
            log.error("Error while shutting down event loop group: \(error)")
        }
    }

    /// Connects to the Robo server at the given URL using traditional callbacks.
    public static func connect(
        to url: URL,
        security: Security,
        continuation: @escaping (Result<RoboClient, Error>) -> Void
    ) {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        WebSocket.connect(to: url, on: eventLoopGroup) { ws in
            // TODO: Register other listeners
            continuation(.success(Self(url: url, eventLoopGroup: eventLoopGroup, webSocket: ws, security: security)))
        }.whenFailure { error in
            continuation(.failure(error))
        }
    }

    /// Connects to the Robo server at the given URL asynchronously.
    @available(iOS 13, *)
    public static func connect(to url: URL, security: Security) async throws -> RoboClient {
        try await withCheckedThrowingContinuation { continuation in
            Self.connect(to: url, security: security) { result in
                continuation.resume(with: result)
            }
        }
    }

    /// Adds a close handler to the web socket.
    public func onClose(_ handler: @escaping () -> Void) {
        closeHandlers.append(handler)
    }

    /// Sends an action to the server.
    public func send(action: Action, continuation: @escaping (Result<Void, Error>) -> Void) {
        do {
            let data = try JSONEncoder().encode(action)
            send(raw: data, continuation: continuation)
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

    /// Sends (plaintext) binary data to the server.
    private func send(raw: Data, continuation: @escaping (Result<Void, Error>) -> Void) {
        do {
            let promise = eventLoopGroup.next().makePromise(of: Void.self)
            let sealed = try security.seal(raw)
            webSocket.send(Array(sealed), promise: promise)
            promise.futureResult.whenComplete(continuation)
        } catch {
            continuation(.failure(error))
        }
    }
}

extension RoboClient where Security == EmptySecurityLayer {
    public static func connect(to url: URL, continuation: @escaping (Result<RoboClient, Error>) -> Void) {
        Self.connect(to: url, security: .init(), continuation: continuation)
    }

    @available(iOS 13, *)
    public static func connect(to url: URL) async throws -> RoboClient {
        try await Self.connect(to: url, security: .init())
    }
}
