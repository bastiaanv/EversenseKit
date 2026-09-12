final class EversenseKitDispatchGroup {
    private let group = DispatchGroup()
    private let lock = NSLock()
    private var count = 0

    func enter() {
        lock.lock()
        count += 1
        lock.unlock()
        group.enter()
    }

    func leave() {
        lock.lock()
        defer { lock.unlock() }

        guard count > 0 else {
            // Ignore surplus leaves without changing the count or retaining
            // the lock, so subsequent operations can still use this group.
            return
        }

        count -= 1
        group.leave()
    }

    @discardableResult func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
        group.wait(timeout: timeout)
    }
}
