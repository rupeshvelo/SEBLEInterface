//
//  SLLockManager.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLLock;

@interface SLLockManager : NSObject

+ (id)manager;

- (void)addLock:(SLLock *)lock;
- (void)removeLock:(SLLock *)lock;
- (NSArray *)orderedLocks;

// methods for testing
- (SLLock *)getTestLock;
- (void)createTestLocks;

@end
