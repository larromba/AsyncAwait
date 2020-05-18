@testable import AsyncAwait
import TestExtensions
import XCTest

final class AwaitTests: XCTestCase {
    private enum AwaitError: Error {
        case mock
    }

    func test_whenAwaitCalled_expectValueAndNoError() {
        waitAsync { completion in
            // sut
            async({
                // test
                var number = try await(self.asyncFunction())
                number += try await(self.asyncFunction())
                XCTAssertEqual(number, 2)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_whenAwaitCalled_expectError() {
        waitAsync { completion in
            // sut
            async({
                _ = try await(self.asyncFunction(isError: true))
                XCTFail("shouldn't be reached")
                completion()
            }, onError: { _ in
                // test
                completion()
            })
        }
    }

    func test_whenAwaitCalled_expectThreadOnBackground() {
        waitAsync { completion in
            // sut
            async({
                // test
                _ = try await(self.asyncFunction())
                XCTAssertFalse(Thread.isMainThread)
                completion()
            }, onError: { _ in
                XCTFail("shouldn't be reached")
                completion()
            })
        }
    }

    func test_whenAwaitCalled_expectErrorThrownOnMainThread() {
        waitAsync { completion in
            // sut
            async({
                _ = try await(self.asyncFunction(isError: true))
                XCTFail("shouldn't be reached")
                completion()
            }, onError: { _ in
                // test
                XCTAssertTrue(Thread.isMainThread)
                completion()
            })
        }
    }

    func test_whenNestedAwaitCalled_expectNoError() {
        waitAsync { completion in
            // sut
            async({
                // test
                _ = try await(self.asyncFunctionNested())
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_whenAwaitAllCalled_expectNoError() {
        waitAsync { completion in
            // sut
            async({
                // test
                let results = try awaitAll([self.asyncFunction(delay: 0.1),
                                            self.asyncFunction(delay: 0.2),
                                            self.asyncFunction(delay: 0.3)])
                XCTAssertEqual(results.0.count, 3)
                XCTAssertEqual(results.1.count, 0)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_whenAwaitAllCalled_expectIgnoresSingleError() {
        waitAsync { completion in
            // sut
            async({
                // test
                let results = try awaitAll([self.asyncFunction(delay: 0.1),
                                            self.asyncFunction(delay: 0.2, isError: true),
                                            self.asyncFunction(delay: 0.3)])
                XCTAssertEqual(results.0.count, 2)
                XCTAssertEqual(results.1.count, 1)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_whenAwaitAllCalledWithBailEarly_expectError() {
        waitAsync { completion in
            // sut
            async({
                _ = try awaitAll([self.asyncFunction(delay: 0.1),
                                  self.asyncFunction(delay: 0.2, isError: true),
                                  self.asyncFunction(delay: 0.3)],
                                 bailEarly: true)
                XCTFail("shouldn't be reached")
                completion()
            }, onError: { _ in
                // test
                completion()
            })
        }
    }

    func test_whenAwaitAllCalled_expectProgressUpdates() {
        // mocks
        var progress = [Double]()

        waitAsync(for: 1.0) { completion in
            // sut
            async({
                // test
                _ = try awaitAll([self.asyncFunction(delay: 0.1),
                                  self.asyncFunction(delay: 0.2),
                                  self.asyncFunction(delay: 0.3),
                                  self.asyncFunction(delay: 0.4),
                                  self.asyncFunction(delay: 0.5)],
                                 progress: { progress += [$0] })
                XCTAssertEqual(progress, [1.0 / 5.0, 2.0 / 5.0, 3.0 / 5.0, 4.0 / 5.0, 5.0 / 5.0])
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    // MARK: - private

    private func asyncFunction(delay: TimeInterval = 0, isError: Bool = false) -> Async<Int> {
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

    private func asyncFunctionNested(delay: TimeInterval = 0) -> Async<String> {
        return Async { completion in
            async({
                let value = try await(self.asyncFunction(delay: delay))
                completion(.success("\(value)"))
            }, onError: { error in
                completion(.failure(error))
            })
        }
    }
}
