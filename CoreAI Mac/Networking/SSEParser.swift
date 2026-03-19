import Foundation

enum SSEParser {
    static func parseDataLine<Response: Decodable>(
        _ line: String,
        decoder: JSONDecoder
    ) throws -> Response? {
        guard line.hasPrefix("data: ") else {
            return nil
        }

        let jsonString = String(line.dropFirst(6))
        guard let data = jsonString.data(using: .utf8) else {
            throw APIError.decodingFailed
        }

        return try decoder.decode(Response.self, from: data)
    }
}
