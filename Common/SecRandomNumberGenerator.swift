struct SecRandomNumberGenerator: RandomNumberGenerator {
    func next() -> UInt64 {
        let size = MemoryLayout<UInt64>.size
        var data = Data(count: size)
        return data.withUnsafeMutableBytes {
            guard SecRandomCopyBytes(kSecRandomDefault, size, $0.baseAddress!) == 0 else { fatalError() }
            return $0.load(as: UInt64.self)
        }
    }
}
