//
//  BiometricService.swift
//  dsl
//
//  Created by chuang chin yuen on 6/2/2024.
//

import Foundation
import SwiftKeychainWrapper
import SwiftJWT
import LocalAuthentication

enum KeychainStorage{
            
    static func saveCredentials(_ credentials: Credentials) throws {
        // Use the username as the account, and get the password as data.
        let data = credentials.refreshToken.data(using: String.Encoding.utf8)!
        
        // Create an access control instance that dictates how the item can be read later.
        let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
                                                     //kSecAttrAccessibleAlways,
                                                     kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                     .biometryCurrentSet,
                                                     nil) // Ignore any error.

        // Allow a device unlock in the last 10 seconds to be used to get at keychain items.
//        let context = LAContext()
        //context.touchIDAuthenticationAllowableReuseDuration = 10
       // context.localizedFallbackTitle = ""

        // Build the query for use in the add operation.
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: "token",
                                    kSecAttrServer as String: "dsl",
                                    kSecAttrAccessControl as String: access as Any,
//                                    kSecUseAuthenticationContext as String: context,
                                    kSecValueData as String: data]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
    
    static func saveCredentialsInfo(_ credentials: CredentialsInfo) throws {
        // Use the username as the account, and get the password as data.
        let data = credentials.sub.data(using: String.Encoding.utf8)!
        

        // Build the query for use in the add operation.
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: "info",
                                    kSecAttrServer as String: "dsl",
                                    kSecValueData as String: data]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
        
    static func getCredentials() throws -> Credentials {
        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: "token",
            kSecAttrServer as String: "dsl",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError(status: status)
            } else if status == errSecAuthFailed {
                throw KeychainError(status: status)
            } else {
                throw KeychainError(status: status)
            }
        }
        
        guard let existingItem = item as? [String: Any],
              let refreshTokenData = existingItem[kSecValueData as String] as? Data,
              let refreshToken = String(data: refreshTokenData, encoding: .utf8) else {
            throw KeychainError(status: errSecInternalError)
        }
        
        return Credentials(refreshToken: refreshToken)
    }
    
    static func getCredentialsInfo() throws -> CredentialsInfo {
      //  context.localizedReason = "Access your password on the keychain"
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: "info",
                                    kSecAttrServer as String: "dsl",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { throw KeychainError(status: status) }

        guard let existingItem = item as? [String: Any],
            let subData = existingItem[kSecValueData as String] as? Data,
            let sub = String(data: subData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError(status: errSecInternalError)
        }

        return CredentialsInfo(sub: sub)
    }

    static func hasCredentials(Account: String) -> Bool {

        let query: [String: Any] = [
            kSecClass as String: kSecClassInternetPassword,
            kSecAttrAccount as String: Account,
            kSecAttrServer as String: "dsl",
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        return status == errSecSuccess
    }

    static func deleteCredentials() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: "dsl"]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }
        
    static func decodeRFToken() -> OfflineTokenClaims? {
        do {
            let credentials = try getCredentials()
            Logger.info(data: "Decode token success")
            //Logger.info(data: "Read credentials: \(credentials.refreshToken)")
            do {
                let jwt = try JWT<OfflineTokenClaims>(jwtString: credentials.refreshToken)
                return jwt.claims
            } catch {
                print(error)
                return nil
            }
        }
        catch{
            if let error = error as? KeychainError {
                Logger.error(data: error.localizedDescription)
            }
            return nil
        }
    }
    
    static func decodeSub() -> String?{
        do {
            let credentials = try getCredentialsInfo()
            let String = credentials.sub
            Logger.info(data: "Decode sub success")
            //Logger.info(data: "Read credentials: \(credentials.refreshToken)")
            return String
        }
        catch{
            if let error = error as? KeychainError {
                Logger.error(data: error.localizedDescription)
            }
            return nil
        }
    }
}

struct KeychainError: Error {
    var status: OSStatus

    var localizedDescription: String {
        return SecCopyErrorMessageString(status, nil) as String? ?? "Unknown error."
    }
}

struct CredentialsInfo: Codable {
    var sub: String = ""
}

struct Credentials: Codable {
    var refreshToken: String = ""
    
    func encoded() -> String {
        let encoder = JSONEncoder()
        let credentialsData = try! encoder.encode(self)
        return String(data: credentialsData, encoding: .utf8)!
    }
    
    static func decode(_ credentialsString: String) -> Credentials{
        let decoder = JSONDecoder()
        let jsonData = credentialsString.data(using: .utf8)
        return try! decoder.decode((Credentials.self), from: jsonData!)
    }
}

struct OfflineTokenClaims: Claims {
    var sub: String
}


