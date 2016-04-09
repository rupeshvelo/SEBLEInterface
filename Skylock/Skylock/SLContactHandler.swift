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

struct SLContactHandler {
    
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
    
    func saveContactToUserDefaults(contact: CNContact, contactId: SLUserDefaultsEmergencyContactId) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(contact.identifier, forKey: contactId.rawValue)
        ud.synchronize()
    }
    
    func emergencyContactIdFromUserDefaults(contactId: SLUserDefaultsEmergencyContactId) -> String? {
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.objectForKey(contactId.rawValue) as? String
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
}
