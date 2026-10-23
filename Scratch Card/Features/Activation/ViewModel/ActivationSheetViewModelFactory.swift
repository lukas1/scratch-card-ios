struct ActivationSheetViewModelFactory {
    private let module: ScratchCardModule

    init(module: ScratchCardModule) {
        self.module = module
    }

    func make() -> ActivationSheetViewModel {
        ActivationSheetViewModel(module: module)
    }
}
