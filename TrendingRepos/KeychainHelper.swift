//
//  KeychainHelper.swift
//  TrendingRepos
//
//  Created by Matt Pengelly on 2023-07-04.
//
import Foundation
import Security

// using baremetal api for securely storing access_token to IOS Keychain for persistent login
// these come from the IOS Keychain documentation itself, so its save to use
struct KeychainHelper {
    private static let service: String = Bundle.main.bundleIdentifier ?? "defaultBundleID"

    static func set(_ key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrService as String: service,
                                     kSecAttrAccount as String: key,
                                     kSecValueData as String: data]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func get(_ key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrService as String: service,
                                     kSecAttrAccount as String: key,
                                     kSecReturnData as String: kCFBooleanTrue!,
                                     kSecMatchLimit as String: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    static func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

extension KeychainHelper {
    static func setBool(_ key: String, value: Bool) -> Bool {
        return set(key, value: String(value))
    }

    static func getBool(_ key: String) -> Bool? {
        if let stringValue = get(key) {
            return Bool(stringValue)
        }
        return nil
    }
}
