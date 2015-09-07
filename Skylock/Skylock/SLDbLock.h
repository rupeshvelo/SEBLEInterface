//
//  SLDbLock.h
//  Skylock
//
//  Created by Andre Green on 9/6/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLDbLockSharedContact, SLDbUser;

@interface SLDbLock : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * isCurrentLock;
@property (nonatomic, retain) SLDbUser *user;
@property (nonatomic, retain) NSSet *sharedContacts;
@end

@interface SLDbLock (CoreDataGeneratedAccessors)

- (void)addSharedContactsObject:(SLDbLockSharedContact *)value;
- (void)removeSharedContactsObject:(SLDbLockSharedContact *)value;
- (void)addSharedContacts:(NSSet *)values;
- (void)removeSharedContacts:(NSSet *)values;

@end
