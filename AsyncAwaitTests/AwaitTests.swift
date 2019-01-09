@testable import AsyncAwait
import TestExtensions
import XCTest

final class AwaitTests: XCTestCase {
    private enum AwaitError: Error {
        case mock
    }

    func testAwaitReturnsValueAndCompletesSuccessfully() {
        waitAsync { completion in
            // sut
            async({
                // test
                var number = try await(self.asyncFunction(delay: 0.1))
                number += try await(self.asyncFunction(delay: 0.1))
                XCTAssertEqual(number, 2)
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func testAwaitCatchesError() {
        waitAsync { completion in
            // sut
            async({
                _ = try await(self.asyncFunction(delay: 0.1, isError: true))
                XCTFail("shouldn't be reached")
                completion()
            }, onError: { _ in
                // test
                completion()
            })
        }
    }

    func testAwaitCanBeNested() {
        waitAsync { completion in
            // sut
            async({
                // test
                _ = try await(self.asyncFunctionNested(delay: 0.1))
                completion()
            }, onError: { error in
                XCTFail(error.localizedDescription)
                completion()
            })
        }
    }

    func testAwaitAll() {
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

    func testAwaitAllIgnoresError() {
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

    func testAwaitAllCanBailEarly() {
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

    func testAwaitAllProgress() {
        // mocks
        var progress = [Double]()

        waitAsync { completion in
            // sut
            async({
                // test
                _ = try awaitAll([self.asyncFunction(delay: 0.1),
                                  self.asyncFunction(delay: 0.2),
                                  self.asyncFunction(delay: 0.3),
                                  self.asyncFunction(delay: 0.4),
                                  self.asyncFunction(delay: 0.45)],
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
            }, onError: { error in
                completion(.failure(error))
            })
        }
    }
}
