// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation

@discardableResult
public func await<T, U: Error>(_ operation: Async<T, U>) throws -> T {
    var result: Result<T, U>?
    let group = DispatchGroup()

    group.enter()
    operation.completion { item in
        result = item
        group.leave()
    }
    if result == nil { // edge case: ensure group.leave() never called before group.wait()
        group.wait()
    }

    switch result {
    case .success(let item):
        return item
    case .failure(let error):
        throw error
    case .none:
        fatalError("result should not be nil")
    }
}

@discardableResult
public func awaitAll<T, U: Error>(_ operations: [Async<T, U>], bailEarly: Bool = false,
                                  progress: ((Double) -> Void)? = nil) throws -> [Result<T, U>] {
    let results = AtomicVariable<[Result<T, U>]>([])
    let group = DispatchGroup()
    var isBailed = false

    for operation in operations {
        group.enter()
        operation.completion { result in
            guard !isBailed else { return }

            results.mutate { results in
                results += [result]
            }
            progress?(Double(results.value.count) / Double(operations.count))

            switch result {
            case .success:
                break
            case .failure:
                guard !bailEarly else {
                    isBailed = true
                    ((results.value.count - 1)..<operations.count).forEach { _ in group.leave() }
                    return
                }
            }
            group.leave()
        }
    }
    if results.value.count != operations.count { // edge case: ensure all group.leave() never called before group.wait()
        group.wait()
    }

    guard !isBailed else {
        switch results.value.last {
        case .failure(let error):
            throw error
        default:
            assertionFailure("AsyncAwait Internal Error: if isBailed == true, the last result should be an error")
            return []
        }
    }
    return results.value
}
