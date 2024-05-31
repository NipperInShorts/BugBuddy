//
//  AccountModel.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import Foundation
import SwiftData

enum AccountType: Codable {
    case bugsnag
}

struct Credentials {
    var apiKey: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

@Model
class Account: Codable {
    
    enum CodingKeys: CodingKey {
        case id, title, type
    }
    
    var title: String
    @Attribute(.unique) let id: UUID
    var type: AccountType
    
    init(title: String, type: AccountType = .bugsnag) {
        self.title = title
        self.id = UUID()
        self.type = type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        type = try container.decode(AccountType.self, forKey: .type)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(type, forKey: .type)
    }
    
    static func examples() -> [Account] {
        [
            Account(title: "TechStyle"),
            Account(title: "Code Daddys"),
        ]
    }
    
    func getApiKey(service: String = "bugsnag", account: String) throws -> String {
        let query: [String: Any] = [
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        
        guard let existingItem = item as? [String : Any],
            let apiKeyData = existingItem[kSecValueData as String] as? Data,
            let apiKey = String(data: apiKeyData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        let credentials = Credentials(apiKey: apiKey)

        return credentials.apiKey
    }
    
    func saveApiKey(for key: String, service: String, account: String) throws {
        let data = key.data(using: String.Encoding.utf8)!
        
        let query: [String: Any] = [
            kSecValueData as String: data,
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
    
    func deleteApiKey(account: String, service: String) throws {
        let query: [String: Any] = [
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: true
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
}

extension Account {
    
    static var emptyAccount: Account {
        Account(title: "")
    }
    
}
