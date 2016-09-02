//
//  SLEmergencyContact+CoreDataProperties.h
//  Ellipse
//
//  Created by Andre Green on 9/2/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLEmergencyContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLEmergencyContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contactId;
@property (nullable, nonatomic, retain) NSString *countyCode;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isCurrentContact;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *phoneNumber;

@end

NS_ASSUME_NONNULL_END
