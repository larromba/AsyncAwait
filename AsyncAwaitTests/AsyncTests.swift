@testable import AsyncAwait
import TestExtensions
import XCTest

final class AsyncTests: XCTestCase {
    func testAsyncCallbackIsNotOnMainThread() {
        async({
            XCTAssertFalse(Thread.isMainThread)
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: 0.1, completion: nil)
    }
}
