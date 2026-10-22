import Clocks

typealias ScratchCardCodeGenerator = () -> String

struct CardScratcher {
    private let clock: any Clock<Duration>
    private let codeGenerator: ScratchCardCodeGenerator

    init(
        clock: any Clock<Duration>,
        codeGenerator: @escaping ScratchCardCodeGenerator
    ) {
        self.clock = clock
        self.codeGenerator = codeGenerator
    }

    func scratch() async throws -> String {
        try await clock.sleep(for: .seconds(2))
        try Task.checkCancellation()
        return codeGenerator()
    }
}
