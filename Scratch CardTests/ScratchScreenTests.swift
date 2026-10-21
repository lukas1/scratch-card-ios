import Testing
import SwiftUI
import ViewInspector
@testable import Scratch_Card

struct ScratchScreenTests {
    @MainActor
    @Test func `GIVEN a hidden code THEN reveal is enabled`() throws {
        let (_, sut) = makeSUT()

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled() == false)
    }

    @MainActor
    @Test func `GIVEN a hidden code WHEN reveal is tapped THEN revealing starts`() throws {
        let (injector, sut) = makeSUT()
        let repository = injector.scratchCardModule.scratchCardRepository

        try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().tap()
        defer { repository.cancelReveal() }

        #expect(repository.isRevealing)
    }

    @MainActor
    @Test func `GIVEN a revealed code THEN reveal is disabled`() throws {
        let (_, sut) = makeSUT(card: .scratched("SC-4829-7316"))

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }

    @MainActor
    private func makeSUT(card: CardState = .unscratched) -> (injector: SharedInjector, sut: ScratchScreenContent) {
        let injector = makeInjector(card: card)
        return (injector, ScratchScreenContent(module: injector.scratchCardModule))
    }
}
