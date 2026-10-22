import Clocks
import Testing

struct ScratchScreenViewModelTests {
    private let expectedCode = "SC-4829-7316"

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN reveal starts again THEN the original reveal completes on time`() async {
        let clock = TestClock()
        let module = ScratchCardModule(clock: clock, codeGenerator: { expectedCode })
        let viewModel = ScratchScreenViewModelFactory(module: module).make()

        viewModel.reveal()
        await waitForRevealState(of: viewModel, toBe: true)
        await clock.advance(by: .seconds(1))

        viewModel.reveal()
        await Task.yield()
        await clock.advance(by: .milliseconds(999))

        #expect(viewModel.isRevealing)
        #expect(viewModel.card == .unscratched)

        await clock.advance(by: .milliseconds(1))
        await waitForRevealState(of: viewModel, toBe: false)

        #expect(viewModel.card == .scratched(expectedCode))
    }

    @MainActor
    @Test func `GIVEN a reveal in progress WHEN the view model is released THEN the card stays unscratched`() async {
        let clock = TestClock()
        let module = ScratchCardModule(clock: clock, codeGenerator: { expectedCode })
        var viewModel: ScratchScreenViewModel? = ScratchScreenViewModelFactory(module: module).make()

        viewModel?.reveal()
        if let viewModel {
            await waitForRevealState(of: viewModel, toBe: true)
        }

        viewModel = nil
        await clock.advance(by: .seconds(2))

        for _ in 0..<100 where module.scratchCardRepository.card == .unscratched {
            await Task.yield()
        }

        #expect(module.scratchCardRepository.card == .unscratched)
    }

    @MainActor
    private func waitForRevealState(of viewModel: ScratchScreenViewModel, toBe expectedValue: Bool) async {
        for _ in 0..<100 where viewModel.isRevealing != expectedValue {
            await Task.yield()
        }
        #expect(viewModel.isRevealing == expectedValue)
    }
}
