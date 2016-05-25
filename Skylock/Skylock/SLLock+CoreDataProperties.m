//
//  SLLock+CoreDataProperties.m
//  Skylock
//
//  Created by Andre Green on 5/22/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLLock+CoreDataProperties.h"

@implementation SLLock (CoreDataProperties)

@dynamic givenName;
@dynamic isCurrentLock;
@dynamic latitude;
@dynamic longitude;
@dynamic macAddress;
@dynamic name;
@dynamic uuid;
@dynamic lastConnected;
@dynamic sharedContacts;
@dynamic user;

@end
