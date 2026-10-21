import SwiftUI

struct ContentView: View {
    @RequiredEnvironment(\.injector) private var injector: Injector

    var body: some View {
        ContentViewContent(
            navigation: injector.globalModule.navigation,
            model: injector.scratchCardModule.scratchCardRepository
        )
    }
}

private struct ContentViewContent: View {
    @Bindable private var navigation: Navigation
    @ObservedObject private var model: ScratchCardRepository
    @State private var isActivationPresented = false

    init(
        navigation: Navigation,
        model: ScratchCardRepository
    ) {
        self.navigation = navigation
        self.model = model
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            HomeScreen(
                card: model.card,
                onScratch: { navigation.push(.scratch) },
                onActivate: { isActivationPresented = true },
                onReset: model.reset
            )
            .navigationDestination(for: NavigationDestinations.self) { destination in
                switch destination {
                case .scratch:
                    ScratchScreen(model: model)
                }
            }
        }
        .tint(Palette.ink)
        .sheet(isPresented: $isActivationPresented) {
            NavigationStack {
                ActivationScreen(model: model)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(.commonDone) { isActivationPresented = false }
                        }
                    }
            }
            .tint(Palette.ink)
        }
        .onChange(of: navigation.path) { oldPath, newPath in
            if oldPath.contains(.scratch), !newPath.contains(.scratch) {
                model.cancelReveal()
            }
        }
    }
}

#Preview("Home · Unscratched") {
    NavigationStack { HomeScreen(card: .unscratched, onScratch: {}, onActivate: {}, onReset: {}) }
}

#Preview("Home · Scratched") {
    NavigationStack { HomeScreen(card: .scratched("SC-4829-7316"), onScratch: {}, onActivate: {}, onReset: {}) }
}

#Preview("Home · Activated") {
    NavigationStack { HomeScreen(card: .activated("SC-4829-7316"), onScratch: {}, onActivate: {}, onReset: {}) }
}
