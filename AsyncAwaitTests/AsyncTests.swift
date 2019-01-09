@testable import AsyncAwait
import TestExtensions
import XCTest

final class AsyncTests: XCTestCase {
    func testAsyncCallbackIsNotOnMainThread() {
        waitAsync { completion in
            // sut
            async({
                // test
                XCTAssertFalse(Thread.isMainThread)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func testAsyncSuccessConvenience() {
        // mocks
        let item = "a string"

        // sut
        let async = Async.success(item)

        // test
        waitAsync { completion in
            let result = try? await(async)
            XCTAssertEqual(item, result)
            completion()
        }
    }

    func testAsyncFailureConvenience() {
        // mocks
        let error = NSError(domain: "domain", code: 0, userInfo: nil)

        // sut
        let async = Async<String>.failure(error)

        // test
        waitAsync { completion in
            do {
                try await(async)
                XCTFail("expected error")
                completion()
            } catch let nsError as NSError {
                XCTAssertEqual(nsError, error)
                completion()
            } catch {
                XCTFail("expected NSError")
                completion()
            }
        }
    }
}
