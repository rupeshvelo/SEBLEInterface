//
//  SLLock+CoreDataProperties.h
//  Ellipse
//
//  Created by Andre Green on 8/19/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLLock.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLLock (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *givenName;
@property (nullable, nonatomic, retain) NSNumber *hasConnected;
@property (nullable, nonatomic, retain) NSNumber *isCurrentLock;
@property (nullable, nonatomic, retain) NSNumber *isDetected;
@property (nullable, nonatomic, retain) NSNumber *isInBootMode;
@property (nullable, nonatomic, retain) NSDate *lastConnected;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *macAddress;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *uuid;
@property (nullable, nonatomic, retain) NSSet<SLDbLockSharedContact *> *sharedContacts;
@property (nullable, nonatomic, retain) SLUser *user;

@end

@interface SLLock (CoreDataGeneratedAccessors)

- (void)addSharedContactsObject:(SLDbLockSharedContact *)value;
- (void)removeSharedContactsObject:(SLDbLockSharedContact *)value;
- (void)addSharedContacts:(NSSet<SLDbLockSharedContact *> *)values;
- (void)removeSharedContacts:(NSSet<SLDbLockSharedContact *> *)values;

@end

NS_ASSUME_NONNULL_END
