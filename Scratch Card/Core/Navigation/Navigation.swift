import Observation

@Observable
final class Navigation {
    var path: [NavigationDestinations] = []

    func push(_ destination: NavigationDestinations) {
        path.append(destination)
    }
}
