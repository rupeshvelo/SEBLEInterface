//
//  SLDbUser+CoreDataProperties.h
//  Skylock
//
//  Created by Andre Green on 1/19/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLDbUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLDbUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSNumber *isCurrentUser;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *userType;
@property (nullable, nonatomic, retain) NSString *googlePushId;
@property (nullable, nonatomic, retain) NSSet<SLDbLock *> *locks;

@end

@interface SLDbUser (CoreDataGeneratedAccessors)

- (void)addLocksObject:(SLDbLock *)value;
- (void)removeLocksObject:(SLDbLock *)value;
- (void)addLocks:(NSSet<SLDbLock *> *)values;
- (void)removeLocks:(NSSet<SLDbLock *> *)values;

@end

NS_ASSUME_NONNULL_END
