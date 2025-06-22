//
//  CryptoUtil.swift
//  EversenseKit
//
//  Created by Bastiaan Verhaar on 16/06/2025.
//

import Crypto
import _CryptoExtras

enum CryptoUtil {
    private static let logger = EversenseLogger(category: "CryptoUtil")
    
    private static let publicKey = "-----BEGIN PUBLIC KEY-----\n" +
        "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEL67Un32stnX4wX8rNYpH9zsu+PFJ\n" +
        "kRDJg5gpOVobGb5e2fazOZ2DDhCqpgMfgUm1P/2HuZhWRJvwSrV402p4gA==\n" +
        "-----END PUBLIC KEY-----"
    private static let aesKey = SymmetricKey(data: Array("XdHC2ni9oKcd1D5f".utf8))
    private static let aesIV = Array("9u4CzyxzQ4884yZL".utf8)
    
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
    
    static func generateSignature(sessionKey: SymmetricKey, data: Data) -> Data {
        let result = HMAC<SHA256>.authenticationCode(for: data, using: sessionKey)
        return Data(result).subdata(in: 0..<8)
    }
    
    private static func getPublicKey() -> P256.KeyAgreement.PublicKey? {
        do {
            return try P256.KeyAgreement.PublicKey(pemRepresentation: publicKey)
        } catch {
            logger.error("Failed to load public key: \(error)")
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
    
    private static func getSharedSecret(from privateKey: P256.KeyAgreement.PrivateKey, with publicKey: P256.KeyAgreement.PublicKey) -> SharedSecret? {
        do {
            return try privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        } catch {
            logger.error("Failed to get shared secret: \(error)")
            return nil
        }
    }
    
    private static func deriveSessionKey(sharedSecret: SharedSecret, salt: Data) -> SymmetricKey {
        return sharedSecret.x963DerivedSymmetricKey(
            using: SHA256.self,
            sharedInfo: salt,
            outputByteCount: 32
        )
    }
}
