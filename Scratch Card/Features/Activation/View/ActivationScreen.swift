import SwiftUI

enum ActivationPhase {
    case ready
    case activating
    case activated
}

enum ActivationError: String, Identifiable {
    case failed
    case unexpected

    var id: String { rawValue }
    var message: String {
        switch self {
        case .failed: String(localized: .activationErrorFailed)
        case .unexpected: String(localized: .activationErrorUnexpected)
        }
    }
}

struct ActivationScreen: View {
    @ObservedObject var model: ScratchCardRepository

    var body: some View {
        ActivationScreenContent(
            code: model.card.code,
            phase: model.card.isActivated ? .activated : (model.isActivating ? .activating : .ready),
            error: nil,
            onActivate: model.activateForDemo
        )
    }
}

struct ActivationScreenContent: View {
    let code: String?
    let phase: ActivationPhase
    let error: ActivationError?
    let onActivate: () -> Void
    @State private var isErrorPresented: Bool

    init(code: String?, phase: ActivationPhase, error: ActivationError?, onActivate: @escaping () -> Void) {
        self.code = code
        self.phase = phase
        self.error = error
        self.onActivate = onActivate
        _isErrorPresented = State(initialValue: error != nil)
    }

    var body: some View {
        DestinationPage(
            title: String(localized: .activationTitle),
            description: String(localized: .activationDescription),
            step: String(localized: .activationStep)
        ) {
            SectionEyebrow(text: String(localized: .cardEyebrow))
                .padding(.top, 26)
                .padding(.bottom, 12)
            ScratchCardArtwork(height: 252) {
                CodePanel(
                    code: code,
                    color: Palette.lime,
                    height: 120,
                    status: code == nil ? String(localized: .activationCodeHiddenStatus) : String(localized: .activationCodeReadyStatus)
                )
            }
            HStack(spacing: 14) {
                Image(systemName: "checkmark")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Palette.softGreen, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(.activationPromptTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Text(.activationPromptDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.muted)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Palette.ink.opacity(0.1)))
            .padding(.top, 16)

            Button(action: onActivate) {
                ActionLabel(title: actionTitle)
            }
                .buttonStyle(CardActionStyle(kind: .primary))
                .disabled(code == nil || phase != .ready)
                .accessibilityIdentifier("activateCardButton")
                .padding(.top, 16)

            if phase == .activating {
                ProgressView()
                    .tint(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
            }
            Text(.activationNote)
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
        .alert(.activationErrorTitle, isPresented: $isErrorPresented) {
            Button(.commonGotIt, role: .cancel) {}
        } message: {
            Text(error?.message ?? "")
        }
        .onChange(of: error) { _, newValue in isErrorPresented = newValue != nil }
    }

    private var actionTitle: String {
        switch phase {
        case .ready: String(localized: .activationActionActivate)
        case .activating: String(localized: .activationActionActivating)
        case .activated: String(localized: .activationActionActivated)
        }
    }
}

#Preview("Activation · Pending code") {
    NavigationStack { ActivationScreenContent(code: nil, phase: .ready, error: nil, onActivate: {}) }
}

#Preview("Activation · Pending, loading") {
    NavigationStack { ActivationScreenContent(code: nil, phase: .activating, error: nil, onActivate: {}) }
}

#Preview("Activation · Ready") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .ready, error: nil, onActivate: {}) }
}

#Preview("Activation · Loading") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .activating, error: nil, onActivate: {}) }
}

#Preview("Activation · Activated") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .activated, error: nil, onActivate: {}) }
}

#Preview("Activation · Failed") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .ready, error: .failed, onActivate: {}) }
}

#Preview("Activation · Unexpected error") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .ready, error: .unexpected, onActivate: {}) }
}

#Preview("Activation · Pending, failed") {
    NavigationStack { ActivationScreenContent(code: nil, phase: .ready, error: .failed, onActivate: {}) }
}

#Preview("Activation · Pending, loading error") {
    NavigationStack { ActivationScreenContent(code: nil, phase: .activating, error: .unexpected, onActivate: {}) }
}

#Preview("Activation · Loading error") {
    NavigationStack { ActivationScreenContent(code: "SC-4829-7316", phase: .activating, error: .unexpected, onActivate: {}) }
}
