import SwiftUI

struct Alert {
    let title: String
    let message: String
}

@Observable
final class AlertPresenter {
    var alert: Alert?

    func isPresented(isHostActive: @escaping () -> Bool) -> Binding<Bool> {
        Binding(
            get: { isHostActive() && self.alert != nil },
            set: { if !$0 && isHostActive() { self.alert = nil } }
        )
    }
}
