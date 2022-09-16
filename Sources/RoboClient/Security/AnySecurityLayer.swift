import Foundation

/// A type-erased wrapper around a ``SecurityLayer``.
public struct AnySecurityLayer: SecurityLayer {
    private let _seal: (Data) throws -> Data
    private let _open: (Data) throws -> Data

    public init<Security>(_ wrapped: Security) where Security: SecurityLayer {
        _seal = wrapped.seal
        _open = wrapped.open
    }

    public func seal(_ data: Data) throws -> Data {
        try _seal(data)
    }

    public func open(_ data: Data) throws -> Data {
        try _open(data)
    }
}
