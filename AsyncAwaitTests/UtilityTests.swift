@testable import AsyncAwait
import TestExtensions
import XCTest

final class UtilityTests: XCTestCase {
    func testOnMainExecutesCallbackOnMainThread() {
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
