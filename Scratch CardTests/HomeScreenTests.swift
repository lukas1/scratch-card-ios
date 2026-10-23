import Testing
import SwiftUI
import ViewInspector
import Clocks

struct HomeScreenTests {
    @MainActor
    @Test func `GIVEN an unscratched card THEN scratch is enabled and activation is disabled`() async throws {
        let (_, sut) = await makeSUT()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().isDisabled() == false)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN an unscratched card WHEN scratch is tapped THEN scratch navigation is pushed`() async throws {
        let (injector, sut) = await makeSUT()

        try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().tap()

        #expect(injector.globalModule.navigation.path == [.scratch])
    }

    @MainActor
    @Test func `GIVEN a scratched card WHEN activation is tapped THEN activation sheet is presented`() async throws {
        let (injector, sut) = await makeSUT(card: .scratched("SC-4829-7316"))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()

        #expect(injector.globalModule.navigation.sheet == .activation)
    }

    @MainActor
    @Test func `GIVEN a card WHEN reset is tapped THEN the card returns to unscratched`() async throws {
        let (injector, sut) = await makeSUT(card: .activated("SC-4829-7316"))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "resetCardButton").button().tap()

        #expect(injector.scratchCardModule.scratchCardRepository.card == .unscratched)
    }

    @MainActor
    private func makeSUT(card: CardState = .unscratched) async -> (injector: SharedInjector, sut: HomeScreenContent) {
        let clock = TestClock()
        let testSession = TestURLSession()
        let injector = SharedInjector(
            clock: clock,
            codeGenerator: { "SC-4829-7316" },
            testSession: testSession
        )
        if card != .unscratched {
            let task = Task { await injector.scratchCardModule.scratchCardRepository.scratchCard() }
            await Task.yield()
            await clock.advance(by: .seconds(2))
            await task.value
        }
        if card.isActivated {
            injector.scratchCardModule.scratchCardRepository.activateCard()
            for _ in 0..<100 where injector.scratchCardModule.scratchCardRepository.isActivating {
                try? await Task.sleep(for: .milliseconds(1))
            }
        }
        return (injector, HomeScreenContent(module: injector.homeModule))
    }
}
