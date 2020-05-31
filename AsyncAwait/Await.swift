// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation

@discardableResult
public func await<T, U: Error>(_ operation: Async<T, U>) throws -> T {
    var value: T!
    var error: U?
    let group = DispatchGroup()

    group.enter()
    operation.completion { result in
        switch result {
        case .success(let resultValue):
            value = resultValue
        case .failure(let resultError):
            error = resultError
        }
        group.leave()
    }
    group.wait()

    if let error = error { throw error }
    return value
}

@discardableResult
public func awaitAll<T, U: Error>(_ operations: [Async<T, U>], bailEarly: Bool = false,
                                  progress: ((Double) -> Void)? = nil) throws -> [Result<T, U>] {
    var results = [Result<T, U>]()
    let group = DispatchGroup()
    var isBailed = false

    for operation in operations {
        group.enter()
        operation.completion { result in
            guard !isBailed else { return }
            results += [result]
            progress?(Double(results.count) / Double(operations.count))
            switch result {
            case .success:
                break
            case .failure:
                guard !bailEarly else {
                    isBailed = true
                    ((results.count - 1)..<operations.count).forEach { _ in group.leave() }
                    return
                }
            }
            group.leave()
        }
    }
    group.wait()

    guard !isBailed else {
        switch results.last {
        case .failure(let error):
            throw error
        default:
            assertionFailure("AsyncAwait Internal Error: if isBailed == true, the last result should be an error")
            return []
        }
    }
    return results
}
