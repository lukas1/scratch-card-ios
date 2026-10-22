import Clocks

enum InjectorFactory {
    static func real() -> any Injector {
#if UI_TESTING
        if CommandLine.arguments.contains("-ui-test-pending-reveal") {
            return SharedInjector(clock: TestClock())
        }
        return SharedInjector(clock: ImmediateClock())
#else
        return SharedInjector()
#endif
    }
}
