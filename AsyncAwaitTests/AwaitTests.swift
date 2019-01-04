@testable import AsyncAwait
import TestExtensions
import XCTest

final class AwaitTests: XCTestCase {
    private enum AwaitError: Error {
        case mock
    }

    func testAwaitReturnsValueAndCompletesSuccessfully() {
        let delay = 1.0
        let expectation = self.expectation(description: "await waits and completes")
        async({
            var number = try await(self.asyncFunction(delay: delay))
            number += try await(self.asyncFunction(delay: delay))
            XCTAssertEqual(number, 2)
            expectation.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: (delay * 2) + 0.5, completion: nil)
    }

    func testAwaitCatchesError() {
        let delay = 1.0
        let expectation = self.expectation(description: "await throws error")
        async({
            _ = try await(self.asyncFunction(delay: delay, isError: true))
            XCTFail("shouldn't be reached")
        }, onError: { _ in
            expectation.fulfill()
        })
        wait(for: delay + 0.5, completion: nil)
    }

    func testAwaitCanBeNested() {
        let delay = 1.0
        let expectation = self.expectation(description: "await waits and completes")
        async({
            _ = try await(self.asyncFunctionNested(delay: delay))
            expectation.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: delay + 0.5, completion: nil)
    }

    func testAwaitAll() {
        let delay = 1.0
        let expectation = self.expectation(description: "await waits and completes")
        async({
            let results = try awaitAll([self.asyncFunction(delay: delay),
                                        self.asyncFunction(delay: delay + 0.1),
                                        self.asyncFunction(delay: delay + 0.2)])
            XCTAssertEqual(results.0.count, 3)
            XCTAssertEqual(results.1.count, 0)
            expectation.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: delay + 0.5, completion: nil)
    }

    func testAwaitAllIgnoresError() {
        let delay = 1.0
        let expectation = self.expectation(description: "await waits and completes")
        async({
            let results = try awaitAll([self.asyncFunction(delay: delay),
                                        self.asyncFunction(delay: delay + 0.1, isError: true),
                                        self.asyncFunction(delay: delay + 0.2)])
            XCTAssertEqual(results.0.count, 2)
            XCTAssertEqual(results.1.count, 1)
            expectation.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: delay + 0.5, completion: nil)
    }

    func testAwaitAllCanBailEarly() {
        let delay = 1.0
        let expectation = self.expectation(description: "await throws error")
        async({
            _ = try awaitAll([self.asyncFunction(delay: delay),
                              self.asyncFunction(delay: delay + 0.1, isError: true),
                              self.asyncFunction(delay: delay + 0.2)],
                             bailEarly: true)
            XCTFail("shouldn't be reached")
        }, onError: { _ in
            expectation.fulfill()
        })
        wait(for: delay + 0.5, completion: nil)
    }

    func testAwaitAllProgress() {
        let delay = 0.1
        let expectation = self.expectation(description: "await throws error")
        var progress = [Double]()
        async({
            _ = try awaitAll([self.asyncFunction(delay: delay),
                              self.asyncFunction(delay: delay + 0.1),
                              self.asyncFunction(delay: delay + 0.2),
                              self.asyncFunction(delay: delay + 0.3),
                              self.asyncFunction(delay: delay + 0.4)],
                             progress: { progress += [$0] })
            XCTAssertEqual(progress, [1.0 / 5.0, 2.0 / 5.0, 3.0 / 5.0, 4.0 / 5.0, 5.0 / 5.0])
            expectation.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        wait(for: (delay + 0.5) + 0.5, completion: nil)
    }

    // MARK: - private

    private func asyncFunction(delay: TimeInterval, isError: Bool = false) -> Async<Int> {
        return Async { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: {
                if isError {
                    completion(.failure(AwaitError.mock))
                } else {
                    completion(.success(1))
                }
            })
        }
    }

    private func asyncFunctionNested(delay: TimeInterval) -> Async<String> {
        return Async { completion in
            async({
                let value = try await(self.asyncFunction(delay: delay))
                completion(.success("\(value)"))
            }, onError: { _ in
                completion(.failure(AwaitError.mock))
            })
        }
    }
}
