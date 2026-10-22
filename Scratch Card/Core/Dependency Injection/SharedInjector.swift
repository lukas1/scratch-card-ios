import Clocks

struct SharedInjector: Injector {
    let globalModule: GlobalModule
    let scratchCardModule: ScratchCardModule
    let homeModule: HomeModule

    init(clock: any Clock<Duration> = ContinuousClock()) {
        let globalModule = GlobalModule()
        let scratchCardModule = ScratchCardModule(clock: clock)
        self.globalModule = globalModule
        self.scratchCardModule = scratchCardModule
        homeModule = HomeModule(globalModule: globalModule, scratchCardModule: scratchCardModule)
    }
}
