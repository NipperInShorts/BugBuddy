//
//  AccountModel.swift
//  BugBuddy
//
//  Created by Justin Nipper on 5/14/24.
//

import Foundation

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

struct Account: Identifiable, Hashable, Codable {
    
    var title: String
    let id: UUID
    let type: AccountType
    
    init(title: String, type: AccountType = .bugsnag) {
        self.title = title
        self.id = UUID()
        self.type = type
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
        print("Failed to get internal \(credentials)")
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
        
        print("internal \(status)")
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
        
        print("Failed to delete internal \(status)")

    }
    
}

extension Account {
    
    static var emptyAccount: Account {
        Account(title: "")
    }
    
}

class DataModel: ObservableObject {
    
    @Published var accounts: [Account] = []
    
    init(accounts: [Account] = []) {
        self.accounts = accounts
    }
    
    func addAccount(for account: Account) {
        accounts.append(account)
    }
    
    func addAccount(for account: Account) -> Account? {
        accounts.append(account)
        
        return accounts.first {
            $0.id == account.id
        }
    }
    
    func updateAccount(for account: Account) {
        if let index = accounts.firstIndex(of: account) {
            accounts[index] = account
        }
    }
    
    func removeAccount(for account: Account) {
        accounts.removeAll {
            $0.id == account.id
        }
    }
    
}
