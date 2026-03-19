import Foundation
import Security

struct DefaultKeychainService: KeychainService {
    private let service = "com.coreai.mac"
    private let account = "coreai.api-key"

    func saveAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query = baseQuery.merging([kSecValueData: data]) { _, newValue in newValue }
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            try updateAPIKey(apiKey)
            return
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }
    }

    func readAPIKey() throws -> String? {
        var query = baseQuery
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }

        guard let data = item as? Data, let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }

        return value
    }

    func updateAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let updateQuery = [kSecValueData: data] as CFDictionary
        let status = SecItemUpdate(baseQuery as CFDictionary, updateQuery)

        if status == errSecItemNotFound {
            try saveAPIKey(apiKey)
            return
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }
    }

    func deleteAPIKey() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status: status)
        }
    }

    private var baseQuery: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
    }
}

enum KeychainError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case unhandled(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "The API key could not be encoded for secure storage."
        case .decodingFailed:
            return "The API key could not be read from secure storage."
        case .unhandled(let status):
            return "A Keychain operation failed with status \(status)."
        }
    }
}
