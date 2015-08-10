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
    SLLockManagerCharacteristicTXPowerControl,
    SLLockManagerCharacteristicMagnet,
    SLLockManagerCharacteristicAccelerometer
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristicState) {
    SLLockManagerCharacteristicStateNone,
    SLLockManagerCharacteristicStateLedOn,
    SLLockManagerCharacteristicStateLedOff,
    SLLockManagerCharacteristicStateOpenLock,
    SLLockManagerCharacteristicStateCloseLock,
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
        _locks                  = [NSMutableDictionary new];
        _locksToAdd             = [NSMutableDictionary new];
        _bleManager             = [SEBLEInterfaceMangager manager];
        _bleManager.delegate    = self;
        _databaseManger         = [SLDatabaseManager manager];
        _bleIsPoweredOn         = NO;
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

- (BOOL)containsLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self.locks objectForKey:lock.name]) {
        return YES;
    }
    
    return NO;
}

- (NSSet *)characteristicsToRead
{
    NSArray *readChars = @[[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicLed],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicLock],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicMagnet],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer]
                           ];
    
    return [NSSet setWithArray:readChars];
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

- (void)removeUnconnectedLocks
{
    [self.bleManager removeNotConnectPeripherals];
    [self.locksToAdd removeAllObjects];
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

- (void)updateLock:(SLLock *)lock withValues:(NSDictionary *)values
{
    [lock updatePropertiesWithDictionary:values];
}

- (void)startScan
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.bleManager startScan];
}

- (void)stopScan
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.bleManager stopScan];
}

- (void)startBlueToothManager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.bleManager powerOn];
    [self.bleManager setCharacteristicsToReadFrom:self.characteristicsToRead];
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

- (void)readValueFromPeripheralForLockName:(NSString *)lockName
                                   service:(SLLockManagerService)service
                            characteristic:(SLLockManagerCharacteristic)characteristic
{
    
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
        case SLLockManagerCharacteristicMagnet:
            characteristicString = @"5EC3";
            break;
        case SLLockManagerCharacteristicAccelerometer:
            characteristicString = @"5EC4";
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

- (void)handleHardwareServiceForLockNameed:(NSString*)lockName data:(NSData *)data
{
    if (data.length != 4) {
        NSLog(@"Error: data is not the right number of bytes for System Hardware Information");
        return;
    }
    
    uint8_t *bytes = (uint8_t *)data.bytes;
    uint16_t batteryVoltage = 0;
    int8_t temp = 0;
    int8_t rssi = 0;
    
    for (int i = 0; i < data.length; i++) {
        if (i == 0 || i == 1) {
            batteryVoltage += bytes[i] << (i*CHAR_BIT);
        } else if (i == 2) {
            temp = bytes[i] << (i*CHAR_BIT);
        } else {
            rssi = bytes[i] << (i*CHAR_BIT);
        }
    }
    
    NSDictionary *values = @{@(SLLockPropertyBatteryVoltage):@(batteryVoltage),
                             @(SLLockPropertyTemperature):@(temp),
                             @(SLLockPropertyRSSIStrength):@(rssi)
                             };
    
    SLLock *lock = self.locks[lockName];
    [self updateLock:lock withValues:values];
}

- (void)handleMagnetForLockNamed:(NSString *)lockName data:(NSData *)data
{
    
}

- (void)handleAccelerometerForLockNamed:(NSString *)lockName data:(NSData *)data
{
    if (data.length != 12) {
        NSLog(@"Error: accelerometer data is not correct number of bytes");
        return;
    }
    
    int16_t xmav = 0;
    int16_t ymav = 0;
    int16_t zmav = 0;
    int16_t xvar = 0;
    int16_t yvar = 0;
    int16_t zvar = 0;
    
    uint8_t *bytes = (uint8_t *)data.bytes;
    
    for (int i=0; i < data.length; i++) {
        NSLog(@"data at index: %@ = %@", @(i), @(bytes[i]));
    }
    
    for (int i=0; i < data.length; i++) {
        if (i == 0 || i == 1) {
            xmav += bytes[i] << ((i%2)*CHAR_BIT);
        } else if (i == 2 || i == 3) {
            ymav += bytes[i] << ((i%2)*CHAR_BIT);
        } else if (i == 4 || i == 5) {
            zmav += bytes[i] << ((i%2)*CHAR_BIT);
        } else if (i == 6 || i == 7) {
            xvar += bytes[i] << ((i%2)*CHAR_BIT);
        } else if (i == 8 || i == 9) {
            yvar += bytes[i] << ((i%2)*CHAR_BIT);
        } else if (i == 10 || i == 11) {
            zvar += bytes[i] << ((i%2)*CHAR_BIT);
        }
    }
    
    NSDictionary *values = @{@(SLLockPropertyAccelerometerData):@{@"xmav":@(xmav),
                                                                  @"ymav":@(ymav),
                                                                  @"zmav":@(zmav),
                                                                  @"xvar":@(xvar),
                                                                  @"yvar":@(yvar),
                                                                  @"zvar":@(zvar)
                                                                  }
                             };
    
    NSLog(@"updating accelerometer values: %@", values);
    
    SLLock *lock = self.locks[lockName];
    [self updateLock:lock withValues:values];
}

#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger
       discoveredPeripheral:(SEBLEPeripheral *)peripheral
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLock *lock = [self lockFromPeripheral:peripheral];
    if (!self.locksToAdd[lock.name] && !self.locks[lock.name]) {
        self.locksToAdd[lock.name] = lock;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDiscoverdLock
                                                            object:lock];
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
        connectedPeripheral:(SEBLEPeripheral *)peripheral
{
    SLLock *lock = [self lockFromPeripheral:peripheral];
    [self addLock:lock];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
           removePeripheral:(SEBLEPeripheral *)peripheral
{
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
          updatedPeripheral:(SEBLEPeripheral *)peripheral
      forCharacteristicUUID:(NSString *)uuid
                   withData:(NSData *)data
{
    if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo]]) {
        [self handleHardwareServiceForLockNameed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet]]) {
        [self handleMagnetForLockNamed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer]]) {
        [self handleAccelerometerForLockNamed:peripheral.peripheral.name data:data];
    }
}

- (void)bleInterfaceManagerIsPoweredOn:(SEBLEInterfaceMangager *)interfaceManager
{
    self.bleIsPoweredOn = YES;
}

@end
