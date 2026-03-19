import Foundation

protocol KeychainService {
    func saveAPIKey(_ apiKey: String) throws
    func readAPIKey() throws -> String?
    func updateAPIKey(_ apiKey: String) throws
    func deleteAPIKey() throws
}
