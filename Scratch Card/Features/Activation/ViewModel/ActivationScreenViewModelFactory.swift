struct ActivationScreenViewModelFactory {
    private let module: ScratchCardModule

    init(module: ScratchCardModule) {
        self.module = module
    }

    func make() -> ActivationScreenViewModel {
        ActivationScreenViewModel(module: module)
    }
}
