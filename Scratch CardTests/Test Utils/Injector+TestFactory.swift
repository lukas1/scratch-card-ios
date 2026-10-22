@MainActor
func makeInjector(
    card: CardState = .unscratched,
    codeGenerator: @escaping ScratchCardCodeGenerator = { "SC-4829-7316" }
) -> SharedInjector {
    let injector = SharedInjector(codeGenerator: codeGenerator)
    injector.scratchCardModule.scratchCardRepository.card = card
    return injector
}
