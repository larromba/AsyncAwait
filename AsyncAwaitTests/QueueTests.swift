@testable import AsyncAwait
import TestExtensions
import XCTest

final class QueueTests: XCTestCase {
    func test_whenDispatchQueueCalled_expectBackgroundThread() {
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
