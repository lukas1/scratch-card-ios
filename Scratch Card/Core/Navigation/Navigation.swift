import Observation

@Observable
final class Navigation {
    var path: [NavigationDestinations] = []
    var sheet: NavigationSheet?

    func push(_ destination: NavigationDestinations) {
        path.append(destination)
    }

    func showSheet(_ sheet: NavigationSheet) {
        self.sheet = sheet
    }

    func dismissSheet() {
        sheet = nil
    }
}
