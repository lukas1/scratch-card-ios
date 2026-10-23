import Testing
import SwiftUI
import ViewInspector
import Clocks

struct ScratchScreenTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test func `GIVEN a hidden code THEN reveal is enabled`() throws {
        let (sut, _) = makeSUT()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled() == false)
    }

    @MainActor
    @Test func `GIVEN a hidden code WHEN reveal time advances THEN the code is revealed`() async throws {
        let clock = TestClock()
        let (sut, _) = makeSUT(clock: clock)

        try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().tap()
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())

        await clock.advance(by: .milliseconds(1_999))

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealProgress").isResponsive())
        #expect(
            try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchCode").text().string()
                == String(localized: .scratchCodeRevealing)
        )

        await clock.advance(by: .milliseconds(1))

        let code = try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchCode").text().string()
        #expect(code == expectedCode)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN a revealed code THEN reveal is disabled`() async throws {
        let clock = TestClock()
        let (sut, module) = makeSUT(clock: clock)
        let reveal = Task { await module.scratchCardRepository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await reveal.value

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }

    @MainActor
    private func makeSUT(
        clock: any Clock<Duration> = ContinuousClock()
    ) -> (screen: ScratchScreenContent, module: ScratchCardModule) {
        let module = ScratchCardModule(clock: clock, codeGenerator: { expectedCode }, testSession: TestURLSession())
        return (ScratchScreenContent(module: module), module)
    }
}
