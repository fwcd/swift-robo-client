import Foundation

/// An optional layer of encryption.
public protocol SecurityLayer {
    /// Encrypts a message (if needed).
    func seal(_ data: Data) throws -> Data

    /// Decrypts a message (if needed).
    func open(_ data: Data) throws -> Data
}
