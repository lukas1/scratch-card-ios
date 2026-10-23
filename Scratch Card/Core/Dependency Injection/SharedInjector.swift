import Clocks
import Foundation

struct SharedInjector: Injector {
    let globalModule: GlobalModule
    let scratchCardModule: ScratchCardModule
    let homeModule: HomeModule

    init(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { UUID().uuidString },
        baseURL: URL = URL(string: "https://api.o2.sk/")!,
        session: URLSession
    ) {
        let globalModule = GlobalModule()
        let scratchCardModule = ScratchCardModule(
            clock: clock,
            codeGenerator: codeGenerator,
            restApiClient: RestApiClient(baseURL: baseURL, session: session)
        )
        self.globalModule = globalModule
        self.scratchCardModule = scratchCardModule
        homeModule = HomeModule(globalModule: globalModule, scratchCardModule: scratchCardModule)
    }
}
