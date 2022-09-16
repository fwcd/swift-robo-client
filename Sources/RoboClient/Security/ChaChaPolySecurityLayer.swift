import Crypto
import Foundation

private let nonceLength = 12
private let tagLength = 16

/// A security layer implementation that uses ChaCha20-Poly1305
/// for symmetric, authenticated encryption.
public struct ChaChaPolySecurityLayer: SecurityLayer {
    private let key: SymmetricKey

    init(key: SymmetricKey) {
        self.key = key
    }

    public init(key data: Data) {
        self.init(key: SymmetricKey(data: data))
    }

    public func seal(_ plaintext: Data) throws -> Data {
        let box = try ChaChaPoly.seal(plaintext, using: key)
        return Data(box.nonce) + box.tag + box.ciphertext
    }

    public func open(_ boxData: Data) throws -> Data {
        let nonce = boxData[..<nonceLength]
        let tag = boxData[nonceLength..<(nonceLength + tagLength)]
        let ciphertext = boxData[(nonceLength + tagLength)...]
        let box = try ChaChaPoly.SealedBox(
            nonce: .init(data: nonce),
            ciphertext: ciphertext,
            tag: tag
        )
        return try ChaChaPoly.open(box, using: key)
    }
}
