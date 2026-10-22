import Clocks

enum InjectorFactory {
    static func real() -> any Injector {
#if UI_TESTING
        let codeGenerator: ScratchCardCodeGenerator = { "SC-4829-7316" }
        if CommandLine.arguments.contains("-ui-test-pending-reveal") {
            return SharedInjector(clock: TestClock(), codeGenerator: codeGenerator)
        }
        return SharedInjector(clock: ImmediateClock(), codeGenerator: codeGenerator)
#else
        return SharedInjector()
#endif
    }
}
