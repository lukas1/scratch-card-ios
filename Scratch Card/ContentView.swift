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
        let isSheetPresented = navigation.sheet != nil

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
        .routedAlerts(using: alertPresenter, isHostActive: { !isSheetPresented && navigation.sheet == nil })
        .sheet(item: $navigation.sheet) { sheet in
            AlertHost(
                alertPresenter: alertPresenter,
                isHostActive: { navigation.sheet != nil },
                content: {
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
            )
        }
    }
}
