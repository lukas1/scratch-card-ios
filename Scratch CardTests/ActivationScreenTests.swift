import Testing
import ViewInspector
@testable import Scratch_Card

struct ActivationScreenTests {
    @MainActor
    @Test func `GIVEN no revealed code THEN activation is disabled`() throws {
        let model = ScratchCardRepository()
        let sut = ActivationScreen(model: model)

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN a revealed code WHEN activation is tapped THEN activation starts`() throws {
        let model = ScratchCardRepository()
        model.card = .scratched("SC-4829-7316")
        let sut = ActivationScreen(model: model)

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().tap()

        #expect(model.isActivating)
    }

    @MainActor
    @Test func `GIVEN activation is in progress THEN activation remains disabled`() throws {
        let model = ScratchCardRepository()
        model.card = .scratched("SC-4829-7316")
        model.isActivating = true
        let sut = ActivationScreen(model: model)

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activateCardButton").button().isDisabled())
    }
}
