import Clocks
import SwiftUI
import Testing
import ViewInspector

struct ContentViewActivationTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test(arguments: ["6.1.1", "6.2", "6.10", "6.1.10", "7"])
    func `GIVEN a version above the threshold WHEN activated THEN the card is activated`(version: String) async throws {
        let sut = await makeSUT(testSession: versionSession(version))

        try await activate(from: sut)

        let activatedStatus = String(localized: .cardStatusActivated)
        #expect(try await waitUntilExists {
            try sut.inspect().find(text: activatedStatus)
        })

        #expect(try sut.inspect().find(text: activatedStatus).string() == activatedStatus)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
        #expect((try? sut.inspect().find(ViewType.Alert.self)) == nil)
    }

    @MainActor
    @Test(arguments: ["5.99", "6", "6.0", "6.1", "6.1.0", "6.1.0.0"])
    func `GIVEN a version at or below the threshold WHEN activated THEN the failure alert is shown`(version: String) async throws {
        let sut = await makeSUT(testSession: versionSession(version))

        try await activate(from: sut)

        try await assertAlert(in: sut, message: String(localized: .activationErrorFailed))
    }

    @MainActor
    @Test(arguments: ["", "6..2", "6.a", "6.1.", "-6.2", "+6.2", "999999999999999999999999", "unknown"])
    func `GIVEN an invalid numeric version WHEN activated THEN the unexpected error alert is shown`(version: String) async throws {
        let sut = await makeSUT(testSession: versionSession(version))

        try await activate(from: sut)

        try await assertAlert(in: sut, message: String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation request fails WHEN activated THEN an alert with the unexpected error message is shown`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503))

        try await activate(from: sut)

        try await assertAlert(in: sut, message: String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation is running WHEN the sheet closes before failure THEN the root alert is shown`() async throws {
        let responseGate = TestResponseGate()
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503, responseGate: responseGate))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()
        let sheet = try sut.inspect().navigationStack().sheet()
        try sheet.find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        await responseGate.waitUntilRequested()
        try sheet.dismiss()
        await responseGate.resumeResponses()

        #expect(try await waitUntilExists {
            try sut.inspect().navigationStack().alert()
        })

        let alert = try sut.inspect().navigationStack().alert()
        #expect(try alert.title().string() == String(localized: .activationErrorTitle))
        #expect(try alert.message().text().string() == String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation is running WHEN the sheet closes before success THEN the card is activated`() async throws {
        let responseGate = TestResponseGate()
        let sut = await makeSUT(testSession: TestURLSession(responseGate: responseGate))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()
        let sheet = try sut.inspect().navigationStack().sheet()
        try sheet.find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        await responseGate.waitUntilRequested()
        try sheet.dismiss()
        await responseGate.resumeResponses()

        let activatedStatus = String(localized: .cardStatusActivated)
        #expect(try await waitUntilExists {
            try sut.inspect().find(text: activatedStatus)
        })

        #expect(try sut.inspect().find(text: activatedStatus).string() == activatedStatus)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN an activation error alert WHEN dismissed THEN the alert is no longer shown`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503))

        try await activate(from: sut)
        try await assertAlert(in: sut, message: String(localized: .activationErrorUnexpected))
        try sut.inspect().find(ViewType.Alert.self).actions().button(0).tap()

        #expect((try? sut.inspect().find(ViewType.Alert.self)) == nil)
    }

    @MainActor
    private func makeSUT(
        testSession: TestURLSession? = nil
    ) async -> ContentViewContent {
        let clock = TestClock()
        let injector = SharedInjector(
            clock: clock,
            codeGenerator: { expectedCode },
            testSession: testSession ?? TestURLSession()
        )
        let sut = ContentViewContent(injector: injector)
        let scratching = Task { await injector.scratchCardModule.scratchCardRepository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await scratching.value
        return sut
    }

    @MainActor
    private func activate(from sut: ContentViewContent) async throws {
        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()
        try sut.inspect().navigationStack().sheet().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
    }

    @MainActor
    private func assertAlert(in sut: ContentViewContent, message: String) async throws {
        #expect(try await waitUntilExists {
            try sut.inspect().find(ViewType.Alert.self)
        })

        let alert = try sut.inspect().find(ViewType.Alert.self)
        #expect(try alert.title().string() == String(localized: .activationErrorTitle))
        #expect(try alert.message().text().string() == message)
    }

    private func versionSession(_ version: String) -> TestURLSession {
        TestURLSession(responseData: Data("{\"ios\":\"\(version)\"}".utf8))
    }
}
