extension Data {
    func hexString() -> String {
        let format = "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}
