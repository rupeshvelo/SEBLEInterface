//
//  SLKeychainHandler.swift
//  Skylock
//
//  Created by Andre Green on 1/2/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

@objc public enum SLKeychainHandlerCase: Int {
    case PublicKey
    case SignedMessage
    case ChallengeKey
}

@objc public class SLKeychainHandler: NSObject {
    private let keychainWrapper = KeychainWrapper()
    private let prefix = "skylock."
    
    @objc public func getItem(handlerCase: SLKeychainHandlerCase, lockName: String) -> String? {
        if let data = self.keychainWrapper.myObjectForKey(self.key(lockName)) as? Dictionary <String, String> {
            let value = data[self.stringForHandlerCase(handlerCase)]
            if (value == "") {
                return nil
            }
            
            return value
        }
        
        return nil
    }
    
    @objc public func setItem(input: String, handlerCase: SLKeychainHandlerCase, lockName: String) {
        let key = self.key(lockName)
        if var data = self.keychainWrapper.myObjectForKey(key) as? Dictionary <String, String> {
            data[self.stringForHandlerCase(handlerCase)] = input
            self.keychainWrapper.mySetObject(data, forKey: key)
        }
        
        let data = self.createEmptyKeyChainData(input, handlerCase: handlerCase)
        self.keychainWrapper.mySetObject(data, forKey: key)
        self.keychainWrapper.writeToKeychain()
    }
    
    private func createEmptyKeyChainData(input: String, handlerCase: SLKeychainHandlerCase) -> Dictionary <String, String> {
        let data: [String: String]
        switch handlerCase {
        case .ChallengeKey:
            data = [
                self.stringForHandlerCase(SLKeychainHandlerCase.ChallengeKey): input,
                self.stringForHandlerCase(SLKeychainHandlerCase.SignedMessage): "",
                self.stringForHandlerCase(SLKeychainHandlerCase.PublicKey): ""
            ]
        case .PublicKey:
            data = [
                self.stringForHandlerCase(SLKeychainHandlerCase.ChallengeKey): "",
                self.stringForHandlerCase(SLKeychainHandlerCase.SignedMessage): "",
                self.stringForHandlerCase(SLKeychainHandlerCase.PublicKey): input
            ]
        case .SignedMessage:
            data = [
                self.stringForHandlerCase(SLKeychainHandlerCase.ChallengeKey): "",
                self.stringForHandlerCase(SLKeychainHandlerCase.SignedMessage): input,
                self.stringForHandlerCase(SLKeychainHandlerCase.PublicKey): ""
            ]
        }
        
        return data
    }
    
    private func key(lockName: String) -> String {
        return self.prefix + lockName
    }
    
    private func stringForHandlerCase(handlerCase: SLKeychainHandlerCase) -> String {
        let handlerCaseString: String
        
        switch handlerCase {
        case .ChallengeKey:
            handlerCaseString = "skylock.challenge.key"
        case .SignedMessage:
            handlerCaseString = "skylock.signed.message"
        case .PublicKey:
            handlerCaseString = "skylock.public.key"
        }
        
        return handlerCaseString
    }
}
