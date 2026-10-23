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
    @Bindable private var alertPresenter: AlertPresenter
    private let injector: Injector

    init(
        injector: Injector
    ) {
        self.injector = injector
        self.navigation = injector.globalModule.navigation
        self.alertPresenter = injector.globalModule.alertPresenter
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
        .alert(alertPresenter.alert?.title ?? "", isPresented: alertPresenter.isPresented) {
            Button(.commonGotIt, role: .cancel) {
                alertPresenter.alert = nil
            }
        } message: {
            Text(alertPresenter.alert?.message ?? "")
        }
    }
}
