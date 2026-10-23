import Foundation

enum ActivationError: Error, Equatable {
    case requestFailed
    case unsupportedVersion(String)

    var message: String {
        switch self {
        case .requestFailed: String(localized: .activationErrorUnexpected)
        case .unsupportedVersion: String(localized: .activationErrorFailed)
        }
    }
}

struct ScratchCardApi {
    private static let activationVersionThreshold = NumericVersion(components: [6, 1])

    private let restClient: RestApiClient

    init(restClient: RestApiClient) {
        self.restClient = restClient
    }

    func activateCard(code: String) async throws(ActivationError) {
        do {
            let payload: ActivationVersion = try await restClient.request(
                method: .get,
                path: "version",
                queryItems: [URLQueryItem(name: "code", value: code)]
            )
            guard let version = NumericVersion(payload.ios) else {
                throw ActivationError.requestFailed
            }
            guard version.isLater(than: Self.activationVersionThreshold) else {
                throw ActivationError.unsupportedVersion(payload.ios)
            }
        } catch let error as ActivationError {
            throw error
        } catch {
            throw ActivationError.requestFailed
        }
    }
}

private struct ActivationVersion: Decodable {
    let ios: String
}

private struct NumericVersion {
    let components: [Int]

    init(components: [Int]) {
        self.components = components
    }

    init?(_ value: String) {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        let components = parts.compactMap { part -> Int? in
            guard !part.isEmpty, part.utf8.allSatisfy({ (48...57).contains($0) }) else {
                return nil
            }
            return Int(part)
        }
        guard !parts.isEmpty, components.count == parts.count else { return nil }
        self.components = components
    }

    func isLater(than other: Self) -> Bool {
        for index in 0..<max(components.count, other.components.count) {
            let left = index < components.count ? components[index] : 0
            let right = index < other.components.count ? other.components[index] : 0
            if left != right { return left > right }
        }
        return false
    }
}
