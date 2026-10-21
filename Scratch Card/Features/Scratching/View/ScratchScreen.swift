import SwiftUI

struct ScratchScreen: View {
    @ObservedObject var model: ScratchCardRepository

    var body: some View {
        ScratchScreenContent(
            code: model.card.code,
            isRevealing: model.isRevealing,
            onReveal: model.startReveal
        )
    }
}

struct ScratchScreenContent: View {
    let code: String?
    let isRevealing: Bool
    let onReveal: () -> Void

    var body: some View {
        DestinationPage(
            title: String(localized: .scratchTitle),
            description: String(localized: .scratchDescription),
            step: String(localized: .scratchStep)
        ) {
            SectionEyebrow(text: String(localized: .cardEyebrow))
                .padding(.top, 30)
                .padding(.bottom, 12)
            ScratchCardArtwork(height: 266) {
                ZStack {
                    LinearGradient(
                        colors: [Palette.foilLight, Palette.foilDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 5) {
                        Image(systemName: "asterisk")
                            .font(.system(size: 25, weight: .medium))
                        if isRevealing {
                            ProgressView().tint(Palette.ink)
                        }
                        Text(
                            code ?? (isRevealing
                                ? String(localized: .scratchCodeRevealing)
                                : String(localized: .scratchCodeHidden))
                        )
                            .font(
                                .system(
                                    size: code == nil ? 25 : 14,
                                    weight: .bold,
                                    design: code == nil ? .serif : .monospaced
                                )
                            )
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.75)
                            .accessibilityIdentifier("scratchCode")
                        Text(
                            code == nil
                                ? String(localized: .scratchCodeHiddenLabel)
                                : String(localized: .scratchCodeRevealedLabel)
                        )
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.6)
                            .foregroundStyle(Palette.muted)
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 14)
                }
                .frame(height: 134)
                .clipShape(RoundedRectangle(cornerRadius: 17))
                .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(.white.opacity(0.6)))
            }
            HStack(spacing: 14) {
                Image(systemName: "asterisk")
                    .font(.system(size: 19))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 44, height: 44)
                    .background(Palette.softGreen, in: Circle())
                VStack(alignment: .leading, spacing: 3) {
                    Text(.scratchPromptTitle)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Text(.scratchPromptDescription)
                        .font(.system(size: 13))
                        .foregroundStyle(Palette.muted)
                }
            }
            .padding(.top, 22)
            Button(action: onReveal) {
                ActionLabel(title: actionTitle)
            }
            .buttonStyle(CardActionStyle(kind: .primary))
            .disabled(code != nil || isRevealing)
            .accessibilityIdentifier("revealButton")
            .padding(.top, 24)
            Text(.scratchNote)
                .font(.system(size: 12))
                .foregroundStyle(Palette.muted)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
        }
    }

    private var actionTitle: String {
        if code != nil {
            String(localized: .scratchActionRevealed)
        } else if isRevealing {
            String(localized: .scratchActionRevealing)
        } else {
            String(localized: .scratchActionReveal)
        }
    }
}

#Preview("Reveal · Ready") {
    NavigationStack { ScratchScreenContent(code: nil, isRevealing: false, onReveal: {}) }
}

#Preview("Reveal · Loading") {
    NavigationStack { ScratchScreenContent(code: nil, isRevealing: true, onReveal: {}) }
}

#Preview("Reveal · Revealed") {
    NavigationStack { ScratchScreenContent(code: "SC-4829-7316", isRevealing: false, onReveal: {}) }
}
