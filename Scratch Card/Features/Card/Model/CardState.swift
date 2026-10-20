enum CardState: Equatable {
    case unscratched
    case scratched(String)
    case activated(String)

    var code: String? {
        switch self {
        case .unscratched: nil
        case .scratched(let code), .activated(let code): code
        }
    }

    var isActivated: Bool {
        if case .activated = self { return true }
        return false
    }
}
