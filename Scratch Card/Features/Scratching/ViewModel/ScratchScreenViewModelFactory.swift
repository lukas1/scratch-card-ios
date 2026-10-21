struct ScratchScreenViewModelFactory {
    private let module: ScratchCardModule

    init(module: ScratchCardModule) {
        self.module = module
    }

    func make() -> ScratchScreenViewModel {
        ScratchScreenViewModel(module: module)
    }
}
