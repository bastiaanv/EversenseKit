import _CryptoExtras
import Crypto
import CryptoSwift
import Foundation
import Security
import SwiftASN1

class CryptoUtil {
    public static let shared = CryptoUtil()

    private static let logger = EversenseLogger(category: "CryptoUtil")

    private static let publicKey = "-----BEGIN PUBLIC KEY-----\n" +
        "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEL67Un32stnX4wX8rNYpH9zsu+PFJ\n" +
        "kRDJg5gpOVobGb5e2fazOZ2DDhCqpgMfgUm1P/2HuZhWRJvwSrV402p4gA==\n" +
        "-----END PUBLIC KEY-----"
    private static let aesKey = SymmetricKey(data: Array("XdHC2ni9oKcd1D5f".utf8))
    private static let aesIV = Array("9u4CzyxzQ4884yZL".utf8)

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
        logger.debug("RAW signature: \(digitalSignature.hexString())")

        var actualSignature = Data()
        let nodeCollection = try DER.parse([UInt8](digitalSignature))
        try DER.sequence(nodeCollection, identifier: .sequence) { nodes in
            actualSignature.append(contentsOf: try ArraySlice(derEncoded: &nodes))
            actualSignature.append(contentsOf: try ArraySlice(derEncoded: &nodes))
        }

        logger.debug("DECODED signature: \(actualSignature.hexString())")

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

        sessionKey = secret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: salt, sharedInfo: Data(), outputByteCount: 16)
    }

    func encrypt(data: Data) -> Data {
        guard let sessionKey = sessionKey else {
            CryptoUtil.logger.error("No sessionKey stored...")
            return Data()
        }

        guard let salt = salt else {
            CryptoUtil.logger.error("No salt stored...")
            return Data()
        }

        do {
            CryptoUtil.logger.debug("RAW data: \(data.hexString())")

            let count = Int64(messageCount)
            messageCount += 1
            if messageCount == 0x3FFF {
                messageCount = 1
            }

            let s = BinaryOperations.dataFrom16Bits(value: UInt16(count & 0x3FFF) << 2)
            let nonce = (salt.toInt64() & Int64(-16384)) | count

            let key = sessionKey.withUnsafeBytes { Array(Data($0)) }
            CryptoUtil.logger.debug("sessionKey: \(key.toHexString())")
            CryptoUtil.logger.debug("salt: \(salt.toHexString())")
            CryptoUtil.logger.debug("nonce: \(nonce.toData(length: 8).toHexString())")
            CryptoUtil.logger.debug("s: \(s.toHexString())")

            let aes = try AES(
                key: key,
                blockMode: CCM(
                    iv: [UInt8](nonce.toData(length: 8)),
                    tagLength: 8,
                    messageLength: data.count + 8,
                    additionalAuthenticatedData: [UInt8](s)
                ),
                padding: .noPadding
            )

            let result = try aes.encrypt([UInt8](data))

//            let result = try AES.GCM.seal(
//                data,
//                using: sessionKey,
//                nonce: AES.GCM.Nonce(data: nonce.toData(length: 8)),
//                authenticating: s
//            )

//            guard let data = result.combined else {
//                CryptoUtil.logger.debug("Empty encryption result...")
//                return Data()
//            }

            var output = Data()
            output.append(s)
            output.append(Data(result))

            CryptoUtil.logger.debug("ENCODED data: \(output.hexString())")
            return output
        } catch {
            CryptoUtil.logger.error("Failed to encrypt data: \(error)")
            return Data()
        }
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
            let iv = try AES._CBC.IV(ivBytes: aesIV)
            decryptedData = try AES._CBC.decrypt(
                encryptedBytes,
                using: aesKey,
                iv: iv
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
            let iv = try AES._CBC.IV(ivBytes: aesIV)

            let decryptedData = try AES._CBC.decrypt(
                encryptedBytes,
                using: aesKey,
                iv: iv
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
