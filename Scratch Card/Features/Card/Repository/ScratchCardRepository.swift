import Combine
import Clocks
import Foundation

// Local presentation state lets the screens be explored without an API or data layer.
final class ScratchCardRepository: ObservableObject {
    private let clock: any Clock<Duration>
    @Published var card: CardState = .unscratched
    @Published var isRevealing = false
    @Published var isActivating = false
    private var revealTask: Task<Void, Never>?
    private var revealGeneration = UUID()

    init(clock: any Clock<Duration> = ContinuousClock()) {
        self.clock = clock
    }

    func reset() {
        cancelReveal()
        card = .unscratched
    }

    func startReveal() {
        guard card == .unscratched, !isRevealing else { return }
        let generation = UUID()
        revealGeneration = generation
        isRevealing = true
        revealTask = Task {
            do {
                try await clock.sleep(for: .seconds(2))
                try Task.checkCancellation()
                guard revealGeneration == generation else { return }
                card = .scratched(UUID().uuidString)
            } catch {
                // Navigating back cancels the local reveal demonstration.
            }
            if revealGeneration == generation {
                isRevealing = false
                revealTask = nil
            }
        }
    }

    func cancelReveal() {
        revealGeneration = UUID()
        revealTask?.cancel()
        revealTask = nil
        isRevealing = false
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
