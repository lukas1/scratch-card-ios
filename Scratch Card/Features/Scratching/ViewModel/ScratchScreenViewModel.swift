import Observation

@Observable
final class ScratchScreenViewModel {
    var card: CardState { repository.card }
    var isRevealing: Bool {
        revealingTask != nil
    }
    private var revealingTask: Task<(), Never>?

    private let repository: ScratchCardRepository

    init(module: ScratchCardModule) {
        repository = module.scratchCardRepository
    }

    func reveal() {
        guard revealingTask == nil else { return }
        revealingTask = Task { [weak self] in
            await self?.repository.scratchCard()
            self?.revealingTask = nil
        }
    }

    func cancelReveal() {
        revealingTask?.cancel()
    }

    deinit {
        revealingTask?.cancel()
    }
}
