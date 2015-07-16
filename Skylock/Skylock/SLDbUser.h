//
//  SLDbUser.h
//  Skylock
//
//  Created by Andre Green on 7/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLDbLock;

@interface SLDbUser : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * facebookLink;
@property (nonatomic, retain) NSNumber * isCurrentUser;
@property (nonatomic, retain) NSSet *locks;
@end

@interface SLDbUser (CoreDataGeneratedAccessors)

- (void)addLocksObject:(SLDbLock *)value;
- (void)removeLocksObject:(SLDbLock *)value;
- (void)addLocks:(NSSet *)values;
- (void)removeLocks:(NSSet *)values;

@end
