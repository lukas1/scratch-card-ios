import Observation

@Observable
final class HomeScreenViewModel {
    var card: CardState { repository.card }

    private let navigation: Navigation
    private let repository: ScratchCardRepository

    init(module: HomeModule) {
        navigation = module.globalModule.navigation
        repository = module.scratchCardModule.scratchCardRepository
    }

    func scratch() {
        navigation.push(.scratch)
    }

    func activate() {
        navigation.showSheet(.activation)
    }

    func reset() {
        repository.reset()
    }
}
