import Combine
import Observation

@Observable
final class HomeScreenViewModel {
    private(set) var card: CardState

    private let navigation: Navigation
    private let repository: ScratchCardRepository
    private var cancellables: Set<AnyCancellable> = []

    init(module: HomeModule) {
        navigation = module.globalModule.navigation
        repository = module.scratchCardModule.scratchCardRepository
        card = repository.card

        repository.$card
            .sink { [weak self] card in self?.card = card }
            .store(in: &cancellables)
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
