//
//  SLEmergencyContact+CoreDataProperties.swift
//  Ellipse
//
//  Created by Andre Green on 11/27/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation
import CoreData


extension SLEmergencyContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SLEmergencyContact> {
        return NSFetchRequest<SLEmergencyContact>(entityName: "SLEmergencyContact");
    }

    @NSManaged public var contactId: String?
    @NSManaged public var countyCode: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var isCurrentContact: NSNumber?
    @NSManaged public var lastName: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var userId: String?

}
