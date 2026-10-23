import Combine
import Foundation

final class ScratchCardRepository: ObservableObject {
    private let cardScratcher: CardScratcher
    private let scratchCardApi: ScratchCardApi
    @Published private(set) var card: CardState
    @Published private(set) var isActivating = false
    @Published private(set) var activationError: ActivationError?
    private var ongoingScratchingCardRequestId: UUID?

    init(
        cardScratcher: CardScratcher,
        scratchCardApi: ScratchCardApi
    ) {
        self.cardScratcher = cardScratcher
        self.scratchCardApi = scratchCardApi
        card = .unscratched
    }

    func reset() {
        ongoingScratchingCardRequestId = nil
        card = .unscratched
        activationError = nil
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
            let code = try await cardScratcher.scratch()
            guard ongoingScratchingCardRequestId == scratchingRequestId else { return }
            card = .scratched(code)
        } catch {
            // Navigating back cancels the local reveal demonstration.
        }
    }

    func activateCard() {
        guard case .scratched(let code) = card, !isActivating else { return }
        isActivating = true
        Task {
            defer { isActivating = false }
            activationError = nil
            do {
                try await scratchCardApi.activateCard(code: code)
                if case .scratched(let currentCode) = card, currentCode == code {
                    card = .activated(code)
                }
            } catch let error as ActivationError {
                if case .scratched(let currentCode) = card, currentCode == code {
                    activationError = error
                }
            } catch {
                if case .scratched(let currentCode) = card, currentCode == code {
                    activationError = .requestFailed
                }
            }
        }
    }

    func dismissActivationError() {
        activationError = nil
    }
}
