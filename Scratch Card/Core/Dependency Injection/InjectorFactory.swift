enum InjectorFactory {
    static func real() -> any Injector {
        SharedInjector()
    }
}
