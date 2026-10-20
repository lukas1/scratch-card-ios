import Testing
import ViewInspector
@testable import Scratch_Card

struct HomeScreenTests {
    @MainActor
    @Test func `GIVEN an unscratched card THEN scratch is enabled and activation is disabled`() throws {
        let sut = HomeScreen(card: .unscratched, onScratch: {}, onActivate: {}, onReset: {})

        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().isDisabled() == false)
        #expect(try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().isDisabled())
    }

    @MainActor
    @Test func `GIVEN an unscratched card WHEN scratch is tapped THEN the scratch action is called`() throws {
        var wasScratched = false
        let sut = HomeScreen(
            card: .unscratched,
            onScratch: { wasScratched = true },
            onActivate: {},
            onReset: {}
        )

        try sut.inspect().find(viewWithAccessibilityIdentifier: "scratchButton").button().tap()

        #expect(wasScratched)
    }

    @MainActor
    @Test func `GIVEN a scratched card WHEN activation is tapped THEN the activation action is called`() throws {
        var wasActivated = false
        let sut = HomeScreen(
            card: .scratched("SC-4829-7316"),
            onScratch: {},
            onActivate: { wasActivated = true },
            onReset: {}
        )

        try sut.inspect().find(viewWithAccessibilityIdentifier: "activationButton").button().tap()

        #expect(wasActivated)
    }
}
