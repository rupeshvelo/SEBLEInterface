//
//  SLLockManager.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEBLEInterface/SEBLEInterfaceManager.h"

@class SLLock;



@interface SLLockManager : NSObject <SEBLEInterfaceManagerDelegate>

+ (id)manager;

- (void)addLock:(SLLock *)lock;
- (void)removeLock:(SLLock *)lock;
- (NSArray *)orderedLocksByName;
- (void)startScan;
- (NSArray *)unaddedLocks;
- (void)toggleCrashForLock:(SLLock *)lock;
- (void)toggleSecurityForLock:(SLLock *)lock;
- (void)toggleSharignForLock:(SLLock *)lock;
// methods for testing
- (SLLock *)getTestLock;
- (void)createTestLocks;

@end
