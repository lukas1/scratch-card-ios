import SwiftUI

@main
struct Scratch_CardApp: App {
    private let injector: any Injector = InjectorFactory.real()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.injector, injector)
        }
    }
}
