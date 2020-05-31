// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation

// callback is called on background thread
// onError is called on main thread
public func async(_ callback: @escaping () throws -> Void, onError: @escaping (Error) -> Void) {
    DispatchQueue.asyncAwait.async {
        do {
            try callback()
        } catch {
            onMain { onError(error) }
        }
    }
}

public struct Async<Success, Failure> where Failure: Error {
    public typealias Completion = (Result<Success, Failure>) -> Void

    let completion: (@escaping Completion) -> Void

    public init(_ completion: @escaping (@escaping Completion) -> Void) {
        self.completion = completion
    }
}

public extension Async {
    static func success(_ item: Success) -> Async<Success, Failure> {
        return Async { completion in
            completion(.success(item))
        }
    }

    static func failure(_ error: Failure) -> Async<Success, Failure> {
        return Async { completion in
            completion(.failure(error))
        }
    }
}
