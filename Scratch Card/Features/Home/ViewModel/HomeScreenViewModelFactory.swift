struct HomeScreenViewModelFactory {
    private let module: HomeModule

    init(module: HomeModule) {
        self.module = module
    }

    func make() -> HomeScreenViewModel {
        HomeScreenViewModel(module: module)
    }
}
