import Foundation

private let asyncAwaitQueue = DispatchQueue(label: "async.queue", attributes: .concurrent)

public extension DispatchQueue {
    class var asyncAwait: DispatchQueue {
        return asyncAwaitQueue
    }
}
