import Foundation
import XCTest
#if DISPATCH_GROUP_STANDALONE
@testable import DispatchGroupSubject
#else
@testable import EversenseKit
#endif

final class DispatchGroupLifecycleTests: XCTestCase {
    // Run potentially blocking lock operations off the XCTest thread. The
    // standalone runner also bounds the whole test process as a final backstop.
    private func assertCompletes(_ operation: @escaping () -> Void,
                                 file: StaticString = #filePath, line: UInt = #line) {
        let completed = DispatchSemaphore(value: 0)
        DispatchQueue(label: "dispatch-group-lifecycle").async {
            operation()
            completed.signal()
        }
        XCTAssertEqual(completed.wait(timeout: .now() + 2), .success,
                       "Group operation must not deadlock", file: file, line: line)
    }

    func testBalancedLeavesWaitForEveryEnter() {
        assertCompletes {
            let group = EversenseKitDispatchGroup()
            XCTAssertEqual(group.wait(timeout: .now()), .success)
            group.enter()
            group.enter()
            XCTAssertEqual(group.wait(timeout: .now()), .timedOut)
            group.leave()
            XCTAssertEqual(group.wait(timeout: .now()), .timedOut)
            group.leave()
            XCTAssertEqual(group.wait(timeout: .now()), .success)
        }
    }

    func testDuplicateLeavesAllowReuseWithoutCountDrift() {
        assertCompletes {
            let group = EversenseKitDispatchGroup()
            for _ in 0..<20 {
                group.enter()
                XCTAssertEqual(group.wait(timeout: .now()), .timedOut)
                group.leave()
                group.leave()
                group.leave()
                XCTAssertEqual(group.wait(timeout: .now()), .success)
            }
        }
    }

    func testRepeatedSurplusLeavesOnFreshGroupAllowReuse() {
        assertCompletes {
            let group = EversenseKitDispatchGroup()
            group.leave()
            group.leave()
            group.enter()
            XCTAssertEqual(group.wait(timeout: .now()), .timedOut)
            group.leave()
            XCTAssertEqual(group.wait(timeout: .now()), .success)
        }
    }

    func testConcurrentLeavesAfterCompletedEnterAllowReuse() {
        assertCompletes {
            let group = EversenseKitDispatchGroup()
            // enter must finish before any leave starts; this deliberately
            // does not test the existing enter/group.enter ordering window.
            group.enter()
            DispatchQueue.concurrentPerform(iterations: 8) { _ in
                group.leave()
            }
            XCTAssertEqual(group.wait(timeout: .now()), .success)
            group.enter()
            XCTAssertEqual(group.wait(timeout: .now()), .timedOut)
            group.leave()
            XCTAssertEqual(group.wait(timeout: .now()), .success)
        }
    }

    func testSurplusLeaveDoesNotBlockNextEnter() {
        let group = EversenseKitDispatchGroup()
        group.leave()

        // The upstream bug leaves the NSLock locked. Never call enter on
        // the test thread: a failed regression must report, not hang XCTest.
        let completed = DispatchSemaphore(value: 0)
        DispatchQueue(label: "dispatch-group-regression").async {
            group.enter()
            group.leave()
            completed.signal()
        }
        XCTAssertEqual(completed.wait(timeout: .now() + 2), .success,
                       "Surplus leave must release the lock for the next enter")
    }
}
