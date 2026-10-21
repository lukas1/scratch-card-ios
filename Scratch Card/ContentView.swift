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

    init(
        navigation: Navigation,
        model: ScratchCardRepository
    ) {
        self.navigation = navigation
        self.model = model
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            HomeScreen()
                .navigationDestination(for: NavigationDestinations.self) { destination in
                    switch destination {
                    case .scratch:
                        ScratchScreen()
                    }
                }
        }
        .tint(Palette.ink)
        .sheet(item: $navigation.sheet) { sheet in
            switch sheet {
            case .activation:
                NavigationStack {
                    ActivationScreen(model: model)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(.commonDone) { navigation.dismissSheet() }
                            }
                        }
                }
                .tint(Palette.ink)
            }
        }
        .onChange(of: navigation.path) { oldPath, newPath in
            if oldPath.contains(.scratch), !newPath.contains(.scratch) {
                model.cancelReveal()
            }
        }
    }
}

#Preview("Home · Unscratched") {
    homePreview(card: .unscratched)
}

#Preview("Home · Scratched") {
    homePreview(card: .scratched("SC-4829-7316"))
}

#Preview("Home · Activated") {
    homePreview(card: .activated("SC-4829-7316"))
}

private func homePreview(card: CardState) -> some View {
    let injector = SharedInjector()
    injector.scratchCardModule.scratchCardRepository.card = card
    return NavigationStack { HomeScreen() }
        .environment(\.injector, injector)
}
