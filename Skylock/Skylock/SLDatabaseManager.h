//
//  SLDatabaseManager.h
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLLock;
@class SLDbUser;

@class NSManagedObjectContext;

@interface SLDatabaseManager : NSObject

@property (strong) SLDbUser *currentUser;


+(id)manager;

- (void)setContext:(NSManagedObjectContext *)context;

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;
- (NSArray *)getAllLocksFromDb;
- (NSArray *)locksForCurrentUser;
- (void)deleteLock:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;
- (void)saveUser:(SLDbUser *)user withCompletion:(void(^)(BOOL success))completion;
- (void)saveFacebookUserWithDictionary:(NSDictionary *)dictionary;
- (void)setCurrentUser;

@end
