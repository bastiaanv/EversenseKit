@testable import EversenseKit
import Testing

struct CryptoUtilTests {
    private let fleetKey =
        "TbKPIUPSw0ZJQFGIGi1oiMwpI8y7UucXwQxgJzvCpdI5RSRSf8Mmz9aIEtgYkBdI2Xb+RUAMyAPgrHrutwLb4E7mRZb85NLRC/eK3WOJ8tX8lDeJKgFUVFYtfJqBCqL4LaOUugnsCUr3Wir6saDBw3lru1YiaT7B9e9SkKqXgB39KKTTBMahhyI7PpXw0YDhGAjihhkMLGfXLo7ckc+aj6KrAPI/j9vLQAtXXKykVICG6L3tVuEpMU3ZNUWR6pxfKh2aBU23pPZAgAOCr/gDB/YSUPQ6snbeUaEuamGJPIpz8/IuNtKsUSZUg+oTM3Im"

    @Test func generateSession() async throws {
        let result = CryptoUtil.generateSession(fleetKey: fleetKey)

        #expect(result != nil)
    }

    @Test func generateSignature() async throws {
        let result = CryptoUtil.generateSession(fleetKey: fleetKey)
        guard let result = result else {
            throw NSError(domain: "EMPTY result", code: 0, userInfo: nil)
        }

        let (sessionKey, salt) = result

        var data = Data([0x06, 0x02, 0x80, 0x00])
        data.append(salt)

        let signature = CryptoUtil.generateSignature(sessionKey: sessionKey, data: data)
        data.append(signature)
        #expect(data.count == 20)
    }

    @Test func decryptPublicKey() async throws {
        let kpTxUniqueId =
            "7vfAhYwjC+VFzA5Fe59OcYnnUMgVR6BJDa2KHl6AE2q2lLbgONl4HfJljN0AQwKtstDVWm3MFznKn2LgUn5q/bQ+gEojFjXOmiImFE3WZYENm5QK9Z4WszGQRT+WOrwLv0nNGY2AgDdlcRwmIk1Kp3ACXddzJFZB+KEQ3djAQS5zD+4unyhZUAHjg8CBk7tc"

        let result = CryptoUtil.decryptPublicKey(fleetKey: kpTxUniqueId)
        #expect(result != nil)
    }

    @Test func generateSalt() async throws {
        let count: Int64 = 1
        let salt = Data(hexString: "ff9f6b558126b96f")
        guard let salt = salt else {
            throw NSError(domain: "EMPTY salt", code: 0, userInfo: nil)
        }

        let x = (salt.toInt64() & Int64(-16384)) | count
        let data = x.toData(length: 8)
        #expect(data == Data(hexString: "01C09F6B558126B9"))
    }

    @Test func generateEncryptionSalt() async throws {
        let salt = Data(hexString: "a3fbb86fbf38dab8")
        guard let salt = salt else {
            throw NSError(domain: "EMPTY salt", code: 0, userInfo: nil)
        }

        let result = CryptoUtil.generateEncryptionSalt(salt: salt, i: 1)
        #expect(Data(hexString: "01c0b86fbf38dab8") == result)
    }

    @Test func testUnix() async throws {
        let x = Date().toUnix2000()
        let x2 = x.toHexString()
        print(x2)
    }
}
