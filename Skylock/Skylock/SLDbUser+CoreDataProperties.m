//
//  SLDbUser+CoreDataProperties.m
//  Skylock
//
//  Created by Andre Green on 1/19/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLDbUser+CoreDataProperties.h"

@implementation SLDbUser (CoreDataProperties)

@dynamic firstName;
@dynamic isCurrentUser;
@dynamic lastName;
@dynamic userId;
@dynamic userType;
@dynamic googlePushId;
@dynamic locks;

@end
