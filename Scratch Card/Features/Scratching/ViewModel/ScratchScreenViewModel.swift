import Combine
import Observation

@Observable
final class ScratchScreenViewModel {
    private(set) var card: CardState
    private(set) var isRevealing: Bool

    private let repository: ScratchCardRepository
    private var cancellables: Set<AnyCancellable> = []

    init(module: ScratchCardModule) {
        repository = module.scratchCardRepository
        card = repository.card
        isRevealing = repository.isRevealing

        repository.$card
            .sink { [weak self] card in self?.card = card }
            .store(in: &cancellables)

        repository.$isRevealing
            .sink { [weak self] isRevealing in self?.isRevealing = isRevealing }
            .store(in: &cancellables)
    }

    func reveal() {
        repository.startReveal()
    }
}
