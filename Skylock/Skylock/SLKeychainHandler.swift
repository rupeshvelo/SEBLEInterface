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
    
    
    @objc public func getItemForUsername(
        userName: String,
        additionalSeviceInfo: String?,
        handlerCase: SLKeychainHandlerCase
        ) -> String?
    {
        let service:String = self.getService(additionalServiceInfo: additionalSeviceInfo, handlerCase: handlerCase)
        return self.get(userName: userName, service: service)
    }
    
    @objc public func setItemForUsername(
        userName: String,
        inputValue: String,
        additionalSeviceInfo: String?,
        handlerCase: SLKeychainHandlerCase
        )
    {
        let service:String = self.getService(additionalServiceInfo: additionalSeviceInfo, handlerCase: handlerCase)
        self.save(userName: userName, service: service, value: inputValue)
    }
    
    @objc public func deleteItemForUsername(
        userName: String,
        additionalServiceInfo: String?,
        handlerCase: SLKeychainHandlerCase) -> Bool
    {
        
        let service:String = self.getService(additionalServiceInfo: additionalServiceInfo, handlerCase: handlerCase)
        return self.delete(userName: userName, service: service)
    }
    
    private func getService(additionalServiceInfo: String?, handlerCase: SLKeychainHandlerCase) -> String {
        var key:String = self.stringForHandlerCase(handlerCase: handlerCase)
        if let addServiceInfo = additionalServiceInfo {
            key += ".\(addServiceInfo)"
        }
        
        return self.prefix + key
    }
    
    private func save(userName: String, service: String, value: String) {
        guard let data:Data = value.data(using: String.Encoding.utf8) else {
            print("Error: cannot encode string in SLKeychainHanlder save method")
            return;
        }
        
        let keychainQuery:[String:Any] = [
            kSecClassValue: kSecClassGenericPasswordValue as AnyObject,
            kSecAttrServiceValue: service as AnyObject,
            kSecAttrAccountValue: userName as AnyObject,
            kSecValueDataValue: data
        ]
        
        SecItemDelete(keychainQuery as CFDictionary)
        
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        print("saved item to key chain with status \(status)")
    }
    
    private func delete(userName: String, service: String) -> Bool {
        guard let value = self.get(userName: userName, service: service) else {
            print("Keychain cannot remove matching value for \(userName)'s service \(service). It does not exist")
            return true
        }
        
        guard let data:Data = value.data(using: String.Encoding.utf8) else {
            print("Error: cannot encode string in SLKeychainHanlder delete item for username method")
            return false;
        }
        
        let keychainQuery:[String:AnyObject] = [
            kSecClassValue: kSecClassGenericPasswordValue as AnyObject,
            kSecAttrServiceValue: service as AnyObject,
            kSecAttrAccountValue: userName as AnyObject,
            kSecValueDataValue: data as NSData
        ]
        
        return SecItemDelete(keychainQuery as CFDictionary) == errSecSuccess
    }
    
    private func get(userName: String, service: String) -> String? {
        let keychainQuery:[String:AnyObject] = [
            kSecClassValue: kSecClassGenericPasswordValue as AnyObject,
            kSecAttrServiceValue: service as AnyObject,
            kSecAttrAccountValue: userName as AnyObject,
            kSecReturnDataValue: kCFBooleanTrue,
            kSecMatchLimitValue: kSecMatchLimitOneValue as AnyObject
        ]

        
        var result: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
        if status == errSecSuccess {
            if let data = result as? NSData, let value = NSString(
                data: data as Data,
                encoding:String.Encoding.utf8.rawValue
                ) as? String
            {
                return value
            }
        }
        
        print("Error: could not retreive value from keychain")
        return nil
    }
    
    private func stringForHandlerCase(handlerCase: SLKeychainHandlerCase) -> String {
        let handlerCaseString: String
        switch handlerCase {
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
