import Clocks
import Foundation

struct ScratchCardModule {
    let scratchCardRepository: ScratchCardRepository

    init(
        clock: any Clock<Duration>,
        codeGenerator: @escaping ScratchCardCodeGenerator = { UUID().uuidString },
        restApiClient: RestApiClient,
        alertPresenter: AlertPresenter = AlertPresenter()
    ) {
        let cardScratcher = CardScratcher(clock: clock, codeGenerator: codeGenerator)
        scratchCardRepository = ScratchCardRepository(
            cardScratcher: cardScratcher,
            scratchCardApi: ScratchCardApi(restClient: restApiClient),
            alertPresenter: alertPresenter
        )
    }
}
