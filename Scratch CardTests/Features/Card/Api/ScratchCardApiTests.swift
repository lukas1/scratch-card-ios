import Foundation
import Testing

struct ScratchCardApiTests {
    @Test(arguments: ["6.1.1", "6.2", "6.10", "6.1.10", "7"])
    func `GIVEN a version above the threshold WHEN activated THEN activation succeeds`(version: String) async {
        await assertActivation(version: version, expectedError: nil)
    }

    @Test(arguments: ["5.99", "6", "6.0", "6.1", "6.1.0", "6.1.0.0"])
    func `GIVEN a version at or below the threshold WHEN activated THEN activation is rejected`(version: String) async {
        await assertActivation(version: version, expectedError: .unsupportedVersion(version))
    }

    @Test(arguments: ["", "6..2", "6.a", "6.1.", "-6.2", "+6.2", "999999999999999999999999"])
    func `GIVEN an invalid numeric version WHEN activated THEN the request fails`(version: String) async {
        await assertActivation(version: version, expectedError: .requestFailed)
    }

    private func assertActivation(version: String, expectedError: ActivationError?) async {
        let session = TestURLSession(responseData: Data("{\"ios\":\"\(version)\"}".utf8))
        let api = ScratchCardApi(
            restClient: RestApiClient(baseURL: session.baseURL, session: session.session)
        )

        do {
            try await api.activateCard(code: "SC-4829-7316")
            #expect(expectedError == nil)
        } catch {
            #expect(error == expectedError)
        }
    }
}
