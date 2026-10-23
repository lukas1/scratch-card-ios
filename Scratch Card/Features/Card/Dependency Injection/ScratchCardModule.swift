import Clocks
import Foundation

struct ScratchCardModule {
    let scratchCardRepository: ScratchCardRepository

    init(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { UUID().uuidString },
        restApiClient: RestApiClient
    ) {
        let cardScratcher = CardScratcher(clock: clock, codeGenerator: codeGenerator)
        scratchCardRepository = ScratchCardRepository(
            cardScratcher: cardScratcher,
            scratchCardApi: ScratchCardApi(restClient: restApiClient)
        )
    }
}
