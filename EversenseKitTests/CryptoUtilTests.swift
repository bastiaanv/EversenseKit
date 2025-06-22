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
            #expect(false)
            return
        }

        let (sessionKey, salt) = result

        var data = Data([0x06, 0x02, 0x80, 0x00])
        data.append(salt)

        let signature = CryptoUtil.generateSignature(sessionKey: sessionKey, data: data)
        #expect(signature != nil)

        data.append(signature)
        #expect(data.count == 20)
    }
}
