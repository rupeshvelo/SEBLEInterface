//
//  SLContactHandler.swift
//  Skylock
//
//  Created by Andre Green on 4/7/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation
import Contacts


enum SLUserDefaultsEmergencyContactId: String {
    case One = "SLUserDefaultsEmergencyContactIdOne"
    case Two = "SLUserDefaultsEmergencyContactIdTwo"
    case Three = "SLUserDefaultsEmergencyContactIdThree"
}

@objc class SLContactHandler:NSObject {
    
    private enum PredicateType {
        case Ids
        case Name
    }
    
    private let keysToFetch: [String] = [
        CNContactGivenNameKey,
        CNContactFamilyNameKey,
        CNContactImageDataKey,
        CNContactEmailAddressesKey,
        CNContactPhoneNumbersKey
    ]
    
    func getContactsWithIds(contactIds: [String]) throws -> [CNContact] {
        return try self.getContacts(PredicateType.Ids, predicateArgument: contactIds)
    }
    
    func getContactsWithName(name: String) throws -> [CNContact] {
        return try self.getContacts(PredicateType.Name, predicateArgument: name)
    }
    
    func saveContactToUserDefaults(
        contact: CNContact,
        contactId: SLUserDefaultsEmergencyContactId,
        shouldSaveToServer: Bool
        )
    {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(contact.identifier, forKey: contactId.rawValue)
        ud.synchronize()
        
        if shouldSaveToServer {
            self.saveContactToServer(
                contact,
                index: self.indexFromUserDefaultsContactId(contactId)
            )
        }
    }
    
    func emergencyContactIdFromUserDefaults(contactId: SLUserDefaultsEmergencyContactId) -> String? {
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.objectForKey(contactId.rawValue) as? String
    }
    
    @objc func emergencyContactsCommaSeperatedFirstNames() -> String {
        var names = ""
        let udContactIds: [SLUserDefaultsEmergencyContactId] = [.One, .Two, .Three]
        for (index, udContactId) in udContactIds.enumerate() {
            if let contactId = self.emergencyContactIdFromUserDefaults(udContactId) {
                do {
                    let contacts = try self.getContactsWithIds([contactId])
                    if let contact = contacts.first {
                        names += contact.givenName + (index == udContactIds.count - 1 ? "" : ", ")
                    }
                } catch {
                    print("Error: failed to get contact with ID: \(contactId)")
                }
            }
        }
        
        return names
    }
    
    func phoneNumberForUserDefualtContactId(contactId: String) -> String? {
        let contacts: [CNContact]
        do {
            contacts = try self.getContactsWithIds([contactId])
        } catch {
            print("Error: could not get CNContact with Id: \(contactId)")
            return nil
        }
        
        
        if let contact = contacts.first {
            return self.phoneNumberForContact(contact)
        }
        
        return nil
    }
    
    func phoneNumberForContact(contact: CNContact) -> String? {
        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
            if let phoneNumber = contact.phoneNumbers.first,
                let number = phoneNumber.value as? CNPhoneNumber
            {
                return number.stringValue
            }
        }
        
        return nil
    }
    
    func fullNameForContact(contact: CNContact) -> String {
        var fullName = ""
        if contact.isKeyAvailable(CNContactGivenNameKey) {
            fullName += contact.givenName
        }
        
        if contact.isKeyAvailable(CNContactFamilyNameKey) {
            if fullName != "" {
                fullName += " "
            }
            
            fullName += contact.familyName
        }
        
        return fullName
    }
    
    private func getContacts(predicateType: PredicateType, predicateArgument: AnyObject) throws -> [CNContact]  {
        let store = CNContactStore()
        let predicate:NSPredicate
        
        switch predicateType {
        case .Ids:
            predicate = CNContact.predicateForContactsWithIdentifiers(predicateArgument as! [String])
        case .Name:
            predicate = CNContact.predicateForContactsMatchingName(predicateArgument as! String)
        }

        let contacts = try store.unifiedContactsMatchingPredicate(
            predicate,
            keysToFetch: self.keysToFetch
        )
        
        print("There were \(contacts.count) contacts fetched.")
        return contacts
    }
    
    private func saveContactToServer(contact: CNContact, index: Int) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), {
            let dataBaseManager = SLDatabaseManager.sharedManager()
            let ud = NSUserDefaults.standardUserDefaults()
            
            guard let user = dataBaseManager.currentUser else {
                print("Error could not retrieve current user to post contact to server with Id: \(contact.identifier)")
                return
            }
            
            guard let phoneNumber = self.phoneNumberForContact(contact) else {
                print("Error: failed to retrieve contact phone with Id: \(contact.identifier) to server")
                return
            }
            
            guard let token = ud.valueForKey(SLUserDefaultsUserToken) as? String else {
                print("Error: no user token found when trying to save contact \(contact.identifier) to server")
                return
            }
            
            
            let body = [
                "emergency_contact": phoneNumber,
                "emergency_contact_name": self.fullNameForContact(contact)
            ]
            
            let subRoutes = [
                user.userId!,
                "mobiles",
                String(index)
            ]
            
            let restManager = SLRestManager.sharedManager()
            let authValue: String = restManager.basicAuthorizationHeaderValueUsername(token, password: "")
            let additionalHeaders = ["Authorization": authValue]
            
            restManager.postObject(
                body, serverKey: SLRestManagerServerKey.Main,
                pathKey: SLRestManagerPathKey.Users,
                subRoutes: subRoutes,
                additionalHeaders: additionalHeaders)
            { (_: [NSObject : AnyObject]!) in
                print("Got payload from saving contact with Id: \(contact.identifier)")
            }
        })
    }
    
    private func indexFromUserDefaultsContactId(contactId: SLUserDefaultsEmergencyContactId) -> Int {
        let index: Int
        switch contactId {
        case .One:
            index = 1
        case .Two:
            index = 2
        case .Three:
            index = 3
        }
        
        return index
    }
}
