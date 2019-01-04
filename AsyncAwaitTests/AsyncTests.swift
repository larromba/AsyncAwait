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

    func testAsyncSuccessConvenience() {
        let item = "a string"
        let async = Async.success(item)
        let result = try? await(async)
        XCTAssertEqual(item, result)
    }

    func testAsyncFailureConvenience() {
        let expectedError = NSError(domain: "domain", code: 0, userInfo: nil)
        let async = Async<String>.failure(expectedError)
        do {
            try await(async)
            XCTFail("expected error")
        } catch let error as NSError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("expected NSError")
        }
    }
}
