import Testing
import SwiftUI
import ViewInspector

struct HomeScreenTests {
    @MainActor
    @Test func `GIVEN an unscratched card THEN scratch is enabled and activation is disabled`() throws {
        let (_, sut) = makeSUT()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().isDisabled() == false)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN an unscratched card WHEN scratch is tapped THEN scratch navigation is pushed`() throws {
        let (injector, sut) = makeSUT()

        try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().tap()

        #expect(injector.globalModule.navigation.path == [.scratch])
    }

    @MainActor
    @Test func `GIVEN a scratched card WHEN activation is tapped THEN activation sheet is presented`() throws {
        let (injector, sut) = makeSUT(card: .scratched("SC-4829-7316"))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()

        #expect(injector.globalModule.navigation.sheet == .activation)
    }

    @MainActor
    @Test func `GIVEN a card WHEN reset is tapped THEN the card returns to unscratched`() throws {
        let (injector, sut) = makeSUT(card: .activated("SC-4829-7316"))

        try sut.inspect().find(viewWithAccessibilityIdentifier: "resetCardButton").button().tap()

        #expect(injector.scratchCardModule.scratchCardRepository.card == .unscratched)
    }

    @MainActor
    private func makeSUT(card: CardState = .unscratched) -> (injector: SharedInjector, sut: HomeScreenContent) {
        let injector = makeInjector(card: card)
        return (injector, HomeScreenContent(module: injector.homeModule))
    }
}
