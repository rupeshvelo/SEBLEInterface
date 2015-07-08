//
//  SLDatabaseManager.h
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLLock;
@class NSManagedObjectContext;

@interface SLDatabaseManager : NSObject

+(id)manager;

- (void)setContext:(NSManagedObjectContext *)context;

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;
- (NSArray *)getAllLocksFromDb;
- (void)deleteLock:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;

@end
