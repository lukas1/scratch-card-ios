import Foundation
import Testing
import ViewInspector
import Clocks

struct ActivationScreenTests {
    @MainActor
    @Test func `GIVEN no revealed code THEN activation is disabled`() throws {
        let module = ScratchCardModule(testSession: TestURLSession())
        let sut = ActivationScreenContent(module: module)

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN a revealed code WHEN activation is tapped THEN activation starts and disables the button`() async throws {
        let testSession = TestURLSession(delay: .milliseconds(150))
        let clock = TestClock()
        let module = ScratchCardModule(
            clock: clock,
            codeGenerator: { "SC-4829-7316" },
            testSession: testSession
        )
        let model = module.scratchCardRepository
        let sut = ActivationScreenContent(module: module)
        let scratching = Task { await model.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await scratching.value

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        await Task.yield()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationProgress").isResponsive())
        for _ in 0..<100 where model.isActivating {
            try await Task.sleep(for: .milliseconds(5))
        }
    }

    @MainActor
    @Test func `GIVEN a revealed code WHEN activation succeeds THEN the button shows activated`() async throws {
        let clock = TestClock()
        let module = ScratchCardModule(
            clock: clock,
            codeGenerator: { "SC-4829-7316" },
            testSession: TestURLSession()
        )
        let sut = ActivationScreenContent(module: module)
        let scratching = Task { await module.scratchCardRepository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await scratching.value

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()

        for _ in 0..<100 where !module.scratchCardRepository.card.isActivated {
            await Task.yield()
        }

        #expect(try sut.inspect().find(text: String(localized: .activationActionActivated)).string() == String(localized: .activationActionActivated))
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
    }
}
