import CryptoKit
import Foundation

class CryptoUtil {
    public static let shared = CryptoUtil()

    private static let logger = EversenseLogger(category: "CryptoUtil")

    private static let publicKey = "-----BEGIN PUBLIC KEY-----\n" +
        "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEL67Un32stnX4wX8rNYpH9zsu+PFJ\n" +
        "kRDJg5gpOVobGb5e2fazOZ2DDhCqpgMfgUm1P/2HuZhWRJvwSrV402p4gA==\n" +
        "-----END PUBLIC KEY-----"
    private static let aesKey = SymmetricKey(data: Array("XdHC2ni9oKcd1D5f".utf8))
    private static let aesIV = Data(Array("9u4CzyxzQ4884yZL".utf8))

    private var messageCount: Int = 1
    private var salt: Data?
    private var sessionKey: SymmetricKey?

    static func generateSession(fleetKey: String) -> (SymmetricKey, Data)? {
        guard let publicKey = getPublicKey() else {
            return nil
        }

        guard let privateKey = decryptFleetKey(fleetKey: fleetKey) else {
            return nil
        }

        guard let sharedSecret = getSharedSecret(from: privateKey, with: publicKey) else {
            return nil
        }

        let salt = Data.randomSecure(length: 8)
        let sessionKey = deriveSessionKey(sharedSecret: sharedSecret, salt: salt)
        return (sessionKey, salt)
    }

    static func generateKeyPair() -> (Data, Data, Data) {
        let privateKey = P256.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey
        let clientId = Data.randomSecure(length: 32)

        return (privateKey.derRepresentation, publicKey.derRepresentation, clientId)
    }

    static func generateEphem(privateKey pKeyData: Data) throws -> (Data, Data, Data, Data) {
        let ephemPrivateKey = P256.KeyAgreement.PrivateKey()
        let ephemPublicKey = Data(ephemPrivateKey.publicKey.derRepresentation)
        let salt = Data.randomSecure(length: 8)

        let privateKey = try P256.Signing.PrivateKey(derRepresentation: pKeyData)
        var data = Data(ephemPublicKey.subdata(in: 27 ..< ephemPublicKey.count))
        data.append(salt)

        let digitalSignature = try privateKey.signature(for: data).derRepresentation
        let actualSignature = try parseECDSASignature(digitalSignature)

        return (ephemPrivateKey.derRepresentation, ephemPublicKey, salt, actualSignature)
    }

    static func generateSignature(sessionKey: SymmetricKey, data: Data) -> Data {
        let result = HMAC<SHA256>.authenticationCode(for: data, using: sessionKey)
        return Data(result).subdata(in: 0 ..< 8)
    }

    func generateSessionKey(sessionPublicKey: Data, privateKey: Data, salt: Data) throws {
        messageCount = 1
        self.salt = salt

        let publicKey = try P256.KeyAgreement.PublicKey(rawRepresentation: sessionPublicKey)
        let privateKey = try P256.KeyAgreement.PrivateKey(derRepresentation: privateKey)
        let secret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)

        sessionKey = secret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: Data(), sharedInfo: salt, outputByteCount: 16)
    }

    func encrypt(data: Data) -> Data {
        guard let sessionKey = sessionKey else {
            CryptoUtil.logger.error("[encrypt] No sessionKey stored...")
            return Data()
        }

        guard let salt = salt else {
            CryptoUtil.logger.error("[encrypt] No salt stored...")
            return Data()
        }

        do {
            let i = Int64(messageCount) & 0x3FFF
            messageCount += 1
            if messageCount == 0x3FFF {
                messageCount = 1
            }

            let s = BinaryOperations.dataFrom16Bits(value: UInt16(i) << 2)

            let ccm = try AESCCM(
                key: sessionKey.withUnsafeBytes { Array($0) },
                nonce: [UInt8](CryptoUtil.generateEncryptionSalt(salt: salt, i: i)),
                tagLength: 8,
                additionalAuthenticatedData: [UInt8](s)
            )

            var output = Data()
            output.append(s)
            output.append(Data(try ccm.encrypt([UInt8](data))))

            return output
        } catch {
            CryptoUtil.logger.error("Failed to encrypt data: \(error)")
            return Data()
        }
    }

    func decrypt(data: Data) -> Data {
        // Two-byte prefix followed by the eight-byte CCM authentication tag.
        guard data.count >= 10 else {
            CryptoUtil.logger.error("[decrypt] Encrypted payload too short - count: \(data.count)")
            return Data()
        }

        guard let sessionKey = sessionKey else {
            CryptoUtil.logger.error("[decrypt] No sessionKey stored...")
            return Data()
        }

        guard let salt = salt else {
            CryptoUtil.logger.error("[decrypt] No salt stored...")
            return Data()
        }

        do {
            let cipherText = Data(data.subdata(in: 2 ..< data.count))
            let prefix = Data(data.subdata(in: 0 ..< 2))
            let i = (prefix.toInt64() >> 2) & 0x3FFF

            let ccm = try AESCCM(
                key: sessionKey.withUnsafeBytes { Array($0) },
                nonce: [UInt8](CryptoUtil.generateEncryptionSalt(salt: salt, i: i)),
                tagLength: 8,
                additionalAuthenticatedData: [UInt8](prefix)
            )

            // cipherText already contains the 8-byte tag appended by encrypt()
            return Data(try ccm.decrypt([UInt8](cipherText)))
        } catch {
            CryptoUtil.logger.error("[general] Failed to decrypt data: \(error)")
            return Data()
        }
    }

    public static func generateEncryptionSalt(salt: Data, i: Int64) -> Data {
        let temp1 = salt.withUnsafeBytes { $0.load(as: Int64.self).littleEndian }
        let temp2 = temp1 & -16384 | i

        return temp2.toData(length: 8)
    }

    private static func getPublicKey() -> P256.KeyAgreement.PublicKey? {
        do {
            return try P256.KeyAgreement.PublicKey(pemRepresentation: publicKey)
        } catch {
            logger.error("Failed to load public key: \(error)")
            return nil
        }
    }

    public static func decryptPublicKey(fleetKey: String) -> P256.KeyAgreement.PublicKey? {
        guard let b64Encoded = fleetKey.data(using: .utf8), let encryptedBytes = Data(base64Encoded: b64Encoded) else {
            logger.error("Failed to base64 decode public key: \(fleetKey)")
            return nil
        }

        var decryptedData = Data()
        do {
            decryptedData = try AES.CBC.decrypt(
                key: aesKey,
                data: encryptedBytes,
                iv: aesIV
            )
        } catch {
            logger.error("Failed to decrypt public key: \(error.localizedDescription)")
            return nil
        }

        do {
            let publicKeyData = Data(decryptedData[0 ..< 64])
            return try P256.KeyAgreement.PublicKey(rawRepresentation: publicKeyData)
        } catch {
            logger.error("public key is not in pem represenation: \(error)")
            return nil
        }
    }

    private static func decryptFleetKey(fleetKey: String) -> P256.KeyAgreement.PrivateKey? {
        guard let b64Encoded = fleetKey.data(using: .utf8), let encryptedBytes = Data(base64Encoded: b64Encoded) else {
            logger.error("Failed to base64 decode fleetkey: \(fleetKey)")
            return nil
        }

        do {
            let decryptedData = try AES.CBC.decrypt(
                key: aesKey,
                data: encryptedBytes,
                iv: aesIV
            )

            guard let privateKeyStr = String(data: decryptedData, encoding: .utf8) else {
                logger.error("Fleetkey is not a PEM document..")
                return nil
            }

            return try P256.KeyAgreement.PrivateKey(pemRepresentation: privateKeyStr)
        } catch {
            logger.error("Failed to decrypt fleetkey: \(error.localizedDescription)")
            return nil
        }
    }

    private static func getSharedSecret(
        from privateKey: P256.KeyAgreement.PrivateKey,
        with publicKey: P256.KeyAgreement.PublicKey
    ) -> SharedSecret? {
        do {
            return try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        } catch {
            logger.error("Failed to get shared secret: \(error)")
            return nil
        }
    }

    private static func deriveSessionKey(sharedSecret: SharedSecret, salt: Data) -> SymmetricKey {
        sharedSecret.x963DerivedSymmetricKey(
            using: SHA256.self,
            sharedInfo: salt,
            outputByteCount: 32
        )
    }
}
