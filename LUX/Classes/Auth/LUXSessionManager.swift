//
//  LUXSessionManager.swift
//  LUX/Auth
//
//  Created by Elliot Schrock on 7/15/19.
//

import Foundation
import Slippers

@objc public protocol LUXSession {
    @objc func authHeaders() -> [String: String]?
    @objc var host: String { get }
    
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
    
    open func setAuthHeaders(authString: String) {
        userDefaults.set(authString, forKey: host)
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
    if let authToken = loginData?.apiKey {
        let session = LUXUserDefaultsSession(host: hostname, authHeaderKey: "Authorization" )
        session.setAuthValue(authString: "Bearer \(authToken)")
        LUXSessionManager.primarySession = session
        return true
    }
    return false
}

public func saveJWTAppGroup<T:AuthKeyProvider>(data: Data, wrapper: T.Type, hostname: String) -> Bool {
    let loginData = JsonProvider.decode(wrapper, from: data)
    if let authToken = loginData?.apiKey {
        let session = LUXAppGroupUserDefaultsSession(host: hostname, authHeaderKey: "Authorization" )
        session.setAuthValue(authString: "Bearer \(authToken)")
        LUXSessionManager.primarySession = session
        return true
    }
    return false
}

public protocol AuthKeyProvider: Codable {
    var apiKey: String? { get set }
}
