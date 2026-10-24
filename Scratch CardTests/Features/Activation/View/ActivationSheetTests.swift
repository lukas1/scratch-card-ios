import Foundation
import Testing
import ViewInspector
import Clocks

struct ActivationSheetTests {
    @MainActor
    @Test func `GIVEN no revealed code THEN activation is disabled`() throws {
        let module = ScratchCardModule(testSession: TestURLSession())
        let sut = ActivationSheetContent(module: module)

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
        let sut = ActivationSheetContent(module: module)
        let scratching = Task { await model.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await scratching.value

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()
        await Task.yield()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationProgress").isResponsive())
        #expect(try await waitUntil { !model.isActivating })
    }

    @MainActor
    @Test func `GIVEN a revealed code WHEN activation succeeds THEN the button shows activated`() async throws {
        let clock = TestClock()
        let module = ScratchCardModule(
            clock: clock,
            codeGenerator: { "SC-4829-7316" },
            testSession: TestURLSession()
        )
        let sut = ActivationSheetContent(module: module)
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

    @MainActor
    @Test func `GIVEN a revealed code WHEN activation fails THEN the button still shows activate`() async throws {
        let clock = TestClock()
        let module = ScratchCardModule(
            clock: clock,
            codeGenerator: { "SC-4829-7316" },
            testSession: TestURLSession(statusCode: 503)
        )
        let repository = module.scratchCardRepository
        let sut = ActivationSheetContent(module: module)
        let scratching = Task { await repository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await scratching.value

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()

        #expect(try await waitUntil { !repository.isActivating })

        #expect(try sut.inspect().find(text: String(localized: .activationActionActivate)).string() == String(localized: .activationActionActivate))
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled() == false)
    }
}
