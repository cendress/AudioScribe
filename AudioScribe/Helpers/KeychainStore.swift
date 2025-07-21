//
//  KeychainStore.swift
//  AudioScribe
//
//  Created by Christopher Endress on 7/20/25.
//

import Foundation
import Security

// Strongly typed errors emitted by KeychainStore
enum KeychainError: LocalizedError {
    case duplicateItem
    case itemNotFound
    case unexpectedStatus(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .duplicateItem: return "Item with the same key already exists."
        case .itemNotFound: return "Item not found in Keychain."
        case .unexpectedStatus(let status):
            return "Keychain error (OSStatus = \(status))."
        }
    }
}

struct KeychainStore {
    static let shared = KeychainStore()
    private init() {}
    
    func save(value: String, key: String, access: CFString = kSecAttrAccessibleAfterFirstUnlock) throws -> Void {
        guard let data = value.data(using: .utf8) else { return }
        try save(data: data, key: key, access: access)
    }
    
    func fetch(key: String) throws -> String {
        let data = try fetchData(key: key)
        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedStatus(errSecDecode)
        }
        
        return string
    }
    
    func save(data: Data, key: String, access: CFString = kSecAttrAccessibleAfterFirstUnlock) throws -> Void {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: access
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            return
        case errSecDuplicateItem:
            // Update existing
            let attributesToUpdate = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        default: throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func fetchData(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                throw KeychainError.unexpectedStatus(errSecInternalError)
            }
            return data
        case errSecItemNotFound: throw KeychainError.itemNotFound
        default: throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func delete(key: String) throws -> Void {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        switch status {
        case errSecSuccess, errSecItemNotFound: return
        default: throw KeychainError.unexpectedStatus(status)
        }
    }
}
