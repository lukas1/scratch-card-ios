import Clocks
import Testing

struct ScratchCardRepositoryTests {
    @MainActor
    @Test func `GIVEN a scratched card WHEN reveal starts THEN the card remains scratched`() async {
        await assertRevealDoesNotStart(for: .scratched("SC-4829-7316"))
    }

    @MainActor
    @Test func `GIVEN an activated card WHEN reveal starts THEN the card remains activated`() async {
        await assertRevealDoesNotStart(for: .activated("SC-4829-7316"))
    }

    @MainActor
    private func assertRevealDoesNotStart(for card: CardState) async {
        let clock = TestClock()
        let repository = ScratchCardRepository(clock: clock)
        repository.card = card

        repository.startReveal()
        await clock.advance(by: .seconds(2))

        #expect(repository.card == card)
        #expect(!repository.isRevealing)
    }
}
