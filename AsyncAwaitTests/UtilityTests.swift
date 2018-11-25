@testable import AsyncAwait
import TestExtensions
import XCTest

final class UtilityTests: XCTestCase {
    func testOnMainExecutesCallbackOnMainThread() {
        let expectation = self.expectation(description: "callback executes")
        onMain {
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }
        wait(for: 0.5, completion: nil)
    }
}
