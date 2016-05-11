//
//  SLUser+CoreDataProperties.h
//  Skylock
//
//  Created by Andre Green on 4/9/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SLUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface SLUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *googlePushId;
@property (nullable, nonatomic, retain) NSNumber *isCurrentUser;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *userType;
@property (nullable, nonatomic, retain) NSString *phoneNumber;
@property (nullable, nonatomic, retain) NSSet<SLLock *> *locks;

@end

@interface SLUser (CoreDataGeneratedAccessors)

- (void)addLocksObject:(SLLock *)value;
- (void)removeLocksObject:(SLLock *)value;
- (void)addLocks:(NSSet<SLLock *> *)values;
- (void)removeLocks:(NSSet<SLLock *> *)values;

@end

NS_ASSUME_NONNULL_END
