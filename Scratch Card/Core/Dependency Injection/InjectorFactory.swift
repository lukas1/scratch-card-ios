import Clocks

enum InjectorFactory {
    static func real() -> any Injector {
#if UI_TESTING
        return SharedInjector(clock: ImmediateClock())
#else
        return SharedInjector()
#endif
    }
}
