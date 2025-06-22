extension Data {
    func hexString() -> String {
        let format = "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    static func randomSecure(length: Int) -> Data {
        var randomNumberGenerator = SecRandomNumberGenerator()
        return Data((0 ..< length).map { _ in UInt8.random(in: UInt8.min ... UInt8.max, using: &randomNumberGenerator) })
    }
}
