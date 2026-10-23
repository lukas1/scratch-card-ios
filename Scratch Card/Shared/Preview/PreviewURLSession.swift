#if !CODE_COVERAGE
import Foundation

struct PreviewURLSession {
    enum Response {
        case version(String)
        case failure
    }

    let baseURL: URL
    let session: URLSession

    init(response: Response = .version("6.24")) {
        let host = "\(UUID().uuidString.lowercased()).preview.invalid"
        baseURL = URL(string: "https://\(host)/")!

        let (statusCode, data): (Int, Data)
        switch response {
        case .version(let version):
            statusCode = 200
            data = Data(#"{"ios":"\#(version)"}"#.utf8)
        case .failure:
            statusCode = 503
            data = Data()
        }
        PreviewURLProtocol.register(host: host, statusCode: statusCode, data: data)

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PreviewURLProtocol.self]
        session = URLSession(configuration: configuration)
    }
}

private class PreviewURLProtocol: URLProtocol {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var responses: [String: (statusCode: Int, data: Data)] = [:]

    static func register(host: String, statusCode: Int, data: Data) {
        lock.lock()
        defer { lock.unlock() }
        responses[host] = (statusCode, data)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let host = request.url?.host else { return }
        Self.lock.lock()
        let response = Self.responses[host]
        Self.lock.unlock()
        guard let response,
              let url = request.url,
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

    override func stopLoading() {}
}
#endif
