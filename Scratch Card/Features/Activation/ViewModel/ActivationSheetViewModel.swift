import Combine
import Observation

@Observable
final class ActivationSheetViewModel {
    private(set) var code: String?
    private(set) var phase: ActivationPhase

    private let repository: ScratchCardRepository
    private var cancellables: Set<AnyCancellable> = []

    init(module: ScratchCardModule) {
        repository = module.scratchCardRepository
        code = repository.card.code
        phase = activationPhase(for: repository.card, isActivating: repository.isActivating)

        repository.$card
            .sink { [weak self] card in
                guard let self else { return }
                updatePresentationState(card: card, isActivating: repository.isActivating)
            }
            .store(in: &cancellables)

        repository.$isActivating
            .sink { [weak self] isActivating in
                guard let self else { return }
                updatePresentationState(card: repository.card, isActivating: isActivating)
            }
            .store(in: &cancellables)
    }

    func activate() {
        repository.activateCard()
    }

    private func updatePresentationState(card: CardState, isActivating: Bool) {
        code = card.code
        phase = activationPhase(for: card, isActivating: isActivating)
    }
}

private func activationPhase(for card: CardState, isActivating: Bool) -> ActivationPhase {
    if card.isActivated { return .activated }
    return isActivating ? .activating : .ready
}
