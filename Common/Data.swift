extension Data {
    init?(hexString: String) {
        guard hexString.count.isMultiple(of: 2) else {
            return nil
        }

        let chars = hexString.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }

        guard hexString.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }

    func hexString() -> String {
        let format = "%02hhx"
        return map { String(format: format, $0) }.joined()
    }

    func base64Safe() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
    }

    static func randomSecure(length: Int) -> Data {
        var randomNumberGenerator = SecRandomNumberGenerator()
        return Data((0 ..< length).map { _ in UInt8.random(in: UInt8.min ... UInt8.max, using: &randomNumberGenerator) })
    }

    func toUInt64() -> UInt64 {
        guard count <= 8 else {
            preconditionFailure("Cannot convert Data to UInt64, size too long")
        }

        var result: UInt64 = 0
        for i in 0 ..< count {
            let shifted = UInt64(self[i]) << (8 * i)
            result |= shifted
        }

        return result
    }

    func toInt64() -> Int64 {
        guard count <= 8 else {
            preconditionFailure("Cannot convert Data to Int64, size too long")
        }

        var result: Int64 = 0
        for i in 0 ..< count {
            let shifted = Int64(self[i]) << (8 * i)
            result |= shifted
        }

        return result
    }
}

extension UInt64 {
    func toData(length: Int) -> Data {
        var output = Data(count: length)
        for i in 0 ..< length {
            output[i] = UInt8((self >> (i * 8)) & 0xFF)
        }

        return output
    }
}

extension Int64 {
    func toData(length: Int) -> Data {
        var output = Data(count: length)
        for i in 0 ..< length {
            output[i] = UInt8((self >> (i * 8)) & 0xFF)
        }

        return output
    }
}
