import SwiftUI

struct HomeScreen: View {
    let card: CardState
    let onScratch: () -> Void
    let onActivate: () -> Void
    let onReset: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    BrandMark()
                        .frame(width: 38, height: 38)
                    Text(.homeBrandTitle)
                        .font(.system(size: 13, weight: .black))
                        .tracking(2)
                        .foregroundStyle(Palette.ink)
                }
                .padding(.bottom, 24)

                Text(card.title)
                    .font(.system(size: 43, weight: .bold, design: .serif))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(card.description)
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.muted)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                HStack {
                    Text(.homeCardHeading)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    HStack(spacing: 7) {
                        Circle().fill(Palette.ink).frame(width: 7, height: 7)
                        Text(card.status)
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.7)
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.12)))
                    .accessibilityIdentifier("cardStatus")
                }
                .padding(.bottom, 16)

                ScratchCardArtwork(height: 226) {
                    CodePanel(
                        code: card.code,
                        color: card.isActivated ? Palette.lime : Palette.softGreen,
                        height: 108
                    )
                }
                .padding(.bottom, 20)

                SectionEyebrow(text: String(localized: .homeNextStepHeading))
                    .padding(.bottom, 10)

                Button(action: onScratch) {
                    ActionLabel(title: String(localized: .homeActionScratch))
                }
                .buttonStyle(CardActionStyle(kind: .primary))
                .disabled(card != .unscratched)
                .accessibilityIdentifier("scratchButton")
                .padding(.bottom, 10)

                if case .scratched = card {
                    Button(action: onActivate) {
                        ActionLabel(title: String(localized: .homeActionActivate))
                    }
                    .buttonStyle(.bordered)
                    .tint(Palette.ink)
                    .accessibilityIdentifier("activationButton")
                } else {
                    Button {} label: {
                        ActionLabel(title: String(localized: .homeActionActivate))
                    }
                    .buttonStyle(CardActionStyle(kind: .secondary))
                    .disabled(true)
                    .accessibilityIdentifier("activationButton")
                }

                Button(.homeActionReset, action: onReset)
                    .font(.system(size: 15))
                    .foregroundStyle(Palette.muted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .padding(.top, 8)
                    .accessibilityIdentifier("resetCardButton")
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.cream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension CardState {
    var title: String {
        switch self {
        case .unscratched: String(localized: .homeTitleUnscratched)
        case .scratched: String(localized: .homeTitleScratched)
        case .activated: String(localized: .homeTitleActivated)
        }
    }

    var description: String {
        switch self {
        case .unscratched: String(localized: .homeDescriptionUnscratched)
        case .scratched: String(localized: .homeDescriptionScratched)
        case .activated: String(localized: .homeDescriptionActivated)
        }
    }

    var status: String {
        switch self {
        case .unscratched: String(localized: .cardStatusUnscratched)
        case .scratched: String(localized: .cardStatusScratched)
        case .activated: String(localized: .cardStatusActivated)
        }
    }
}

private struct BrandMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Palette.lime)
            Image(systemName: "asterisk")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Palette.ink)
        }
    }
}

struct ActionLabel: View {
    let title: String

    var body: some View {
        HStack {
            Text(title).font(.system(size: 15, weight: .bold))
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 20, weight: .medium))
        }
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity, minHeight: 60)
    }
}

struct CardActionStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let kind: Kind

    enum Kind {
        case primary
        case secondary
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(kind == .primary ? .white : Palette.ink)
            .background(kind == .primary ? Palette.ink : .clear, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                if kind == .secondary {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Palette.ink.opacity(0.25))
                        .allowsHitTesting(false)
                }
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.38)
    }
}
