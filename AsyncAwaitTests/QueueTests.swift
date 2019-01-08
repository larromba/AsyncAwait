@testable import AsyncAwait
import TestExtensions
import XCTest

final class QueueTests: XCTestCase {
    func testOnAsyncExecutesCallbackOnBackgroundThread() {
        let expectation = self.expectation(description: "callback executes")
        DispatchQueue.asyncAwait.async {
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        }
        wait(for: 0.5, completion: nil)
    }
}
