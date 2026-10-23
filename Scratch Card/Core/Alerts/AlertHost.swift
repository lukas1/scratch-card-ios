import SwiftUI

struct AlertHost<Content: View>: View {
    private let content: Content
    private let alertPresenter: AlertPresenter
    private let isHostActive: () -> Bool

    init(
        alertPresenter: AlertPresenter,
        isHostActive: @escaping () -> Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.alertPresenter = alertPresenter
        self.isHostActive = isHostActive
    }

    var body: some View {
        content.routedAlerts(using: alertPresenter, isHostActive: isHostActive)
    }
}

private struct RoutedAlertModifier: ViewModifier {
    @Bindable var alertPresenter: AlertPresenter
    let isHostActive: () -> Bool

    func body(content: Content) -> some View {
        content
            .alert(
                alertPresenter.alert?.title ?? "",
                isPresented: alertPresenter.isPresented(isHostActive: isHostActive)
            ) {
                Button(.commonGotIt, role: .cancel) {
                    alertPresenter.alert = nil
                }
            } message: {
                Text(alertPresenter.alert?.message ?? "")
            }
    }
}

extension View {
    func routedAlerts(using alertPresenter: AlertPresenter, isHostActive: @escaping () -> Bool) -> some View {
        modifier(RoutedAlertModifier(alertPresenter: alertPresenter, isHostActive: isHostActive))
    }
}
