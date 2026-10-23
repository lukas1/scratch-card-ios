import Clocks
import Foundation
import Testing

struct ScratchCardRepositoryTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN reveal starts again THEN only the original reveal runs`() async {
        let clock = TestClock()
        var generatedCodeCount = 0
        let repository = makeRepository(clock: clock) {
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
        let repository = makeRepository(clock: clock, codeGenerator: { expectedCode })
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
        let repository = makeRepository(clock: clock) {
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
        let clock = TestClock()
        let repository = makeRepository(
            clock: clock,
            testSession: TestURLSession()
        )
        await scratch(repository, clock: clock)

        await assertRevealDoesNotStart(
            for: .scratched(expectedCode),
            repository: repository,
            clock: clock
        )
    }

    @MainActor
    @Test func `GIVEN an activated card WHEN reveal starts THEN the card remains activated`() async throws {
        let clock = TestClock()
        let repository = makeRepository(
            clock: clock,
            testSession: TestURLSession()
        )
        await scratch(repository, clock: clock)
        repository.activateCard()
        try await waitForActivationToFinish(repository)

        await assertRevealDoesNotStart(
            for: .activated(expectedCode),
            repository: repository,
            clock: clock
        )
    }

    @MainActor
    private func assertRevealDoesNotStart(
        for card: CardState,
        repository: ScratchCardRepository,
        clock: TestClock<Duration>
    ) async {
        await repository.scratchCard()
        await clock.advance(by: .seconds(2))

        #expect(repository.card == card)
    }

    @MainActor
    private func scratch(_ repository: ScratchCardRepository, clock: TestClock<Duration>) async {
        let task = Task { await repository.scratchCard() }
        await Task.yield()
        await clock.advance(by: .seconds(2))
        await task.value
    }

    @MainActor
    private func waitForActivationToFinish(_ repository: ScratchCardRepository) async throws {
        for _ in 0..<100 where repository.isActivating {
            try await Task.sleep(for: .milliseconds(1))
        }
    }

    @MainActor
    private func makeRepository(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { "SC-4829-7316" },
        testSession: TestURLSession = TestURLSession()
    ) -> ScratchCardRepository {
        ScratchCardModule(
            clock: clock,
            codeGenerator: codeGenerator,
            testSession: testSession
        ).scratchCardRepository
    }
}
