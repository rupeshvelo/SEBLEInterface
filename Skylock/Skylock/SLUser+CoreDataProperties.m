//
//  SLUser+CoreDataProperties.m
//  Skylock
//
//  Created by Andre Green on 7/24/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLUser+CoreDataProperties.h"

@implementation SLUser (CoreDataProperties)

@dynamic email;
@dynamic firstName;
@dynamic googlePushId;
@dynamic isCurrentUser;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic userId;
@dynamic userType;
@dynamic areCrashAlertsOn;
@dynamic areTheftAlertsOn;
@dynamic isAutoLockOn;
@dynamic isAutoUnlockOn;
@dynamic locks;

@end
