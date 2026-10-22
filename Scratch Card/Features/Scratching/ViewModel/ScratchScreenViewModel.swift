import Combine
import Observation

@Observable
final class ScratchScreenViewModel {
    private(set) var card: CardState
    var isRevealing: Bool {
        revealingTask != nil
    }
    private var revealingTask: Task<(), Never>?

    private let repository: ScratchCardRepository
    private var cancellables: Set<AnyCancellable> = []

    init(module: ScratchCardModule) {
        repository = module.scratchCardRepository
        card = repository.card

        repository.$card
            .sink { [weak self] card in self?.card = card }
            .store(in: &cancellables)
    }

    func reveal() {
        guard revealingTask == nil else { return }
        revealingTask = Task { [weak self] in
            await self?.repository.scratchCard()
            self?.revealingTask = nil
        }
    }

    deinit {
        revealingTask?.cancel()
    }
}
