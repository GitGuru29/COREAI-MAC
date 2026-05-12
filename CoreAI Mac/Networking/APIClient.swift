import Foundation

final class APIClient {
    private let settingsStore: SettingsStore
    private let keychainService: KeychainService
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    /// A dedicated session tuned for long-running LLM streaming across a local network.
    ///
    /// Key settings:
    /// - `timeoutIntervalForRequest`  = requestTimeout (600 s) — max idle gap between any two bytes.
    /// - `timeoutIntervalForResource` = 0              — **unlimited** total transfer time; a large
    ///   generation is never killed by the OS resource watchdog.
    /// - `waitsForConnectivity`       = true           — queue the request instead of failing
    ///   immediately when the interface is briefly unavailable (e.g. Wi-Fi roam).
    static let longRunningSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = RequestBuilder.requestTimeout
        config.timeoutIntervalForResource = 0      // unlimited — never kill a long generation
        config.waitsForConnectivity       = true   // survive brief Wi-Fi blips instead of failing
        return URLSession(configuration: config)
    }()

    init(
        settingsStore: SettingsStore,
        keychainService: KeychainService,
        session: URLSession = APIClient.longRunningSession
    ) {
        self.settingsStore = settingsStore
        self.keychainService = keychainService
        self.session = session
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func encodeBody<T: Encodable>(_ value: T) throws -> Data {
        try encoder.encode(value)
    }

    func send<Response: Decodable>(_ endpoint: APIEndpoint<Response>) async throws -> Response {
        let builder = RequestBuilder(
            settingsStore: settingsStore,
            keychainService: keychainService
        )
        let request = try builder.build(for: endpoint)

        do {
            let (data, response) = try await session.data(for: request)
            return try decodeResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.requestTimedOut
        } catch {
            throw APIError.transportError(error.localizedDescription)
        }
    }

    func stream<Response: Decodable>(
        _ endpoint: APIStreamingEndpoint<Response>
    ) throws -> AsyncThrowingStream<Response, Error> {
        let builder = RequestBuilder(
            settingsStore: settingsStore,
            keychainService: keychainService
        )
        let request = try builder.build(for: endpoint)

        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }

                    guard (200...299).contains(httpResponse.statusCode) else {
                        var buffer = Data()
                        for try await byte in bytes {
                            buffer.append(byte)
                        }
                        let backendError = try? decoder.decode(BackendErrorResponse.self, from: buffer)
                        throw APIError.map(statusCode: httpResponse.statusCode, backend: backendError)
                    }

                    for try await line in bytes.lines {
                        try Task.checkCancellation()
                        if let payload: Response = try SSEParser.parseDataLine(line, decoder: decoder) {
                            continuation.yield(payload)
                        }
                    }

                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch let error as APIError {
                    continuation.finish(throwing: error)
                } catch let error as URLError where error.code == .timedOut {
                    continuation.finish(throwing: APIError.requestTimedOut)
                } catch {
                    continuation.finish(throwing: APIError.transportError(error.localizedDescription))
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func decodeResponse<Response: Decodable>(data: Data, response: URLResponse) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let backendError = try? decoder.decode(BackendErrorResponse.self, from: data)
            throw APIError.map(statusCode: httpResponse.statusCode, backend: backendError)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
