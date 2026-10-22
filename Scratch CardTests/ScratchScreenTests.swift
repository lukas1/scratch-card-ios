import Testing
import SwiftUI
import ViewInspector
import Clocks
@testable import Scratch_Card

struct ScratchScreenTests {
    @MainActor
    @Test func `GIVEN a hidden code THEN reveal is enabled`() throws {
        let sut = makeSUT().view

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled() == false)
    }

    @MainActor
    @Test func `GIVEN a hidden code WHEN reveal time advances THEN the code is revealed`() async throws {
        let clock = TestClock()
        let sut = makeSUT(clock: clock).view

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
        #expect(!code.isEmpty)
        #expect(code != String(localized: .scratchCodeHidden))
        #expect(code != String(localized: .scratchCodeRevealing))
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN reveal starts again THEN the original reveal completes on time`() async throws {
        let clock = TestClock()
        let (module, sut) = makeSUT(clock: clock)

        module.scratchCardRepository.startReveal()
        await clock.advance(by: .seconds(1))
        module.scratchCardRepository.startReveal()
        await clock.advance(by: .milliseconds(999))

        #expect(
            try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchCode").text().string()
                == String(localized: .scratchCodeRevealing)
        )

        await clock.advance(by: .milliseconds(1))

        let code = try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchCode").text().string()
        #expect(code != String(localized: .scratchCodeRevealing))
    }

    @MainActor
    @Test func `GIVEN a revealed code THEN reveal is disabled`() throws {
        let sut = makeSUT(card: .scratched("SC-4829-7316")).view

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }

    @MainActor
    private func makeSUT(
        card: CardState = .unscratched,
        clock: any Clock<Duration> = ContinuousClock()
    ) -> (module: ScratchCardModule, view: ScratchScreenContent) {
        let module = ScratchCardModule(clock: clock)
        module.scratchCardRepository.card = card
        return (module, ScratchScreenContent(module: module))
    }
}
