//
// Copyright (c) 2020 Rosberry. All rights reserved.
//

public enum LoadingStatus {
    case error(error: Error)
    case loading
    case idle

    public var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}

extension LoadingStatus: Equatable {
    public static func == (lhs: LoadingStatus, rhs: LoadingStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.idle, .idle):
            return true
        case (.error(let lError), .error(let rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}
