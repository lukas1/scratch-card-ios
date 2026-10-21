struct SharedInjector: Injector {
    let globalModule: GlobalModule
    let scratchCardModule: ScratchCardModule
    let homeModule: HomeModule

    init() {
        let globalModule = GlobalModule()
        let scratchCardModule = ScratchCardModule()
        self.globalModule = globalModule
        self.scratchCardModule = scratchCardModule
        homeModule = HomeModule(globalModule: globalModule, scratchCardModule: scratchCardModule)
    }
}
