import Clocks
import SwiftUI
import Testing
import ViewInspector

struct ContentViewActivationTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test func `GIVEN a scratched card WHEN activation succeeds THEN no alert is shown`() async throws {
        let sut = await makeSUT()

        try await activate(from: sut)

        #expect((try? sut.inspect().find(ViewType.Alert.self)) == nil)
    }

    @MainActor
    @Test func `GIVEN activation returns an unsupported version WHEN activated THEN an alert with the failure message is shown`() async throws {
        let sut = await makeSUT(
            testSession: TestURLSession(responseData: Data(#"{"ios":"6.1"}"#.utf8))
        )

        try await activate(from: sut)

        try assertAlert(in: sut, message: String(localized: .activationErrorFailed))
    }

    @MainActor
    @Test func `GIVEN activation returns an invalid version WHEN activated THEN an alert with the unexpected error message is shown`() async throws {
        let sut = await makeSUT(
            testSession: TestURLSession(responseData: Data(#"{"ios":"unknown"}"#.utf8))
        )

        try await activate(from: sut)

        try assertAlert(in: sut, message: String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation request fails WHEN activated THEN an alert with the unexpected error message is shown`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503))

        try await activate(from: sut)

        try assertAlert(in: sut, message: String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation is running WHEN the sheet closes before failure THEN the root alert is shown`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503, delay: .milliseconds(100)))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()
        let sheet = try sut.inspect().navigationStack().sheet()
        try sheet.find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        try sheet.dismiss()

        for _ in 0..<50 where (try? sut.inspect().navigationStack().alert()) == nil {
            try await Task.sleep(for: .milliseconds(20))
        }

        let alert = try sut.inspect().navigationStack().alert()
        #expect(try alert.title().string() == String(localized: .activationErrorTitle))
        #expect(try alert.message().text().string() == String(localized: .activationErrorUnexpected))
    }

    @MainActor
    @Test func `GIVEN activation is running WHEN the sheet closes before success THEN the card is activated`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(delay: .milliseconds(150)))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()
        let sheet = try sut.inspect().navigationStack().sheet()
        try sheet.find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        try sheet.dismiss()

        let activatedStatus = String(localized: .cardStatusActivated)
        for _ in 0..<100 where (try? sut.inspect().find(text: activatedStatus)) == nil {
            try await Task.sleep(for: .milliseconds(10))
        }

        #expect(try sut.inspect().find(text: activatedStatus).string() == activatedStatus)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN an activation error alert WHEN dismissed THEN the alert is no longer shown`() async throws {
        let sut = await makeSUT(testSession: TestURLSession(statusCode: 503))

        try await activate(from: sut)
        try sut.inspect().find(ViewType.Alert.self).actions().button(0).tap()

        #expect((try? sut.inspect().find(ViewType.Alert.self)) == nil)
    }

    @MainActor
    private func makeSUT(
        testSession: TestURLSession = TestURLSession()
    ) async -> ContentViewContent {
        let clock = TestClock()
        let injector = SharedInjector(
            clock: clock,
            codeGenerator: { expectedCode },
            testSession: testSession
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
        for _ in 0..<100 where (try? sut.inspect().find(ViewType.Alert.self)) == nil {
            await Task.yield()
        }
    }

    @MainActor
    private func assertAlert(in sut: ContentViewContent, message: String) throws {
        let alert = try sut.inspect().find(ViewType.Alert.self)
        #expect(try alert.title().string() == String(localized: .activationErrorTitle))
        #expect(try alert.message().text().string() == message)
    }
}
