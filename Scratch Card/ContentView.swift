import SwiftUI

struct ContentView: View {
    @RequiredEnvironment(\.injector) private var injector: Injector

    var body: some View {
        ContentViewContent(
            injector: injector
        )
    }
}

struct ContentViewContent: View {
    @Bindable private var navigation: Navigation
    @ObservedObject private var scratchCardRepository: ScratchCardRepository
    private let injector: Injector

    init(
        injector: Injector
    ) {
        self.injector = injector
        self.navigation = injector.globalModule.navigation
        _scratchCardRepository = ObservedObject(wrappedValue: injector.scratchCardModule.scratchCardRepository)
    }

    var body: some View {
        NavigationStack(path: $navigation.path) {
            HomeScreen(injector: injector)
                .navigationDestination(for: NavigationDestinations.self) { destination in
                    switch destination {
                    case .scratch:
                        ScratchScreen(injector: injector)
                    }
                }
        }
        .tint(Palette.ink)
        .sheet(item: $navigation.sheet) { sheet in
            switch sheet {
            case .activation:
                NavigationStack {
                    ActivationScreen(injector: injector)
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
