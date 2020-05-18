@testable import AsyncAwait
import TestExtensions
import XCTest

final class UtilityTests: XCTestCase {
    func test_whenOnMainConvenienceCalled_expectCodeOnMainThread() {
        waitAsync { completion in
            // sut
            onMain {
                // test
                XCTAssertTrue(Thread.isMainThread)
                completion()
            }
        }
    }
}
