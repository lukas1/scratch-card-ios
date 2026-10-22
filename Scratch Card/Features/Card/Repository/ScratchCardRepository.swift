import Combine
import Clocks
import Foundation

// Local presentation state lets the screens be explored without an API or data layer.
final class ScratchCardRepository: ObservableObject {
    private let clock: any Clock<Duration>
    @Published var card: CardState = .unscratched
    @Published var isActivating = false
    private var ongoingScratchingCardRequestId: UUID?

    init(clock: any Clock<Duration> = ContinuousClock()) {
        self.clock = clock
    }

    func reset() {
        ongoingScratchingCardRequestId = nil
        card = .unscratched
    }

    func scratchCard() async {
        guard card == .unscratched, ongoingScratchingCardRequestId == nil else { return }
        let scratchingRequestId = UUID()
        ongoingScratchingCardRequestId = scratchingRequestId

        defer {
            if scratchingRequestId == ongoingScratchingCardRequestId {
                ongoingScratchingCardRequestId = nil
            }
        }

        do {
            try await clock.sleep(for: .seconds(2))
            try Task.checkCancellation()
            guard ongoingScratchingCardRequestId == scratchingRequestId else { return }
            card = .scratched(UUID().uuidString)
        } catch {
            // Navigating back cancels the local reveal demonstration.
        }
    }

    func activateForDemo() {
        guard case .scratched(let code) = card, !isActivating else { return }
        isActivating = true
        Task {
            try? await clock.sleep(for: .seconds(1))
            if case .scratched(let currentCode) = card, currentCode == code {
                card = .activated(code)
            }
            isActivating = false
        }
    }
}
