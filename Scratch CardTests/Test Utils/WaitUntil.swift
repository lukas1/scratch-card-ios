import Foundation

@MainActor
func waitUntil(
    maxAttempts: Int = 100,
    interval: Duration = .milliseconds(10),
    _ condition: () -> Bool
) async throws -> Bool {
    for _ in 0..<maxAttempts {
        if condition() { return true }
        try await Task.sleep(for: interval)
    }
    return condition()
}

@MainActor
func waitUntilExists<Value>(
    maxAttempts: Int = 100,
    interval: Duration = .milliseconds(10),
    _ lookup: () throws -> Value
) async throws -> Bool {
    try await waitUntil(maxAttempts: maxAttempts, interval: interval) {
        (try? lookup()) != nil
    }
}
