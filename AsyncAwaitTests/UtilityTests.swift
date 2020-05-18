@testable import AsyncAwait
import TestExtensions
import XCTest

final class UtilityTests: XCTestCase {
    func test_onMainConvenience_whenCalled_expectMainThread() {
        waitAsync { completion in
            // sut
            onMain {
                // test
                XCTAssertTrue(Thread.isMainThread)
                completion()
            }
        }
    }
}
