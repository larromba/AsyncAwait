// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation

public func async(_ callback: @escaping () throws -> Void, onError: @escaping (Error) -> Void,
                  throwErrorOnMain: Bool = false) {
    DispatchQueue.asyncAwait.async {
        do {
            try callback()
        } catch {
            throwErrorOnMain ? onMain { onError(error) } : onError(error)
        }
    }
}

public struct Async<T, U: Error> {
    public typealias Completion = (Result<T, U>) -> Void

    let completion: (@escaping Completion) -> Void

    public init(_ completion: @escaping (@escaping Completion) -> Void) {
        self.completion = completion
    }
}

public extension Async {
    static func success(_ item: T) -> Async<T, U> {
        return Async { completion in
            completion(.success(item))
        }
    }

    static func failure(_ error: U) -> Async<T, U> {
        return Async { completion in
            completion(.failure(error))
        }
    }
}
