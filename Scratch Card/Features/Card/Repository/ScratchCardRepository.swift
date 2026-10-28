import Foundation
import Observation

@Observable
final class ScratchCardRepository {
    private let cardScratcher: CardScratcher
    private let scratchCardApi: ScratchCardApi
    private let alertPresenter: AlertPresenter
    private(set) var card: CardState
    private(set) var isActivating = false
    private var ongoingScratchingCardRequestId: UUID?
    private var activationTask: Task<Void, Never>?
    private var activationRequestId: UUID?

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
        activationRequestId = nil
        activationTask?.cancel()
        activationTask = nil
        isActivating = false
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
        let requestId = UUID()
        activationRequestId = requestId
        isActivating = true
        activationTask = Task {
            defer {
                if activationRequestId == requestId {
                    activationRequestId = nil
                    activationTask = nil
                    isActivating = false
                }
            }

            do {
                try await scratchCardApi.activateCard(code: code)
                guard activationRequestId == requestId else { return }
                if case .scratched(let currentCode) = card, currentCode == code {
                    card = .activated(code)
                }
            } catch let error as ActivationError {
                guard activationRequestId == requestId else { return }
                if case .scratched(let currentCode) = card, currentCode == code {
                    present(error)
                }
            } catch {
                // The API currently maps request errors to ActivationError.
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
