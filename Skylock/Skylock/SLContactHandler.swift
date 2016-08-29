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
    
    private let keysToFetch: [CNKeyDescriptor] = [
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
    
    func allContacts(completion: ([CNContact]) -> Void) throws {
        let fetchRequest = CNContactFetchRequest(keysToFetch: self.keysToFetch)
        var contacts:[CNContact] = [CNContact]()
        try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (contact, nil) in
            contacts.append(contact)
        }
        
        completion(contacts)
    }
    
    func dbEmegencyContacts() -> [SLEmergencyContact]? {
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        let contacts:[SLEmergencyContact]? = dbManager.emergencyContacts() as? [SLEmergencyContact]
        
        return contacts
    }
    
    func emergencyContactFromCNContact(contact: CNContact) -> SLEmergencyContact {
        print("contact: \(contact)")
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        if let dbContact = dbManager.getContactWithContactId(contact.identifier) {
            return dbContact
        }
        
        let newContact = dbManager.newEmergencyContact()
        newContact.firstName = contact.givenName
        newContact.lastName = contact.familyName
        newContact.contactId = contact.identifier
        newContact.isCurrentContact = false
        
        if !contact.phoneNumbers.isEmpty {
            if let phoneNumber = contact.phoneNumbers[0].value as? CNPhoneNumber {
                newContact.phoneNumber = phoneNumber.valueForKey("digits") as? String
                newContact.countyCode = phoneNumber.valueForKey("countryCode") as? String
            }
        }
        
        if !contact.emailAddresses.isEmpty {
            newContact.email = (contact.emailAddresses[0]).valueForKey("value") as? String
        }
        
        return newContact
    }
    
    func getImageForContact(identifier: String, completion:((imageData: NSData?) -> ())?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var contact:CNContact?
            do {
                contact = try CNContactStore().unifiedContactWithIdentifier(
                    identifier,
                    keysToFetch: [CNContactImageDataKey]
                )
            } catch {
                if let exit = completion {
                    exit(imageData: nil)
                }
            }
            
            if let exit = completion {
                exit(imageData: contact?.imageData)
            }
        })
    }
    
    func getActiveEmergencyContacts() -> [SLEmergencyContact]? {
        guard let contacts = self.dbEmegencyContacts() else {
            return nil
        }
        
        var activeContacts:[SLEmergencyContact] = [SLEmergencyContact]()
        for contact:SLEmergencyContact in contacts {
            if let isCurrent = contact.isCurrentContact where isCurrent.boolValue {
                activeContacts.append(contact)
            }
        }
        
        return activeContacts
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
    
    func authorizedToAccessContacts() -> Bool {
        let status:CNAuthorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
        return status == .Authorized
    }
    
    func requestAuthorization(completion: ((allowedAccess:Bool) -> Void)?) {
        CNContactStore().requestAccessForEntityType(.Contacts) { (didAllowAccess:Bool, error:NSError?) in
            guard let completionBlock = completion else {
                return
            }
            
            if error == nil {
                completionBlock(allowedAccess: didAllowAccess)
            } else {
                completionBlock(allowedAccess: false)
            }
        }
    }
    
    private func getContacts(predicateType: PredicateType, predicateArgument: AnyObject) throws -> [CNContact]  {
        let predicate:NSPredicate
        
        switch predicateType {
        case .Ids:
            predicate = CNContact.predicateForContactsWithIdentifiers(predicateArgument as! [String])
        case .Name:
            predicate = CNContact.predicateForContactsMatchingName(predicateArgument as! String)
        }

        let contacts = try CNContactStore().unifiedContactsMatchingPredicate(
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
            { (status: UInt, payload:[NSObject : AnyObject]!) in
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
