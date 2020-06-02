// adapted from https://www.objc.io/blog/2018/12/18/atomic-variables/

import Foundation

final class AtomicVariable<A> {
    private let queue = DispatchQueue(label: "atomic variable serial queue")
    private var _value: A
    var value: A {
        return queue.sync { self._value }
    }

    init(_ value: A) {
        self._value = value
    }

    func mutate(_ transform: (inout A) -> Void) {
        queue.sync {
            transform(&self._value)
        }
    }
}
