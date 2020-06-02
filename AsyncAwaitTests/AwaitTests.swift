@testable import AsyncAwait
import TestExtensions
import XCTest

final class AwaitTests: XCTestCase {
    private enum AwaitError: Error {
        case mock
    }

    func test_await_whenCalled_expectValue() {
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

    func test_await_whenCalled_expectError() {
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

    func test_await_whenCalled_expectThreadStaysOnBackground() {
        waitAsync { completion in
            // sut
            async({
                // test
                XCTAssertFalse(Thread.isMainThread)
                _ = try await(self.asyncFunction())
                XCTAssertFalse(Thread.isMainThread)
                completion()
            }, onError: { _ in
                XCTFail("shouldn't be reached")
                completion()
            })
        }
    }

    func test_await_whenCalled_expectErrorThrownOnMainThread() {
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

    func test_await_whenNestedFunctionCalled_expectValue() {
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

    func test_await_whenWrappedSyncCodeCalled_expectNoDeadlock() {
        waitAsync { completion in
            // sut
            async({
                // test
                _ = try await(self.asyncFunctionWrappingSyncCode())
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    // MARK: - await all

    func test_awaitAll_whenCalled_expectValue() {
        waitAsync { completion in
            // sut
            async({
                // test
                let results = try awaitAll([self.asyncFunction(delay: 0.1),
                                            self.asyncFunction(delay: 0.2),
                                            self.asyncFunction(delay: 0.3)])
                XCTAssertEqual(results.compactMap { $0.getValue() }.count, 3)
                XCTAssertEqual(results.compactMap { $0.getError() }.count, 0)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_awaitAll_whenCalled_expectIgnoresSingleError() {
        waitAsync { completion in
            // sut
            async({
                // test
                let results = try awaitAll([self.asyncFunction(delay: 0.1),
                                            self.asyncFunction(delay: 0.2, isError: true),
                                            self.asyncFunction(delay: 0.3)])
                XCTAssertEqual(results.compactMap { $0.getValue() }.count, 2)
                XCTAssertEqual(results.compactMap { $0.getError() }.count, 1)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func test_awaitAll_whenCalledWithBailEarlyFlag_expectError() {
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

    func test_awaitAll_whenCalled_expectProgressUpdates() {
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

    func test_awaitAll_whenWrappedSyncCodeCalled_expectNoDeadlock() {
        waitAsync(for: 2.0) { completion in
            // sut
            async({
                // test
                let functions = (0..<10).flatMap { _ in [self.syncCode()] }
                _ = try awaitAll(functions)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    // MARK: - private

    private func asyncFunction(delay: TimeInterval = 0, isError: Bool = false) -> Async<Int, AwaitError> {
        return Async { completion in
            DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: {
                if isError {
                    completion(.failure(.mock))
                } else {
                    completion(.success(1))
                }
            })
        }
    }

    private func asyncFunctionNested(delay: TimeInterval = 0) -> Async<String, Error> {
        return Async { completion in
            async({
                let value = try await(self.asyncFunction(delay: delay))
                completion(.success("\(value)"))
            }, onError: { error in
                completion(.failure(error))
            })
        }
    }

    private func asyncFunctionWrappingSyncCode() -> Async<String, Error> {
        return Async { completion in
            async({
                let value = try await(self.syncCode())
                completion(.success("\(value)"))
            }, onError: { error in
                completion(.failure(error))
            })
        }
    }

    private func syncCode() -> Async<String, Error> {
        return Async { completion in
            async({
                completion(.success(""))
            }, onError: { error in
                completion(.failure(error))
            })
        }
    }
}
