@testable import AsyncAwait
import TestExtensions
import XCTest

final class AsyncTests: XCTestCase {
    func test_asyncCallback_whenFired_expectNotOnMainThread() {
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

    func test_asyncSuccessConvenience_whenCalled_expectValue() {
        // mocks
        let item = "a string"

        // sut
        let async = Async<String, Error>.success(item)

        // test
        let result = try? await(async)
        XCTAssertEqual(item, result)
    }

    func test_asyncFailureConvenience_whenCalled_expectError() {
        // mocks
        let error = NSError(domain: "domain", code: 0, userInfo: nil)

        // sut
        let async = Async<String, Error>.failure(error)

        // test
        do {
            try await(async)
            XCTFail("expected error")
        } catch let nsError as NSError {
            XCTAssertEqual(nsError, error)
        } catch {
            XCTFail("expected NSError")
        }
    }
}
