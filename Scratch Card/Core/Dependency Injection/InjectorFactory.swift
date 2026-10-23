import Clocks
import Foundation

enum InjectorFactory {
    static func real(baseURL: URL) -> any Injector {
#if UI_TESTING
        let codeGenerator: ScratchCardCodeGenerator = { "SC-4829-7316" }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [SuccessfulResponseURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let clock: any Clock<Duration> = CommandLine.arguments.contains("-ui-test-pending-reveal")
            ? TestClock()
            : ImmediateClock()
        return SharedInjector(
            clock: clock,
            codeGenerator: codeGenerator,
            baseURL: baseURL,
            session: session
        )
#else
        return SharedInjector(baseURL: baseURL, session: .shared)
#endif
    }
}

#if UI_TESTING
private class SuccessfulResponseURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              let response = HTTPURLResponse(
                url: url,
                statusCode: ProcessInfo.processInfo.arguments.contains("-ui-test-activation-failure") ? 503 : 200,
                httpVersion: nil,
                headerFields: nil
              ) else { return }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        if response.statusCode == 200 {
            client?.urlProtocol(self, didLoad: Data(#"{"ios":"6.24"}"#.utf8))
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
#endif
