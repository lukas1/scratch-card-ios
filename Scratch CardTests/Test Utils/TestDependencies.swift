import Foundation

struct TestURLSession {
    let baseURL: URL
    let session: URLSession
    private let host: String

    init(
        statusCode: Int = 200,
        responseData: Data = Data(#"{"ios":"6.24"}"#.utf8),
        responseGate: TestResponseGate? = nil
    ) {
        let host = "\(UUID().uuidString.lowercased()).example.com"
        self.host = host
        baseURL = URL(string: "https://\(host)/")!
        StubURLProtocol.register(
            host: host,
            response: .init(statusCode: statusCode, data: responseData, gate: responseGate)
        )

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    var receivedRequest: URLRequest? {
        StubURLProtocol.receivedRequest(for: host)
    }

    var receivedRequestCount: Int {
        StubURLProtocol.receivedRequestCount(for: host)
    }
}

actor TestResponseGate {
    private var hasReceivedRequest = false
    private var areResponsesResumed = false
    private var requestContinuations: [UUID: CheckedContinuation<Void, Never>] = [:]
    private var responseContinuations: [UUID: CheckedContinuation<Void, Never>] = [:]

    func waitUntilRequested() async {
        guard !hasReceivedRequest else { return }
        let waiterID = UUID()
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                guard !hasReceivedRequest, !Task.isCancelled else {
                    continuation.resume()
                    return
                }
                requestContinuations[waiterID] = continuation
            }
        } onCancel: {
            Task { await self.cancelRequestWaiter(id: waiterID) }
        }
    }

    func waitUntilResponsesAreResumed() async {
        guard !areResponsesResumed else { return }
        let waiterID = UUID()
        await withTaskCancellationHandler {
            await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                guard !areResponsesResumed, !Task.isCancelled else {
                    continuation.resume()
                    return
                }
                responseContinuations[waiterID] = continuation
            }
        } onCancel: {
            Task { await self.cancelResponseWaiter(id: waiterID) }
        }
    }

    func requestReceived() {
        hasReceivedRequest = true
        requestContinuations.values.forEach { $0.resume() }
        requestContinuations.removeAll()
    }

    func resumeResponses() {
        areResponsesResumed = true
        responseContinuations.values.forEach { $0.resume() }
        responseContinuations.removeAll()
    }

    private func cancelResponseWaiter(id: UUID) {
        responseContinuations.removeValue(forKey: id)?.resume()
    }

    private func cancelRequestWaiter(id: UUID) {
        requestContinuations.removeValue(forKey: id)?.resume()
    }
}

extension ScratchCardModule {
    init(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { UUID().uuidString },
        testSession: TestURLSession
    ) {
        self.init(
            clock: clock,
            codeGenerator: codeGenerator,
            restApiClient: RestApiClient(
                baseURL: testSession.baseURL,
                session: testSession.session
            )
        )
    }
}

extension SharedInjector {
    init(
        clock: any Clock<Duration> = ContinuousClock(),
        codeGenerator: @escaping ScratchCardCodeGenerator = { "SC-4829-7316" },
        testSession: TestURLSession
    ) {
        self.init(
            clock: clock,
            codeGenerator: codeGenerator,
            baseURL: testSession.baseURL,
            session: testSession.session
        )
    }
}

private final class StubURLProtocol: URLProtocol {
    struct Response {
        let statusCode: Int
        let data: Data
        let gate: TestResponseGate?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var responses: [String: Response] = [:]
    nonisolated(unsafe) private static var requests: [String: [URLRequest]] = [:]
    private var loadingTask: Task<Void, Never>?

    static func register(host: String, response: Response) {
        lock.lock()
        defer { lock.unlock() }
        responses[host] = response
        requests[host] = []
    }

    static func receivedRequest(for host: String) -> URLRequest? {
        lock.lock()
        defer { lock.unlock() }
        return requests[host]?.last
    }

    static func receivedRequestCount(for host: String) -> Int {
        lock.lock()
        defer { lock.unlock() }
        return requests[host]?.count ?? 0
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let host = request.url?.host else { return }
        Self.lock.lock()
        let response = Self.responses[host]
        Self.requests[host, default: []].append(request)
        Self.lock.unlock()
        guard let response else { return }

        loadingTask = Task {
            if let gate = response.gate {
                await gate.requestReceived()
                await gate.waitUntilResponsesAreResumed()
            }
            guard !Task.isCancelled else { return }
            guard let url = request.url,
                  let httpResponse = HTTPURLResponse(
                    url: url,
                    statusCode: response.statusCode,
                    httpVersion: nil,
                    headerFields: nil
                  ) else { return }
            client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: response.data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        loadingTask?.cancel()
        loadingTask = nil
    }
}
