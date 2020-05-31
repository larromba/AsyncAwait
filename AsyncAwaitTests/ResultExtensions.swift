import Foundation

extension Result {
    func getValue() -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    func getError() -> Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
