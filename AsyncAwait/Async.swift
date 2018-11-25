// modified from "freshOS/then" https://github.com/freshOS/then/tree/master/Source

import Foundation
import Result

public func async(_ callback: @escaping () throws -> Void, onError: @escaping (Error) -> Void) {
    DispatchQueue(label: "async.queue", attributes: .concurrent).async {
        do {
            try callback()
        } catch {
            onError(error)
        }
    }
}

public struct Async<T> {
    public typealias Completion = (Result<T>) -> Void

    let completion: (@escaping Completion) -> Void

    public init(_ completion: @escaping (@escaping Completion) -> Void) {
        self.completion = completion
    }
}
