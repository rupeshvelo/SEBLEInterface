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

typedef NS_ENUM(NSUInteger, SLLockManagerTouchPadButton) {
    SLLockManagerTouchPadButtonTop,
    SLLockManagerTouchPadButtonRight,
    SLLockManagerTouchPadButtonBottom,
    SLLockManagerTouchPadButtonLeft
};

@property (nonatomic, assign) BOOL hasBleControl;

+ (id)sharedManager;

- (void)addLock:(SLLock *)lock;
- (void)permenantlyRemoveLock:(SLLock *)lock;
- (NSArray *)orderedLocksByName;
- (void)startScan;
- (void)stopScan;
- (BOOL)isScanning;
- (BOOL)isBlePoweredOn;
- (void)setCurrentLock:(SLLock *)lock;
- (SLLock *)getCurrentLock;
- (void)setLockStateForLock:(SLLock *)lock;
- (void)toggleCrashForLock:(SLLock *)lock;
- (void)toggleSecurityForLock:(SLLock *)lock;
- (void)toggleSharingForLock:(SLLock *)lock;
- (void)startBlueToothManager;
- (void)removeUnconnectedLocks;
- (void)updateLock:(SLLock *)lock withValues:(NSDictionary *)values;
- (void)startGettingHardwareData;
- (void)shouldEnterActiveSearchMode:(BOOL)shouldSearch;
- (NSDictionary *)addedAndRemovedLocksFromPreviousLocks:(NSArray *)previousLocks;
- (BOOL)hasLocksForCurrentUser;
- (void)deselectAllLocks;
- (void)updateFirmware;
- (void)writeTouchPadButtonPushes:(UInt8 *)pushes size:(int)size lock:(SLLock *)lock;
- (void)readButtonLockSequenceForLock:(SLLock *)lock;
- (void)deleteLockFromCurrentUserAccountWithMacAddress:(NSString *)macAddress;
- (void)factoryResetCurrentLock;
- (void)checkLockOpenOrClosed;
- (void)flashLEDs;
- (void)flashLEDsForLock:(SLLock *)lock;
- (NSArray *)locksDiscoveredInSearch;
- (void)clearAvaliableLocks;
- (void)connectToLockWithName:(NSString *)lockName;
- (void)changeCurrentLockGivenNameToName:(NSString *)newName;
- (NSArray *)unconnectedLocksForCurrentUser;
- (void)shallowConnectLock:(SLLock *)lock;
- (void)disconnectFromLockWithAddress:(NSString *)macAddress;

// temporary methods for testing
- (void)readFirmwareDataForLockAddress:(NSString *)macAddress;
- (void)checkCommandStatusForLockWithMacAddress:(NSString *)macAddress;

/**
 * returns a dictionary with keys "factory" and "nonFactory"
 */
- (NSDictionary *)factoryAndNonFactoryNameForName:(NSString *)name;

@end
