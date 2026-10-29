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
    private var isReleased = false
    private var requestContinuation: CheckedContinuation<Void, Never>?
    private var releaseContinuation: CheckedContinuation<Void, Never>?

    func waitUntilRequested() async {
        guard !hasReceivedRequest else { return }
        await withCheckedContinuation { continuation in
            requestContinuation = continuation
        }
    }

    func waitUntilReleased() async {
        guard !isReleased else { return }
        await withCheckedContinuation { continuation in
            releaseContinuation = continuation
        }
    }

    func requestReceived() {
        hasReceivedRequest = true
        requestContinuation?.resume()
        requestContinuation = nil
    }

    func release() {
        isReleased = true
        releaseContinuation?.resume()
        releaseContinuation = nil
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

        Task {
            if let gate = response.gate {
                await gate.requestReceived()
                await gate.waitUntilReleased()
            }
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

    override func stopLoading() {}
}
