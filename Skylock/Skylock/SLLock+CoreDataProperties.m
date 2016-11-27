//
//  SLLock+CoreDataProperties.m
//  Ellipse
//
//  Created by Andre Green on 11/27/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLLock+CoreDataProperties.h"

@implementation SLLock (CoreDataProperties)

+ (NSFetchRequest<SLLock *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SLLock"];
}

@dynamic givenName;
@dynamic hasConnected;
@dynamic isConnecting;
@dynamic isCurrentLock;
@dynamic isInBootMode;
@dynamic isLocked;
@dynamic isSetForDeletion;
@dynamic lastConnected;
@dynamic latitude;
@dynamic lockPosition;
@dynamic longitude;
@dynamic macAddress;
@dynamic name;
@dynamic uuid;
@dynamic lastLocked;
@dynamic sharedContacts;
@dynamic user;

@end
