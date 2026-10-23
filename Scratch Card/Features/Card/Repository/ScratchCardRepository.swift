import Combine
import Foundation

final class ScratchCardRepository: ObservableObject {
    private let cardScratcher: CardScratcher
    private let scratchCardApi: ScratchCardApi
    private let alertPresenter: AlertPresenter
    @Published private(set) var card: CardState
    @Published private(set) var isActivating = false
    private var ongoingScratchingCardRequestId: UUID?

    init(
        cardScratcher: CardScratcher,
        scratchCardApi: ScratchCardApi,
        alertPresenter: AlertPresenter
    ) {
        self.cardScratcher = cardScratcher
        self.scratchCardApi = scratchCardApi
        self.alertPresenter = alertPresenter
        card = .unscratched
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
            do {
                try await scratchCardApi.activateCard(code: code)
                if case .scratched(let currentCode) = card, currentCode == code {
                    card = .activated(code)
                }
            } catch let error as ActivationError {
                if case .scratched(let currentCode) = card, currentCode == code {
                    present(error)
                }
            }
        }
    }

    private func present(_ error: ActivationError) {
        alertPresenter.alert = Alert(
            title: String(localized: .activationErrorTitle),
            message: error.message
        )
    }
}
