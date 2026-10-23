import Foundation

struct TestURLSession {
    let baseURL: URL
    let session: URLSession
    private let host: String

    init(
        statusCode: Int = 200,
        responseData: Data = Data(#"{"ios":"6.24"}"#.utf8),
        delay: Duration = .zero
    ) {
        let host = "\(UUID().uuidString.lowercased()).example.com"
        self.host = host
        baseURL = URL(string: "https://\(host)/")!
        StubURLProtocol.register(
            host: host,
            response: .init(statusCode: statusCode, data: responseData, delay: delay)
        )

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: configuration)
    }

    var receivedRequest: URLRequest? {
        StubURLProtocol.receivedRequest(for: host)
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
        let delay: Duration
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var responses: [String: Response] = [:]
    nonisolated(unsafe) private static var requests: [String: URLRequest] = [:]

    static func register(host: String, response: Response) {
        lock.lock()
        defer { lock.unlock() }
        responses[host] = response
        requests.removeValue(forKey: host)
    }

    static func receivedRequest(for host: String) -> URLRequest? {
        lock.lock()
        defer { lock.unlock() }
        return requests[host]
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let host = request.url?.host else { return }
        Self.lock.lock()
        let response = Self.responses[host]
        Self.requests[host] = request
        Self.lock.unlock()
        guard let response else { return }

        Task {
            if response.delay > .zero {
                try? await Task.sleep(for: response.delay)
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
