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

typedef NS_ENUM(NSUInteger, SLLockManagerServices) {
    SLLockManagerServicesLedService,
    SLLockManagerServicesLedOn,
    SLLockManagerServicesLedOff,
    SLLockManagerServicesLockService,
    SLLockManagerServicesLockState,
    SLLockManagerServicesLockShift,
    SLLockManagerServicesLedState,
    SLLockManagerServicesTxPwr,
    SLLockManagerServicesTesting
};

@interface SLLockManager : NSObject <SEBLEInterfaceManagerDelegate>

+ (id)manager;

- (void)addLock:(SLLock *)lock;
- (void)removeLock:(SLLock *)lock;
- (NSArray *)orderedLocksByName;
- (void)startScan;
- (NSArray *)unaddedLocks;
- (void)toggleCrash:(BOOL)turnOn;
// methods for testing
- (SLLock *)getTestLock;
- (void)createTestLocks;

@end
