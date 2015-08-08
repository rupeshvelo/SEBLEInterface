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
    SLLockManagerServiceSecurity,
    SLLockManagerServiceHardware,
    SLLockManagerServiceConfiguration,
    SLLockManagerServiceTest,
    SLLockManagerServiceBoot,
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristic) {
    SLLockManagerCharacteristicLed = 0,
    SLLockManagerCharacteristicLock,
    SLLockManagerCharacteristicHardwareInfo,
    SLLockManagerCharacteristicReserved,
    SLLockManagerCharacteristicTXPowerControl
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristicState) {
    SLLockManagerCharacteristicStateNone,
    SLLockManagerCharacteristicStateLedOn,
    SLLockManagerCharacteristicStateLedOff,
    SLLockManagerCharacteristicStateOpenLock,
    SLLockManagerCharacteristicStateCloseLock
};

typedef enum {
    SLLockManagerValueOff       = 0x00,
    SLLockManagerValueLedOn     = 0x4F,
    SLLockManagerValueLockOpen  = 0x01,
} SLLockMangerValue;

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) NSMutableDictionary *locksToAdd;
@property (nonatomic, strong) SLDatabaseManager *databaseManger;
@property (nonatomic, assign) BOOL bleIsPoweredOn;
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
        _bleIsPoweredOn = NO;
    }
    
    return self;
}

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLLockManager *lockManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockManger = [[self alloc] init];
    });
    
    return lockManger;
}

- (NSArray *)testLocks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self.locks objectForKey:lock.name]) {
        return YES;
    }
    
    return NO;
}

- (void)addLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [locks enumerateObjectsUsingBlock:^(SLLock *lock, NSUInteger idx, BOOL *stop) {
//        if (![self containsLock:lock]) {
//            self.locks[lock.name] = lock;
//        }
        
        [self addLock:lock];
    }];
}

- (void)removeLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self containsLock:lock]) {
        [self.locks removeObjectForKey:lock.name];
    }
}

- (NSArray *)orderedLocksByName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *locksByName = [self.locks.allValues sortedArrayUsingComparator:^NSComparisonResult(SLLock *l1, SLLock *l2) {
        return [l1.name compare:l2.name];
    }];
    
    return locksByName;
}

- (SLLock *)lockFromPeripheral:(SEBLEPeripheral *)blePeripheral
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [SLLock lockWithName:blePeripheral.peripheral.name uuid:blePeripheral.CBUUIDAsString];
}

- (void)fetchLocks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self getLocksFromDatabase];
    
    // testing
//    if (self.locks.allKeys.count == 0) {
//        for (SLLock *lock in self.testLocks) {
//            [self saveLockToDatabase:lock];
//        }
//        
//        [self getLocksFromDatabase];
//    }
}

- (NSArray *)unaddedLocks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *unaddedKeys = [NSMutableArray arrayWithArray:self.locksToAdd.allKeys];
    [unaddedKeys sortUsingComparator:^NSComparisonResult(SLLock *lock1, SLLock *lock2) {
        return [lock1.name compare:lock2.name];
    }];
    
    __block NSMutableArray *locks = [NSMutableArray new];
    [unaddedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [locks addObject:self.locksToAdd[unaddedKeys[idx]]];
    }];
    
    return locks;
}

- (void)startScan
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.bleManager startScan];
}

- (void)stopScan
{
    [self.bleManager stopScan];
}

- (void)startBlueToothManager
{
    [self.bleManager powerOn];
}

- (void)setLockStateForLock:(SLLock *)lock
{
    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceHardware
                        characteristic:SLLockManagerCharacteristicLock
                                turnOn:lock.isLocked.boolValue];
}

- (void)toggleCrashForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceHardware
                        characteristic:SLLockManagerCharacteristicLed
                                turnOn:lock.isCrashOn.boolValue];
}

- (void)toggleSecurityForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
}

- (void)toggleSharingForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)writeToPeripheralForLockName:(NSString *)lockName
                             service:(SLLockManagerService)service
                      characteristic:(SLLockManagerCharacteristic)characteristic
                              turnOn:(BOOL)turnOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *serviceUUID = [self uuidForService:service];
    NSString *characteristicUUID = [self uuidForCharacteristic:characteristic];
    
    u_int8_t value = [self valueForCharacteristic:characteristic turnOn:turnOn];
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self.bleManager writeToPeripheralWithName:lockName
                                   serviceUUID:serviceUUID
                            characteristicUUID:characteristicUUID
                                          data:data];
}

- (uint8_t)valueForCharacteristic:(SLLockManagerCharacteristic)characteristic
                                     turnOn:(BOOL)turnOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    switch (characteristic) {
        case SLLockManagerCharacteristicLed:
            return turnOn ? SLLockManagerValueLedOn : SLLockManagerValueOff;
            break;
        case SLLockManagerCharacteristicLock:
            return turnOn ? SLLockManagerValueLockOpen : SLLockManagerValueOff;
            break;
        default:
            return SLLockManagerCharacteristicStateNone;
            break;
    }
}

- (void)saveLockToDatabase:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.databaseManger saveLockToDb:lock withCompletion:^(BOOL success) {
        NSLog(@"saving lock: %@ was a %@", lock.name, success ? @"succes":@"failure");
    }];
}

- (void)getLocksFromDatabase
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *locks = [self.databaseManger locksForCurrentUser];
    if (locks) {
        [self addLocksFromDb:locks];
    }
}

- (NSString *)uuidForCharacteristic:(SLLockManagerCharacteristic)characteristic
{
    NSString *characteristicString;
    
    switch (characteristic) {
        case SLLockManagerCharacteristicLed:
            characteristicString = @"5E41";
            break;
        case SLLockManagerCharacteristicLock:
            characteristicString = @"5E42";
            break;
        case SLLockManagerCharacteristicHardwareInfo:
            characteristicString = @"5E43";
            break;
        case SLLockManagerCharacteristicReserved:
            characteristicString = @"5E44";
            break;
        case SLLockManagerCharacteristicTXPowerControl:
            characteristicString = @"5E45";
            break;
        default:
            break;
    }
    
    return characteristicString ? [NSString stringWithFormat:@"%@%@%@",
                                   [self uuidStringForFirstPart:YES],
                                   characteristicString,
                                   [self uuidStringForFirstPart:NO]] : nil;
}

- (NSString *)uuidForService:(SLLockManagerService)service
{
    NSString *serviceString;
    
    switch (service) {
        case SLLockManagerServiceSecurity:
            serviceString = @"5E00";
            break;
        case SLLockManagerServiceHardware:
            serviceString = @"5E40";
            break;
        case SLLockManagerServiceConfiguration:
            serviceString = @"5E80";
            break;
        case SLLockManagerServiceTest:
            serviceString = @"5EC0";
            break;
        case SLLockManagerServiceBoot:
            serviceString = @"5D00";
            break;
        default:
            break;
    }
    
    return serviceString ? [NSString stringWithFormat:@"%@%@%@",
                            [self uuidStringForFirstPart:YES],
                            serviceString,
                            [self uuidStringForFirstPart:NO]] : nil;
}

- (NSString *)uuidStringForFirstPart:(BOOL)isFirstPart
{
    return isFirstPart ? @"D399" : @"-FA57-11E4-AE59-0002A5D5C51B";
}

#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger discoveredPeripheral:(SEBLEPeripheral *)peripheral
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLock *lock = [self lockFromPeripheral:peripheral];
    if (!self.locksToAdd[lock.name]) {
        self.locksToAdd[lock.name] = lock;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDiscoverdLock
                                                            object:lock];
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager connectedPeripheral:(SEBLEPeripheral *)peripheral
{
    SLLock *lock = [self lockFromPeripheral:peripheral];
    [self addLock:lock];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager removePeripheral:(SEBLEPeripheral *)peripheral
{
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager didUpdateDeviceValues:(NSDictionary *)values
{
    
}

- (void)bleInterfaceManagerIsPoweredOn:(SEBLEInterfaceMangager *)interfaceManager
{
    self.bleIsPoweredOn = YES;
}

@end
