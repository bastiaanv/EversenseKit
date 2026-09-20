@testable import EversenseKit
import CryptoKit
import Foundation
import Testing

struct PacketLengthGuardTests {
    // Ephemeral, synthetic session: no transmitter credentials or patient data.
    private func makeCrypto() throws -> CryptoUtil {
        let crypto = CryptoUtil()
        let client = P256.KeyAgreement.PrivateKey()
        let peer = P256.KeyAgreement.PrivateKey()
        try crypto.generateSessionKey(
            sessionPublicKey: peer.publicKey.rawRepresentation,
            privateKey: client.derRepresentation,
            salt: Data(repeating: 0, count: 8)
        )
        return crypto
    }

    @Test(arguments: 0 ..< 10)
    func rejectsShortEncryptedPayload(length: Int) throws {
        let crypto = try makeCrypto()
        #expect(crypto.decrypt(data: Data(repeating: 0, count: length)).isEmpty)
    }

    @Test(arguments: [0, 1, 16, 32])
    func preservesEncryptedRoundTrip(length: Int) throws {
        let crypto = try makeCrypto()
        let plaintext = Data((0 ..< length).map { UInt8($0) })
        let encrypted = crypto.encrypt(data: plaintext)
        #expect(encrypted.count == length + 10)
        #expect(crypto.decrypt(data: encrypted) == plaintext)
    }
}
