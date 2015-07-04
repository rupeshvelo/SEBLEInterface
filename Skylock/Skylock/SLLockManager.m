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

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) NSMutableArray *lockOrder;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) NSMutableDictionary *locksToAdd;


// testing
@property (nonatomic, strong) NSArray *testLocks;

@end

@implementation SLLockManager

- (id)init
{
    self = [super init];
    if (self) {
        _locks      = [NSMutableDictionary new];
        _lockOrder  = [NSMutableArray new];
        _locksToAdd = [NSMutableDictionary new];
        _bleManager = [[SEBLEInterfaceMangager alloc] init];
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
    if ([self.locks objectForKey:lock.lockId]) {
        return YES;
    }
    
    return NO;
}

- (void)addLock:(SLLock *)lock
{
    if ([self containsLock:lock]) {
        NSLog(@"Duplicate lock with id: %@", lock.lockId);
    } else {
        self.locks[lock.lockId] = lock;
        [self.lockOrder addObject:lock.lockId];
    }
}

- (void)removeLock:(SLLock *)lock
{
    if ([self containsLock:lock]) {
        [self.locks removeObjectForKey:lock.lockId];
        [self.lockOrder removeObject:lock.lockId];
    }
}

- (NSArray *)orderedLocks
{
    NSMutableArray *locks = [NSMutableArray new];
    for (NSString *lockId in self.lockOrder) {
        [locks addObject:self.locks[lockId]];
    }
    
    return locks;
}

- (SLLock *)getTestLock
{
    int target = arc4random_uniform(3);
    return self.testLocks[target];
}

- (SLLock *)lockFromPeripheral:(SEBLEPeripheral *)blePeripheral
{
    SLLock *lock = [[SLLock alloc] initWithName:blePeripheral.peripheral.name
                                         lockId:blePeripheral.UUID
                               batteryRemaining:@(0)
                                   wifiStrength:@(0)
                                   cellStrength:@(0)
                                       lastTime:@(0)
                                   distanceAway:@(0)
                                       isLocked:@(YES)
                                      isCrashOn:@(YES)
                                    isSharingOn:@(YES)
                                   isSecurityOn:@(YES)];
    return lock;
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

#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger discoveredPeripheral:(SEBLEPeripheral *)peripheral
{
    SLLock *lock = [self lockFromPeripheral:peripheral];
    if (!self.locksToAdd[lock.lockId]) {
        self.locksToAdd[lock.lockId] = lock;
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
