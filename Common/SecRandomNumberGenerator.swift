struct SecRandomNumberGenerator: RandomNumberGenerator {
    func next() -> UInt64 {
        let size = MemoryLayout<UInt64>.size
        var data = Data(count: size)
        return data.withUnsafeMutableBytes {
            guard 0 == SecRandomCopyBytes(kSecRandomDefault, size, $0.baseAddress!) else { fatalError() }
            return $0.load(as: UInt64.self)
        }
    }
}
