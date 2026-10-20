import SwiftUI

@main
struct ScratchCardApp: App {
    private let injector: any Injector = InjectorFactory.real()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.injector, injector)
        }
    }
}
