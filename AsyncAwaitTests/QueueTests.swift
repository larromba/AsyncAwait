@testable import AsyncAwait
import TestExtensions
import XCTest

final class QueueTests: XCTestCase {
    func testOnAsyncExecutesCallbackOnBackgroundThread() {
        waitAsync { completion in
            // sut
            DispatchQueue.asyncAwait.async {
                // test
                XCTAssertFalse(Thread.isMainThread)
                completion()
            }
        }
    }
}
