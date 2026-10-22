import Clocks

struct ScratchCardModule {
    let scratchCardRepository: ScratchCardRepository

    init(clock: any Clock<Duration> = ContinuousClock()) {
        scratchCardRepository = ScratchCardRepository(clock: clock)
    }
}
