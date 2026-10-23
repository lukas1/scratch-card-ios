import SwiftUI

struct Alert {
    let title: String
    let message: String
}

@Observable
final class AlertPresenter {
    var alert: Alert?

    var isPresented: Binding<Bool> {
        Binding(
            get: { self.alert != nil },
            set: { if !$0 { self.alert = nil } }
        )
    }
}
