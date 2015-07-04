//
//  SLLockManager.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockManager.h"
#import "SLLock.h"
#include <stdlib.h>
#import "SEBLEInterface/SEBLEInterfaceManager.h"
#import "SEBLEInterface/SEBLEPeripheral.h"
#import "SLNotifications.h"


@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) NSMutableDictionary *locksToAdd;
@property (nonatomic, strong) NSDictionary *services;

// testing
@property (nonatomic, strong) NSArray *testLocks;

@end

@implementation SLLockManager

- (id)init
{
    self = [super init];
    if (self) {
        _locks      = [NSMutableDictionary new];
        _locksToAdd = [NSMutableDictionary new];
        _bleManager = [SEBLEInterfaceMangager manager];
        _bleManager.delegate = self;

    }
    
    return self;
}

+ (id)manager
{
    static SLLockManager *lockManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockManger = [[self alloc] init];
    });
    
    return lockManger;
}

- (NSDictionary *)services
{
    if (!_services) {
        _services = @{@(SLLockManagerServicesLedService): @"9c7d1523-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLedOn): @"9c7d1525-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLedOff): @"9c7d1526-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLockService): @"9c7d1529-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLockState): @"9c7d152a-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLockShift): @"9c7d152b-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesLedState): @"9c7d1524-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesTxPwr): @"9c7d1528-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServicesTesting): @"9c7d152c-ba74-0bac-bb4b-539d6a70eadd"
                      };
    }
    
    return _services;
}

- (NSArray *)testLocks
{
    if (!_testLocks) {
        SLLock *lock1 = [[SLLock alloc] initWithName:@"One Love"
                                              lockId:@"bkdidlldie830387jdod9"
                                    batteryRemaining:@(46.7)
                                        wifiStrength:@(56.8)
                                        cellStrength:@(87.98)
                                            lastTime:@(354)
                                        distanceAway:@(12765)
                                            isLocked:@(NO)
                                           isCrashOn:@(NO)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(NO)];
        
        SLLock *lock2 = [[SLLock alloc] initWithName:@"Three Little Birds"
                                              lockId:@"opdkdopwp08djwwkddidh"
                                    batteryRemaining:@(99)
                                        wifiStrength:@(56)
                                        cellStrength:@(45.21)
                                            lastTime:@(65)
                                        distanceAway:@(100)
                                            isLocked:@(NO)
                                           isCrashOn:@(YES)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(YES)];
        
        SLLock *lock3 = [[SLLock alloc] initWithName:@"Buffalo Soldier"
                                              lockId:@"pdidmhjdghsjsyy27d6th"
                                    batteryRemaining:@(2.98)
                                        wifiStrength:@(45)
                                        cellStrength:@(46.4)
                                            lastTime:@(45)
                                        distanceAway:@(1256)
                                            isLocked:@(YES)
                                           isCrashOn:@(NO)
                                         isSharingOn:@(YES)
                                        isSecurityOn:@(NO)];
        
        SLLock *lock4 = [[SLLock alloc] initWithName:@"Stir It Up"
                                              lockId:@"eoeopwpwpeie993pw-0-2"
                                    batteryRemaining:@(63)
                                        wifiStrength:@(78)
                                        cellStrength:@(36)
                                            lastTime:@(853)
                                        distanceAway:@(7000)
                                            isLocked:@(NO)
                                           isCrashOn:@(YES)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(YES)];
        
        _testLocks = @[lock1, lock2, lock3, lock4];
    }
    
    return _testLocks;
}

- (BOOL)containsLock:(SLLock *)lock
{
    if ([self.locks objectForKey:lock.name]) {
        return YES;
    }
    
    return NO;
}

- (void)addLock:(SLLock *)lock
{
    if ([self containsLock:lock]) {
        NSLog(@"Duplicate lock: %@", lock.name);
    } else {
        if (self.locksToAdd[lock.name]) {
            [self.locksToAdd removeObjectForKey:lock.name];
        }
        
        self.locks[lock.name] = lock;
        [self.bleManager addPeripheralNamed:lock.name];
    }
}

- (void)removeLock:(SLLock *)lock
{
    if ([self containsLock:lock]) {
        [self.locks removeObjectForKey:lock.name];
    }
}

- (NSArray *)orderedLocksByName
{
    NSArray *locksByName = [self.locks.allValues sortedArrayUsingComparator:^NSComparisonResult(SLLock *l1, SLLock *l2) {
        return [l1.name compare:l2.name];
    }];
    
    return locksByName;
}

- (SLLock *)getTestLock
{
    int target = arc4random_uniform(3);
    return self.testLocks[target];
}

- (SLLock *)lockFromPeripheral:(SEBLEPeripheral *)blePeripheral
{
    return [SLLock lockWithName:blePeripheral.peripheral.name];
}

- (void)createTestLocks
{
    [self.testLocks enumerateObjectsUsingBlock:^(SLLock *lock, NSUInteger idx, BOOL *stop) {
        [self addLock:lock];
    }];
}

- (NSArray *)unaddedLocks
{
    NSMutableArray *unaddedKeys = [NSMutableArray arrayWithArray:self.locksToAdd.allKeys];
    [unaddedKeys sortUsingComparator:^NSComparisonResult(SLLock *lock1, SLLock *lock2) {
        return [lock1.name compare:lock2.name];
    }];
    
    NSMutableArray *locks = [NSMutableArray new];
    for(NSUInteger i=0; i < unaddedKeys.count; i++) {
        [locks addObject:self.locksToAdd[unaddedKeys[i]]];
    }
    
    return locks;
}

- (void)startScan
{
    [self.bleManager startScan];
}

- (void)toggleCrash:(BOOL)turnOn
{
    
}

#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger discoveredPeripheral:(SEBLEPeripheral *)peripheral
{
    SLLock *lock = [self lockFromPeripheral:peripheral];
    if (!self.locksToAdd[lock.name]) {
        self.locksToAdd[lock.name] = lock;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDiscoverdLock
                                                            object:nil];
    }
    
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager connectPeripheral:(SEBLEPeripheral *)peripheral
{
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager removePeripheral:(SEBLEPeripheral *)peripheral
{
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager didUpdateDeviceValues:(NSDictionary *)values
{
    
}

@end
