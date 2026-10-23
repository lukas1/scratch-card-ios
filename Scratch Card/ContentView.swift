import SwiftUI

struct ContentView: View {
    @RequiredEnvironment(\.injector) private var injector: Injector

    var body: some View {
        ContentViewContent(
            navigation: injector.globalModule.navigation,
            scratchCardModule: injector.scratchCardModule
        )
    }
}

private struct ContentViewContent: View {
    @Bindable private var navigation: Navigation
    @ObservedObject private var scratchCardRepository: ScratchCardRepository

    init(
        navigation: Navigation,
        scratchCardModule: ScratchCardModule
    ) {
        self.navigation = navigation
        _scratchCardRepository = ObservedObject(wrappedValue: scratchCardModule.scratchCardRepository)
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
                    ActivationScreen()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button(.commonDone) { navigation.dismissSheet() }
                            }
                        }
                }
                .tint(Palette.ink)
            }
        }
        .alert(.activationErrorTitle, isPresented: Binding(
            get: { scratchCardRepository.activationError != nil },
            set: { if !$0 { scratchCardRepository.dismissActivationError() } }
        )) {
            Button(.commonGotIt, role: .cancel) {
                scratchCardRepository.dismissActivationError()
            }
        } message: {
            Text(scratchCardRepository.activationError?.message ?? "")
        }
    }
}
