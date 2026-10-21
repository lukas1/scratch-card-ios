@testable import Scratch_Card

@MainActor
func makeInjector(card: CardState = .unscratched) -> SharedInjector {
    let injector = SharedInjector()
    injector.scratchCardModule.scratchCardRepository.card = card
    return injector
}
