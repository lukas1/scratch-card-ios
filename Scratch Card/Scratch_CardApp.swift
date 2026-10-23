import SwiftUI

@main
struct ScratchCardApp: App {
    private let injector: any Injector = InjectorFactory.real(baseURL: URL(string: "https://api.o2.sk/")!)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.injector, injector)
        }
    }
}
