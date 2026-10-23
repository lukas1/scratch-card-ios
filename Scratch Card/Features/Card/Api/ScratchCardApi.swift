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
    static let activationVersionThreshold = 6.1

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
            guard let version = Double(payload.ios) else {
                throw ActivationError.requestFailed
            }
            guard version > Self.activationVersionThreshold else {
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
