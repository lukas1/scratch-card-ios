import Testing
import ViewInspector
@testable import Scratch_Card

struct ScratchScreenTests {
    @MainActor
    @Test func `GIVEN a hidden code THEN reveal is enabled`() throws {
        let model = ScratchCardRepository()
        let sut = ScratchScreen(model: model)

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled() == false)
    }

    @MainActor
    @Test func `GIVEN a hidden code WHEN reveal is tapped THEN revealing starts`() throws {
        let model = ScratchCardRepository()
        let sut = ScratchScreen(model: model)

        try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().tap()
        defer { model.cancelReveal() }

        #expect(model.isRevealing)
    }

    @MainActor
    @Test func `GIVEN a revealed code THEN reveal is disabled`() throws {
        let model = ScratchCardRepository()
        model.card = .scratched("SC-4829-7316")
        let sut = ScratchScreen(model: model)

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "revealButton").button().isDisabled())
    }
}
