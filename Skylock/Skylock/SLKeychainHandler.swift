//
//  SLKeychainHandler.swift
//  Skylock
//
//  Created by Andre Green on 1/2/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation
import Security

@objc public enum SLKeychainHandlerCase: Int {
    case PublicKey
    case SignedMessage
    case ChallengeKey
    case Password
    case RestToken
}

@objc public class SLKeychainHandler: NSObject {
    private let kSecClassValue = NSString(format: kSecClass) as String
    private let kSecAttrAccountValue = NSString(format: kSecAttrAccount) as String
    private let kSecValueDataValue = NSString(format: kSecValueData) as String
    private let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword) as String
    private let kSecAttrServiceValue = NSString(format: kSecAttrService) as String
    private let kSecMatchLimitValue = NSString(format: kSecMatchLimit) as String
    private let kSecReturnDataValue = NSString(format: kSecReturnData) as String
    private let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne) as String
    
    private let prefix = "skylock."
    
    
    @objc public func getItemForUsername(userName: String, additionalSeviceInfo: String?, handlerCase: SLKeychainHandlerCase) -> String? {
        let service:String = self.getService(additionalSeviceInfo, handlerCase: handlerCase)
        return self.get(userName, service: service)
    }
    
    @objc public func setItemForUsername(userName: String, inputValue: String, additionalSeviceInfo: String?, handlerCase: SLKeychainHandlerCase) {
        let service:String = self.getService(additionalSeviceInfo, handlerCase: handlerCase)
        self.save(userName, service: service, value: inputValue)
    }
    
    @objc public func deleteItemForUsername(userName: String, additionalServiceInfo: String?, handlerCase: SLKeychainHandlerCase) -> Bool {
        let service = self.stringForHandlerCase(handlerCase)
        let keychainQuery:[String:AnyObject] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: userName,
        ]
        
        return SecItemDelete(keychainQuery as CFDictionaryRef) == errSecSuccess
    }
    
    private func getService(additionaServiceInfo: String?, handlerCase: SLKeychainHandlerCase) -> String {
        var key:String = self.stringForHandlerCase(handlerCase)
        if let addServiceInfo = additionaServiceInfo {
            key += ".\(addServiceInfo)"
        }
        
        return self.prefix + key
    }
    
    private func save(userName: String, service: String, value: String) {
        guard let data:NSData = value.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) else {
            print("Error: cannot encode string in SLKeychainHanlder save method")
            return;
        }
        
        let keychainQuery:[String:AnyObject] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: userName,
            kSecValueDataValue: data
        ]
        
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
        print("saved item to key chain with status \(status)")
    }
    
    private func get(userName: String, service: String) -> String? {
        let keychainQuery:[String:AnyObject] = [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: service,
            kSecAttrAccountValue: userName,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue
        ]

        
        var result: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &result)
        if status == errSecSuccess {
            if let data = result as? NSData, let value = NSString(data: data, encoding:NSUTF8StringEncoding) as? String {
                return value
            }
        }
        
        print("Error: could not retreive value from keychain")
        return nil
    }
    
    private func stringForHandlerCase(handlerCase: SLKeychainHandlerCase) -> String {
        let handlerCaseString: String
        switch handlerCase {
        case .ChallengeKey:
            handlerCaseString = "challenge.key"
        case .SignedMessage:
            handlerCaseString = "signed.message"
        case .PublicKey:
            handlerCaseString = "public.key"
        case .Password:
            handlerCaseString = "password"
        case .RestToken:
            handlerCaseString = "rest.token"
        }
        
        return self.prefix + handlerCaseString
    }
}
