//
//  SLLock+CoreDataProperties.h
//  Ellipse
//
//  Created by Andre Green on 11/27/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLLock+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SLLock (CoreDataProperties)

+ (NSFetchRequest<SLLock *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *givenName;
@property (nullable, nonatomic, copy) NSNumber *hasConnected;
@property (nullable, nonatomic, copy) NSNumber *isConnecting;
@property (nullable, nonatomic, copy) NSNumber *isCurrentLock;
@property (nullable, nonatomic, copy) NSNumber *isInBootMode;
@property (nullable, nonatomic, copy) NSNumber *isLocked;
@property (nullable, nonatomic, copy) NSNumber *isSetForDeletion;
@property (nullable, nonatomic, copy) NSDate *lastConnected;
@property (nullable, nonatomic, copy) NSNumber *latitude;
@property (nullable, nonatomic, copy) NSNumber *lockPosition;
@property (nullable, nonatomic, copy) NSNumber *longitude;
@property (nullable, nonatomic, copy) NSString *macAddress;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSDate *lastLocked;
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
