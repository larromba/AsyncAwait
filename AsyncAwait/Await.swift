// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation

@discardableResult
public func await<T>(_ operation: Async<T>) throws -> T {
    var value: T!
    var error: Error?
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
public func awaitAll<T>(_ operations: [Async<T>], bailEarly: Bool = false,
                        progress: ((Double) -> Void)? = nil) throws -> ([T], [Error]) {
    var values = [T]()
    var errors = [Error]()
    let group = DispatchGroup()
    var isBailed = false

    for operation in operations {
        group.enter()
        operation.completion { result in
            guard !isBailed else { return }
            switch result {
            case .success(let resultValue):
                values += [resultValue]
                // TODO: if many operations complete at exactly the same time, maybe this won't work as expected?
                progress?(Double(values.count + errors.count) / Double(operations.count))
            case .failure(let resultError):
                errors += [resultError]
                guard !bailEarly else {
                    isBailed = true
                    (values.count..<operations.count).forEach { _ in group.leave() }
                    return
                }
            }
            group.leave()
        }
    }
    group.wait()

    guard !isBailed else { throw errors[0] }
    return (values, errors)
}
