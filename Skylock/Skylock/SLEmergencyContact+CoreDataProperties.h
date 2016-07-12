//
//  SLEmergencyContact+CoreDataProperties.h
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLEmergencyContact.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLEmergencyContact (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *contactId;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *phoneNumber;
@property (nullable, nonatomic, retain) NSNumber *isCurrentContact;

@end

NS_ASSUME_NONNULL_END
