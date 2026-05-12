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

        // When the standard SSE end-of-stream sentinel "[DONE]" is received,
        // synthesize a final event with `done: true` so the view models
        // know the stream completed normally and was not interrupted.
        guard jsonString != "[DONE]" else {
            let doneJson = """
            {"model": "", "chunk": "", "done": true}
            """
            guard let data = doneJson.data(using: .utf8) else { return nil }
            return try? decoder.decode(Response.self, from: data)
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw APIError.decodingFailed
        }

        return try decoder.decode(Response.self, from: data)
    }
}
