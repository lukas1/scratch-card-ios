import SwiftUI

enum Palette {
    static let cream = Color(red: 247.0 / 255, green: 245.0 / 255, blue: 239.0 / 255)
    static let ink = Color(red: 24.0 / 255, green: 51.0 / 255, blue: 46.0 / 255)
    static let muted = Color(red: 88.0 / 255, green: 112.0 / 255, blue: 105.0 / 255)
    static let lime = Color(red: 215.0 / 255, green: 244.0 / 255, blue: 107.0 / 255)
    static let cardLight = Color(red: 40.0 / 255, green: 80.0 / 255, blue: 71.0 / 255)
    static let cardDark = Color(red: 17.0 / 255, green: 42.0 / 255, blue: 37.0 / 255)
    static let softGreen = Color(red: 232.0 / 255, green: 240.0 / 255, blue: 233.0 / 255)
    static let foilLight = Color(red: 244.0 / 255, green: 248.0 / 255, blue: 222.0 / 255)
    static let foilDark = Color(red: 190.0 / 255, green: 213.0 / 255, blue: 187.0 / 255)
}

struct SectionEyebrow: View {
    private let text: String

    init(text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .tracking(1.6)
            .foregroundStyle(Palette.muted)
    }
}

struct ScratchCardArtwork<Content: View>: View {
    private let height: CGFloat
    private let content: Content

    init(height: CGFloat, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.cardLight, Palette.cardDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            GeometryReader { geometry in
                Circle()
                    .fill(.white.opacity(0.055))
                    .frame(width: geometry.size.width * 0.9)
                    .position(x: geometry.size.width * 0.95, y: geometry.size.height * 0.05)
                Circle()
                    .strokeBorder(Palette.lime.opacity(0.12), lineWidth: 24)
                    .frame(width: geometry.size.width * 0.55)
                    .position(x: geometry.size.width * 0.03, y: geometry.size.height * 1.06)
            }
            .accessibilityHidden(true)
            VStack(spacing: 0) {
                HStack {
                    Text(.cardArtworkTopLabel)
                        .font(.system(size: 11, weight: .black))
                        .tracking(2)
                    Spacer()
                    Text(.cardArtworkSequence)
                        .font(.system(size: 11, design: .monospaced))
                        .opacity(0.7)
                }
                Spacer(minLength: 12)
                content
                Spacer(minLength: 12)
                HStack {
                    Text(.cardArtworkBottomLabel)
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1)
                        .opacity(0.76)
                    Spacer()
                    Image(systemName: "asterisk")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Palette.lime)
                }
            }
            .foregroundStyle(.white)
            .padding(22)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .accessibilityElement(children: .contain)
    }
}

struct CodePanel: View {
    private let code: String?
    private let color: Color
    private let height: CGFloat
    private let status: String?

    init(code: String?, color: Color, height: CGFloat, status: String? = nil) {
        self.code = code
        self.color = color
        self.height = height
        self.status = status
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(.cardCodeTitle)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(Palette.ink.opacity(0.7))
            Spacer(minLength: 4)
            Text(code ?? "••••  ••••  ••••")
                .font(.system(size: code == nil ? 25 : 14, weight: .bold, design: .monospaced))
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .foregroundStyle(Palette.ink)
                .accessibilityIdentifier("cardCode")
            if let status {
                Spacer(minLength: 4)
                Text(status)
                    .font(.system(size: 11))
                    .foregroundStyle(Palette.muted)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(color, in: RoundedRectangle(cornerRadius: 17))
    }
}

struct DestinationPage<Content: View>: View {
    private let title: String
    private let description: String
    private let step: String
    private let content: Content

    init(title: String, description: String, step: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.step = step
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 43, weight: .bold, design: .serif))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 25)
                Text(description)
                    .font(.system(size: 15))
                    .lineSpacing(4)
                    .foregroundStyle(Palette.muted)
                    .padding(.top, 12)
                content
            }
            .frame(maxWidth: 560, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.cream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text(step)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(Palette.muted)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.16)))
            }
        }
    }
}
