import Foundation

/// A simple security layer that doesn't perform any encryption.
public struct EmptySecurityLayer: SecurityLayer {
    public init() {}

    public func seal(_ data: Data) throws -> Data {
        data
    }

    public func open(_ data: Data) throws -> Data {
        data
    }
}
