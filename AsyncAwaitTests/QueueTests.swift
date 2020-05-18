@testable import AsyncAwait
import TestExtensions
import XCTest

final class QueueTests: XCTestCase {
    func test_dispatchQueue_whenCalled_expectBackgroundThread() {
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
