import Clocks
import Foundation

struct ScratchCardModule {
    let scratchCardRepository: ScratchCardRepository

    init(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { UUID().uuidString }
    ) {
        let cardScratcher = CardScratcher(clock: clock, codeGenerator: codeGenerator)
        scratchCardRepository = ScratchCardRepository(clock: clock, cardScratcher: cardScratcher)
    }
}
