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
#import "SLDatabaseManager.h"
#import "SLDbLock+Methods.m"

typedef NS_ENUM(NSUInteger, SLLockManagerService) {
    SLLockManagerServiceLedService = 0,
    SLLockManagerServiceLedState,
    SLLockManagerServiceLedOn,
    SLLockManagerServiceLedOff,
    SLLockManagerServiceLockService,
    SLLockManagerServiceLockShift,
    SLLockManagerServiceLockState,
    SLLockManagerServiceTxPwr,
    SLLockManagerServiceTesting
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristic) {
    SLLockManagerCharacteristicLed = 100,
    SLLockManagerCharacteristicLock
};

typedef enum {
    SLLockManagerValueNone      = 0xFF,
    SLLockManagerValueLedOn     = 0x4F,
    SLLockManagerValueLedOff    = 0x00,
    SLLockManagerValueLock      = 0x01,
    SLLockManagerValueUnlock    = 0x00
} SLLockMangerValue;

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) NSMutableDictionary *locksToAdd;
@property (nonatomic, strong) NSDictionary *services;
@property (nonatomic, strong) SLDatabaseManager *databaseManger;

// testing
@property (nonatomic, strong) NSArray *testLocks;

@end

@implementation SLLockManager

- (id)init
{
    self = [super init];
    if (self) {
        _locks          = [NSMutableDictionary new];
        _locksToAdd     = [NSMutableDictionary new];
        _bleManager     = [SEBLEInterfaceMangager manager];
        _bleManager.delegate = self;
        _databaseManger = [SLDatabaseManager manager];

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
        _services = @{@(SLLockManagerServiceLedService): @"9c7d1523-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceLedOn): @"9c7d1525-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceLedOff): @"9c7d1526-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceLockState): @"9c7d1529-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerCharacteristicLock): @"9c7d152a-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceLockShift): @"9c7d152b-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerCharacteristicLed): @"9c7d1524-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceTxPwr): @"9c7d1528-ba74-0bac-bb4b-539d6a70eadd",
                      @(SLLockManagerServiceTesting): @"9c7d152c-ba74-0bac-bb4b-539d6a70eadd"
                      };
    }
    
    return _services;
}

- (NSArray *)testLocks
{
    if (!_testLocks) {
        SLLock *lock1 = [[SLLock alloc] initWithName:@"One Love"
                                                uuid:@"bkdi-dlldi-e830387-jdod9"
                                    batteryRemaining:@(46.7)
                                        wifiStrength:@(56.8)
                                        cellStrength:@(87.98)
                                            lastTime:@(354)
                                        distanceAway:@(12765)
                                            isLocked:@(NO)
                                           isCrashOn:@(NO)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(NO)
                                            latitude:@(37.761663)
                                           longitude:@(-122.422855)];
        
        SLLock *lock2 = [[SLLock alloc] initWithName:@"Three Little Birds"
                                                uuid:@"opdkdopwp08djwwkddidh"
                                    batteryRemaining:@(99)
                                        wifiStrength:@(56)
                                        cellStrength:@(45.21)
                                            lastTime:@(65)
                                        distanceAway:@(100)
                                            isLocked:@(NO)
                                           isCrashOn:@(YES)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(YES)
                                            latitude:@(37.761663)
                                           longitude:@(-122.422855)];
        
        SLLock *lock3 = [[SLLock alloc] initWithName:@"Buffalo Soldier"
                                                uuid:@"pdidmhjdghsjsyy27d6th"
                                    batteryRemaining:@(2.98)
                                        wifiStrength:@(45)
                                        cellStrength:@(46.4)
                                            lastTime:@(45)
                                        distanceAway:@(1256)
                                            isLocked:@(YES)
                                           isCrashOn:@(NO)
                                         isSharingOn:@(YES)
                                        isSecurityOn:@(NO)
                                            latitude:@(37.761663)
                                           longitude:@(-122.422855)];
    
        
        SLLock *lock4 = [[SLLock alloc] initWithName:@"Stir It Up"
                                                uuid:@"eoeopwpwpeie993pw-0-2"
                                    batteryRemaining:@(63)
                                        wifiStrength:@(78)
                                        cellStrength:@(36)
                                            lastTime:@(853)
                                        distanceAway:@(7000)
                                            isLocked:@(NO)
                                           isCrashOn:@(YES)
                                         isSharingOn:@(NO)
                                        isSecurityOn:@(YES)
                                            latitude:@(37.761663)
                                           longitude:@(-122.422855)];
        
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
            self.locks[lock.name] = lock;
            [self.bleManager addPeripheralNamed:lock.name];
            [self saveLockToDatabase:lock];
        }
    }
}

- (void)addLocksFromDb:(NSArray *)locks
{
    for (SLLock *lock in locks) {
        if (![self containsLock:lock]) {
            self.locks[lock.name] = lock;
        }
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

- (SLLock *)lockFromPeripheral:(SEBLEPeripheral *)blePeripheral
{
    return [SLLock lockWithName:blePeripheral.peripheral.name uuid:blePeripheral.CBUUIDAsString];
}

- (void)fetchLocks
{
    [self getLocksFromDatabase];
    
    // testing
    if (self.locks.allKeys.count == 0) {
        [self addLocksFromDb:self.testLocks];
    }
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

- (void)toggleCrashForLock:(SLLock *)lock
{
    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceLedService
                        characteristic:SLLockManagerCharacteristicLed
                                turnOn:lock.isCrashOn.boolValue];
}

- (void)toggleSecurityForLock:(SLLock *)lock
{
    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceLockState
                        characteristic:SLLockManagerCharacteristicLock
                                turnOn:lock.isSecurityOn.boolValue];
}

- (void)toggleSharingForLock:(SLLock *)lock
{
    
}

- (void)writeToPeripheralForLockName:(NSString *)lockName
                             service:(SLLockManagerService)service
                      characteristic:(SLLockManagerCharacteristic)characteristic
                              turnOn:(BOOL)turnOn
{
    NSString *serviceUUID = self.services[@(service)];
    NSString *characteristicUUID = self.services[@(characteristic)];
    
    u_int8_t value = [self valueForCharacteristic:characteristic turnOn:turnOn];
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self.bleManager writeToPeripheralWithName:lockName
                                   serviceUUID:serviceUUID.uppercaseString
                            characteristicUUID:characteristicUUID.uppercaseString
                                          data:data];
}

- (SLLockMangerValue)valueForCharacteristic:(SLLockManagerCharacteristic)characteristic
                                     turnOn:(BOOL)turnOn
{
    switch (characteristic) {
        case SLLockManagerCharacteristicLed:
            return turnOn ? SLLockManagerValueLedOn : SLLockManagerValueLedOff;
            break;
        case SLLockManagerCharacteristicLock:
            return turnOn ? SLLockManagerValueLock : SLLockManagerValueUnlock;
            break;
        default:
            return SLLockManagerValueNone;
            break;
    }
    
}

- (void)saveLockToDatabase:(SLLock *)lock
{
    [self.databaseManger saveLockToDb:lock withCompletion:^(BOOL success) {
        NSLog(@"saving lock: %@ was a %@", lock.name, success ? @"succes":@"failure");
    }];
}

- (void)getLocksFromDatabase
{
    NSArray *locks = [self.databaseManger getAllLocksFromDb];
    [self addLocksFromDb:locks];
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
