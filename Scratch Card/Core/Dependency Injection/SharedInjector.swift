struct SharedInjector: Injector {
    let globalModule: GlobalModule = GlobalModule()
    let scratchCardModule: ScratchCardModule = ScratchCardModule()
}
