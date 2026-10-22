import Clocks
import Testing

struct ScratchCardRepositoryTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN reveal starts again THEN only the original reveal runs`() async {
        let clock = TestClock()
        var generatedCodeCount = 0
        let repository = ScratchCardRepository(clock: clock) {
            generatedCodeCount += 1
            return "SC-4829-\(7315 + generatedCodeCount)"
        }
        let originalTask = Task { await repository.scratchCard() }
        await Task.yield()

        let duplicateTask = Task { await repository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await originalTask.value
        await duplicateTask.value

        #expect(generatedCodeCount == 1)
        #expect(repository.card == .scratched("SC-4829-7316"))
    }

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN reset happens THEN the card stays unscratched`() async {
        let clock = TestClock()
        let repository = ScratchCardRepository(clock: clock, codeGenerator: { expectedCode })
        let task = Task { await repository.scratchCard() }
        await Task.yield()

        repository.reset()
        await clock.advance(by: .seconds(2))
        await task.value

        #expect(repository.card == .unscratched)
    }

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN its task is cancelled THEN a retry reveals the card once`() async {
        let clock = TestClock()
        var generatedCodeCount = 0
        let repository = ScratchCardRepository(clock: clock) {
            generatedCodeCount += 1
            return "SC-4829-\(7315 + generatedCodeCount)"
        }
        let task = Task { await repository.scratchCard() }
        await Task.yield()

        task.cancel()
        await task.value

        #expect(repository.card == .unscratched)

        let retryTask = Task { await repository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await retryTask.value

        #expect(generatedCodeCount == 1)
        #expect(repository.card == .scratched("SC-4829-7316"))
    }

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

        await repository.scratchCard()
        await clock.advance(by: .seconds(2))

        #expect(repository.card == card)
    }
}
