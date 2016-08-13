//
//  SLLock+CoreDataProperties.m
//  Ellipse
//
//  Created by Andre Green on 8/13/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLLock+CoreDataProperties.h"

@implementation SLLock (CoreDataProperties)

@dynamic givenName;
@dynamic isCurrentLock;
@dynamic lastConnected;
@dynamic latitude;
@dynamic longitude;
@dynamic macAddress;
@dynamic name;
@dynamic uuid;
@dynamic isInBootMode;
@dynamic sharedContacts;
@dynamic user;

@end
