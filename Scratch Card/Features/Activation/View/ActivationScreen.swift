import SwiftUI

struct ActivationScreen: View {
    @RequiredEnvironment(\.injector) private var injector: Injector

    var body: some View {
        ActivationScreenContent(module: injector.scratchCardModule)
    }
}

struct ActivationScreenContent: View {
    @State private var viewModel: ActivationScreenViewModel

    init(module: ScratchCardModule) {
        _viewModel = State(wrappedValue: ActivationScreenViewModelFactory(module: module).make())
    }

    var body: some View {
        ActivationScreenPresentation(
            code: viewModel.code,
            phase: viewModel.phase,
            onActivate: viewModel.activate
        )
    }
}

private struct ActivationScreenPresentation: View {
    private let code: String?
    private let phase: ActivationPhase
    private let onActivate: () -> Void

    init(code: String?, phase: ActivationPhase, onActivate: @escaping () -> Void) {
        self.code = code
        self.phase = phase
        self.onActivate = onActivate
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
                    status: code == nil
                        ? String(localized: .activationCodeHiddenStatus)
                        : String(localized: .activationCodeReadyStatus)
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
                    .accessibilityIdentifier("activationProgress")
            }
            Text(.activationNote)
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
    }

    private var actionTitle: String {
        switch phase {
        case .ready: String(localized: .activationActionActivate)
        case .activating: String(localized: .activationActionActivating)
        case .activated: String(localized: .activationActionActivated)
        }
    }
}

#if !CODE_COVERAGE
#Preview("Activation · Pending code") {
    NavigationStack { ActivationScreenPresentation(code: nil, phase: .ready, onActivate: {}) }
}

#Preview("Activation · Pending, loading") {
    NavigationStack { ActivationScreenPresentation(code: nil, phase: .activating, onActivate: {}) }
}

#Preview("Activation · Ready") {
    NavigationStack { ActivationScreenPresentation(code: "SC-4829-7316", phase: .ready, onActivate: {}) }
}

#Preview("Activation · Loading") {
    NavigationStack { ActivationScreenPresentation(code: "SC-4829-7316", phase: .activating, onActivate: {}) }
}

#Preview("Activation · Activated") {
    NavigationStack { ActivationScreenPresentation(code: "SC-4829-7316", phase: .activated, onActivate: {}) }
}

#Preview("Activation · Unsupported version error") {
    ActivationErrorPreview(error: .unsupportedVersion("6.1"))
}

#Preview("Activation · Request error") {
    ActivationErrorPreview(error: .requestFailed)
}

private struct ActivationErrorPreview: View {
    private let module: ScratchCardModule
    @StateObject private var repository: ScratchCardRepository

    init(error: ActivationError) {
        let previewSession: PreviewURLSession
        switch error {
        case .unsupportedVersion(let version):
            previewSession = PreviewURLSession(response: .version(version))
        case .requestFailed:
            previewSession = PreviewURLSession(response: .failure)
        }
        let module = ScratchCardModule(
            codeGenerator: { "SC-4829-7316" },
            restApiClient: RestApiClient(
                baseURL: previewSession.baseURL,
                session: previewSession.session
            )
        )
        self.module = module
        _repository = StateObject(wrappedValue: module.scratchCardRepository)
    }

    var body: some View {
        NavigationStack {
            ActivationScreenContent(module: module)
        }
        .task {
            await repository.scratchCard()
            repository.activateCard()
        }
    }
}
#endif
