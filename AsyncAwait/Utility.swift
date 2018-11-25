import Foundation

public func onMain(callback: @escaping () -> Void) {
    DispatchQueue.main.async {
        callback()
    }
}
