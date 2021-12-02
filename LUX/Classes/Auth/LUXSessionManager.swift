//
//  LUXSessionManager.swift
//  LUX/Auth
//
//  Created by Elliot Schrock on 7/15/19.
//

import Foundation
import Slippers
import Security
import LithoOperators

@objc public protocol LUXSession {
    @objc func authHeaders() -> [String: String]?
    @objc var host: String { get }
    
    @objc func setAuthValue(authString: String)
    @objc func isAuthenticated() -> Bool
    @objc func clearAuth()
}

open class LUXSessionManager: NSObject {
    public static var primarySession: LUXSession?
    public static var allSessions: [LUXSession] = [LUXSession]()
    
    public static func sessionFor(host: String) -> LUXSession? {
        for session in allSessions {
            if session.host == host {
                return session
            }
        }
        return nil
    }
}

open class LUXKeyChainSession: LUXSession {
    public var host: String
    public let authHeaderKey: String
    
    public init(host: String, authHeaderKey: String) {
        self.host = host
        self.authHeaderKey = authHeaderKey
    }
    
    public func authHeaders() -> [String : String]? {
        var item: CFTypeRef?
        let _ = SecItemCopyMatching(authRetrieveQueryDictionary(host) as CFDictionary, &item)
        
        if let existingItem = item as? [String : Any],
           let keyData = existingItem[kSecValueData as String] as? Data,
           let apiKey = String(data: keyData, encoding: String.Encoding.utf8) {
            return [authHeaderKey: apiKey]
        }
        
        return nil
    }
    
    
    public func setAuthValue(authString: String) {
        if let _ = authHeaders() {
            let status = SecItemUpdate(authUpdateQueryDictionary(host) as CFDictionary, authUpdateAttrsDictionary(authString) as CFDictionary)
            print(status)
        } else {
            let status = SecItemAdd(authAddQueryDictionary(host, authString) as CFDictionary, nil)
            print(status)
        }
    }
    
    public func isAuthenticated() -> Bool {
        return authHeaders() != nil
    }
    
    public func clearAuth() {
        let _ = SecItemDelete(authUpdateQueryDictionary(host) as CFDictionary)
    }
}

public func authUpdateAttrsDictionary(_ value: String) -> [String: Any] {
    return [kSecValueData as String: value]
}

public func authAddQueryDictionary(_ server: String, _ value: String) -> [String: Any] {
    if let data = value.data(using: .utf8) {
        return baseAuthQueryDictionary(server) << [kSecValueData as String: data]
    } else {
        return baseAuthQueryDictionary(server)
    }
}

public func authRetrieveQueryDictionary(_ server: String) -> [String: Any] {
    return baseAuthQueryDictionary(server) << [kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true]
}

public func authUpdateQueryDictionary(_ server: String) -> [String: Any] {
    return baseAuthQueryDictionary(server)
}

public func baseAuthQueryDictionary(_ server: String) -> [String: Any] {
    return [kSecClass as String: kSecClassInternetPassword,
            kSecAttrServer as String: server]
}

open class LUXAppGroupUserDefaultsSession: LUXSession {
    public let host: String
    public let authHeaderKey: String
    public let userDefaults: UserDefaults
    
    public init(host: String, authHeaderKey: String, userDefaults: UserDefaults = UserDefaults.standard) {
        self.host = host
        self.authHeaderKey = authHeaderKey
        self.userDefaults = userDefaults
    }
    
    open func authHeaders() -> [String: String]? {
        return [authHeaderKey: userDefaults.string(forKey: host) ?? ""]
    }
    
    open func setAuthValue(authString: String) {
        userDefaults.set(authString, forKey: host)
        userDefaults.synchronize()
    }

    open func clearAuth() {
        userDefaults.removeObject(forKey: host)
    }
    
    open func isAuthenticated() -> Bool {
        let apiKey = userDefaults.string(forKey: host)
        return apiKey != nil && apiKey != ""
    }
}

open class LUXMultiHeaderDefaultsSession: LUXSession {
    public let host: String
    public let headers: [String: String]
    public let userDefaults: UserDefaults
    
    public init(host: String, authHeaders: [String: String], userDefaults: UserDefaults = UserDefaults.standard) {
        self.host = host
        self.headers = authHeaders
        self.userDefaults = userDefaults
    }
    
    open func authHeaders() -> [String: String]? {
        return userDefaults.dictionary(forKey: host) as? [String: String]
    }
    
    public func setAuthValue(authString: String) {}
    
    open func setAuthHeaders(dict authHeaders: [String: String]) {
        userDefaults.set(authHeaders, forKey: host)
        userDefaults.synchronize()
    }
    
    open func clearAuth() {
        userDefaults.removeObject(forKey: host)
    }
    
    open func isAuthenticated() -> Bool {
        if let headers = userDefaults.dictionary(forKey: host) as? [String: String] {
            if headers.keys.count == 0 { return false }
            for key in headers.keys {
                if let value = headers[key] {
                    if value.isEmpty { return false }
                } else {
                    return false
                }
            }
            return true
        }
        return false
    }
}

open class LUXUserDefaultsSession: LUXAppGroupUserDefaultsSession {
    public init(host: String, authHeaderKey: String) {
        super.init(host: host, authHeaderKey: authHeaderKey)
    }
}

public func saveJWT<T:AuthKeyProvider>(data: Data, wrapper: T.Type, hostname: String) -> Bool {
    let loginData = JsonProvider.decode(wrapper, from: data)
    if let authToken = loginData?.apiKey, let session = LUXSessionManager.primarySession {
        session.setAuthValue(authString: "Bearer \(authToken)")
        LUXSessionManager.primarySession = session
        return true
    }
    return false
}

public protocol AuthKeyProvider: Codable {
    var apiKey: String? { get set }
}
