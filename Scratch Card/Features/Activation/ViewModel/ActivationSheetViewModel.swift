import Observation

@Observable
final class ActivationSheetViewModel {
    var code: String? { repository.card.code }
    var phase: ActivationPhase {
        activationPhase(for: repository.card, isActivating: repository.isActivating)
    }

    private let repository: ScratchCardRepository

    init(module: ScratchCardModule) {
        repository = module.scratchCardRepository
    }

    func activate() {
        repository.activateCard()
    }
}

private func activationPhase(for card: CardState, isActivating: Bool) -> ActivationPhase {
    if card.isActivated { return .activated }
    return isActivating ? .activating : .ready
}
