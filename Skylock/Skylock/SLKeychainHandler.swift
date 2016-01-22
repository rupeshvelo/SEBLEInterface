//
//  SLKeychainHandler.swift
//  Skylock
//
//  Created by Andre Green on 1/2/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

@objc public enum SLKeychainLockHandlerCase: Int {
    case PublicKey
    case SignedMessage
    case ChallengeKey
}

@objc public enum SLKeychainUserHandlerCase: Int {
    case Password
}

@objc public class SLKeychainHandler: NSObject {
    private let keychainWrapper = KeychainWrapper()
    private let prefix = "skylock."
    
    @objc public func getLockItem(handlerCase: SLKeychainLockHandlerCase, lockName: String) -> String? {
        
        if let data = self.keychainWrapper.myObjectForKey(self.key(lockName)) as? Dictionary <String, String> {
            let value = data[self.stringForLockHandlerCase(handlerCase)]
            if (value == "") {
                return nil
            }
            
            return value
        }
        
        return nil
    }
    
    @objc public func getUserItem(handlerCase: SLKeychainUserHandlerCase, userId: String) -> String? {
       
        if let result = self.keychainWrapper.myObjectForKey(self.stringForUserHandlerCase(handlerCase)) as? String {
            return result
        }
        
        return nil
//        if let data = self.keychainWrapper.myObjectForKey(self.key(userId)) as? Dictionary <String, String> {
//            let value = data[self.stringForUserHandlerCase(handlerCase)]
//            if (value == "") {
//                return nil
//            }
//            
//            return value
//        }
//        
//        return nil
    }
    
    @objc public func setItemForLock(input: String, handlerCase: SLKeychainLockHandlerCase, lockName: String) {
        let key = self.key(lockName)
        if var data = self.keychainWrapper.myObjectForKey(key) as? Dictionary <String, String> {
            data[self.stringForLockHandlerCase(handlerCase)] = input
            self.keychainWrapper.mySetObject(data, forKey: key)
        }
        
        let data = self.createEmptyKeyChainLockData(input, handlerCase: handlerCase)
        self.keychainWrapper.mySetObject(data, forKey: key)
        self.keychainWrapper.writeToKeychain()
    }
    
    @objc public func setItemForUser(input: String, handlerCase: SLKeychainUserHandlerCase, userId: String) {
        self.keychainWrapper.setValue(input, forKey: self.stringForUserHandlerCase(.Password))
        self.keychainWrapper.writeToKeychain()
        
//        let key = self.key(userId)
//        if var data = self.keychainWrapper.myObjectForKey(key) as? Dictionary <String, String> {
//            data[self.stringForUserHandlerCase(handlerCase)] = input
//            self.keychainWrapper.mySetObject(data, forKey: key)
//        }
//        
//        let data = self.createEmptyKeyChainUserData(input, handlerCase: handlerCase)
//        self.keychainWrapper.mySetObject(data, forKey: key)
//        self.keychainWrapper.writeToKeychain()
    }
    
    private func createEmptyKeyChainLockData(input: String, handlerCase: SLKeychainLockHandlerCase) -> Dictionary <String, String> {
        let data: [String: String]
        switch handlerCase {
        case .ChallengeKey:
            data = [
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.ChallengeKey): input,
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.SignedMessage): "",
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.PublicKey): "",
            ]
        case .PublicKey:
            data = [
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.ChallengeKey): "",
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.SignedMessage): "",
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.PublicKey): input,
            ]
        case .SignedMessage:
            data = [
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.ChallengeKey): "",
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.SignedMessage): input,
                self.stringForLockHandlerCase(SLKeychainLockHandlerCase.PublicKey): "",
            ]
        }
        
        return data
    }
    
    private func createEmptyKeyChainUserData(input: String, handlerCase: SLKeychainUserHandlerCase) -> Dictionary <String, String> {
        let data: [String: String]
        switch handlerCase {
        case .Password:
            data = [
                self.stringForUserHandlerCase(.Password): input
            ]
        }
        
        return data
    }
    
    private func key(input: String) -> String {
        return self.prefix + input
    }
    
    private func stringForLockHandlerCase(handlerCase: SLKeychainLockHandlerCase) -> String {
        let handlerCaseString: String
        
        switch handlerCase {
        case .ChallengeKey:
            handlerCaseString = self.prefix + "challenge.key"
        case .SignedMessage:
            handlerCaseString = self.prefix + "signed.message"
        case .PublicKey:
            handlerCaseString = self.prefix + "public.key"
        }
        
        return handlerCaseString
    }
    
    private func stringForUserHandlerCase(handlerCase: SLKeychainUserHandlerCase) -> String {
        switch handlerCase {
        case .Password:
            return self.prefix + "password"
        }
    }
}
