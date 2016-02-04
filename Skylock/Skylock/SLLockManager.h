//
//  SLLockManager.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEBLEInterface/SEBLEInterfaceManager.h"
#import "SLLockValue.h"
#import "SLLock.h"

@interface SLLockManager : NSObject <
SEBLEInterfaceManagerDelegate,
SLLockValueDelegate
>



@property (nonatomic, assign) BOOL hasBleControl;

+ (id)sharedManager;

- (void)addLock:(SLLock *)lock;
- (void)removeLock:(SLLock *)lock;
- (NSArray *)orderedLocksByName;
- (void)startScan;
- (void)stopScan;
- (NSArray *)unaddedLocks;
- (void)setCurrentLock:(SLLock *)lock;
- (SLLock *)getCurrentLock;
- (SLLock *)newLockWithName:(NSString *)name andUUID:(NSString *)uuid;
- (void)setLockStateForLock:(SLLock *)lock;
- (void)toggleCrashForLock:(SLLock *)lock;
- (void)toggleSecurityForLock:(SLLock *)lock;
- (void)toggleSharingForLock:(SLLock *)lock;
- (void)fetchLocks;
- (void)startBlueToothManager;
- (void)removeUnconnectedLocks;
- (void)updateLock:(SLLock *)lock withValues:(NSDictionary *)values;
- (void)startGettingHardwareData;
- (void)shouldEnterSearchMode:(BOOL)shouldSearch;
- (NSDictionary *)addedAndRemovedLocksFromPreviousLocks:(NSArray *)previousLocks;
- (BOOL)hasLocksForCurrentUser;
- (void)deselectAllLocks;
- (void)testing;

/**
 * returns a dictionary with keys "factory" and "nonFactory"
 */
- (NSDictionary *)factoryAndNonFactoryNameForName:(NSString *)name;

@end
