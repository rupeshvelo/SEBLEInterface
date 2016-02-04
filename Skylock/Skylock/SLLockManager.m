
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
#import "SLLockValue.h"
#import "SLNotificationManager.h"
#import "SLAccelerometerValues.h"
#import "SLRestManager.h"
#import "NSString+Skylock.h"
#import "Skylock-Swift.h"
#import <Security/Security.h>
#import "SLUserDefaults.h"
#import "SLUser.h"


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
    SLLockManagerCharacteristicAccelerometer,
    SLLockManagerCharacteristicSecurityState,
    SLLockManagerCharacteristicPublicKey,
    SLLockManagerCharacteristicSignedMessage,
    SLLockManagerCharacteristicChallengeData
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristicState) {
    SLLockManagerCharacteristicStateNone,
    SLLockManagerCharacteristicStateLedOn,
    SLLockManagerCharacteristicStateLedOff,
    SLLockManagerCharacteristicStateOpenLock,
    SLLockManagerCharacteristicStateCloseLock,
};

typedef NS_ENUM(NSUInteger, SLLockManagerConnectionPhase) {
    SLLockManagerConnectionPhaseNone,
    SLLockManagerConnectionPhasePublicKey,
    SLLockManagerConnectionPhaseChallengeKey,
    SLLockManagerConnectionPhaseSignedMessage
};

typedef enum {
    SLLockManagerValueOff       = 0x00,
    SLLockManagerValueLedOn     = 0x4F,
    SLLockManagerValueOn        = 0x01,
    
} SLLockMangerValue;

typedef NS_ENUM(NSUInteger, SLLockManagerValueService) {
    SLLockManagerValueServiceAccelerometer,
    SLLockManagerValueServiceHardware,
};

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) NSMutableDictionary *locksToAdd;
@property (nonatomic, strong) SLDatabaseManager *databaseManger;
@property (nonatomic, assign) BOOL bleIsPoweredOn;
@property (nonatomic, strong) NSTimer *harwareTimer;
@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) NSMutableDictionary *lockValues;
@property (nonatomic, strong) NSMutableSet *namesToConnect;
@property (nonatomic, strong) NSMutableDictionary *lockConnectionPhases;
@property (nonatomic, assign) BOOL shouldSearch;
@property (nonatomic, strong) SLKeychainHandler *keychainHandler;

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
        _lockValues             = [NSMutableDictionary new];
        _lockConnectionPhases   = [NSMutableDictionary new];
        
        _namesToConnect         = [NSMutableSet new];
        _bleManager             = [SEBLEInterfaceMangager sharedManager];
        _bleManager.delegate    = self;
        _databaseManger         = [SLDatabaseManager sharedManager];
        _keychainHandler        = [SLKeychainHandler new];
        _bleIsPoweredOn         = NO;
        _shouldSearch           = NO;
    }
    
    return self;
}

+ (id)sharedManager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLLockManager *lockManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockManger = [[self alloc] init];
    });
    
    return lockManger;
}

- (BOOL)isLockConnected:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return !!self.locks[lock.name];
}

- (NSArray *)deviceNameFragmentsToConnect
{
    return @[@"skylock"];
}

- (NSSet *)servicesToSubcribeTo
{
    NSArray *services = @[[self uuidForService:SLLockManagerServiceSecurity],
                          [self uuidForService:SLLockManagerServiceHardware],
                          [self uuidForService:SLLockManagerServiceConfiguration],
                          [self uuidForService:SLLockManagerServiceTest],
                          [self uuidForService:SLLockManagerServiceBoot],
                          [self uuidForService:SLLockManagerServiceSecurity],
                          [self uuidForCharacteristic:SLLockManagerCharacteristicSignedMessage]
                          ];
    
    return [NSSet setWithArray:services];
}

- (NSSet *)characteristicsToRead
{
    NSArray *readChars = @[[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicLed],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicLock],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicMagnet],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicPublicKey],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicSignedMessage],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]
                           ];
    
    return [NSSet setWithArray:readChars];
}

- (NSSet *)charcteristicsToNotify
{
    NSArray *notifyChars = @[[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicPublicKey],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicLock]
                             ];
    
    return [NSSet setWithArray:notifyChars];
}

- (NSSet *)servicesToBeNotifedOfWhenFound
{
    NSArray *services = @[[self uuidForService:SLLockManagerServiceSecurity]];
    return [NSSet setWithArray:services];
}

- (NSMutableDictionary *)lockValues
{
    if (!_lockValues) {
        _lockValues = [NSMutableDictionary new];
    }
    
    return _lockValues;
}

- (NSDictionary *)connectionPhases
{
    NSDictionary *phases = @{@(SLLockManagerConnectionPhasePublicKey): @(NO),
                             @(SLLockManagerConnectionPhaseChallengeKey): @(NO),
                             @(SLLockManagerConnectionPhaseSignedMessage): @(NO)
                             };
    
    return phases;
}

- (void)setCurrentLock:(SLLock *)lock
{
    [self.locks enumerateKeysAndObjectsUsingBlock:^(id key, SLLock *aLock, BOOL *stop) {
        aLock.isCurrentLock = @(NO);
    }];
    
    self.selectedLock = lock;
    self.selectedLock.isCurrentLock = @(YES);
    [SLDatabaseManager.sharedManager setCurrentLock:self.selectedLock];
    
    [self startGettingHardwareData];
}

- (SLLock *)getCurrentLock
{
    return self.selectedLock;
}

- (void)deselectAllLocks
{
    [self.locks enumerateKeysAndObjectsUsingBlock:^(id key, SLLock *aLock, BOOL *stop) {
        aLock.isCurrentLock = @(NO);
    }];
    
    self.selectedLock = nil;
    [SLDatabaseManager.sharedManager deselectAllLocks];
}

- (void)addLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isLockConnected:lock]) {
        NSLog(@"Duplicate lock: %@", lock.name);
    } else if (self.locksToAdd[lock.name]) {
        [self connectLock:lock];
    } else {
        for (SLLock *dbLock in [self.databaseManger allLocks]) {
            if ([dbLock.name isEqualToString:lock.name]) {
                [self connectLock:lock];
                break;
            }
        }
    }
}

- (void)connectLock:(SLLock *)lock
{
    SLLockManagerConnectionPhase phase = lock.isInFactoryMode ?
            SLLockManagerConnectionPhasePublicKey : SLLockManagerConnectionPhaseSignedMessage;
    self.lockConnectionPhases[lock.name] = @(phase);
    self.locks[lock.name] = lock;
    [self.bleManager addPeripheralNamed:lock.name];
    [self saveLockToDatabase:lock];
    
    if (self.locksToAdd[lock.name]) {
        [self.locksToAdd removeObjectForKey:lock.name];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerConnectedLock
                                                        object:nil];
}

- (void)addLocksFromDb:(NSArray *)locks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [locks enumerateObjectsUsingBlock:^(SLLock *lock, NSUInteger idx, BOOL *stop) {
        [self.namesToConnect addObject:lock.name];
    }];
    
    [self.bleManager setDeviceNamesToConnectTo:self.namesToConnect];
}

- (void)removeLock:(SLLock *)lock
{
    // Explicitly called by user to disconnect the lock
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isLockConnected:lock]) {
        [self.locks removeObjectForKey:lock.name];
    }
    
    if ([self.namesToConnect containsObject:lock.name]) {
        [self.namesToConnect removeObject:lock.name];
        [self.bleManager setDeviceNamesToConnectTo:self.namesToConnect];
        [self.bleManager removePeripheralNamed:lock.name];
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
             
- (NSDictionary *)addedAndRemovedLocksFromPreviousLocks:(NSArray *)previousLocks
{
    NSMutableDictionary *prevLocksDict = [NSMutableDictionary new];
    for (SLLock *lock in previousLocks) {
        prevLocksDict[lock.name] = lock;
    }
    
    NSMutableArray *newLocks = [NSMutableArray new];
    [self.locks enumerateKeysAndObjectsUsingBlock:^(NSString *name, SLLock *lock, BOOL *stop) {
        prevLocksDict[name] ? [prevLocksDict removeObjectForKey:name] : [newLocks addObject:lock];
    }];
    
    return @{@"new": newLocks,
             @"removed": prevLocksDict.allValues
             };
}

- (NSDictionary *)lockFromPeripheral:(SEBLEPeripheral *)blePeripheral
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSDictionary *possibleNames = [self factoryAndNonFactoryNameForName:blePeripheral.peripheral.name];
    return [SLDatabaseManager.sharedManager newLockWithName:blePeripheral.peripheral.name
                                              possibleNames:[NSSet setWithArray:possibleNames.allValues]
                                                    andUUID:blePeripheral.CBUUIDAsString];
}

- (BOOL)hasLocksForCurrentUser
{
    return self.namesToConnect.allObjects.count != 0;
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
    [lock updateProperties:values];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerUpdatedLock
                                                        object:lock];
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
    [self.bleManager setDeviceNameFragmentsToConnect:self.deviceNameFragmentsToConnect];
    [self.bleManager setServiceToReadFrom:self.servicesToSubcribeTo];
    [self.bleManager setCharacteristicsToReadFrom:self.characteristicsToRead];
    [self.bleManager setCharacteristicsToReceiveNotificationsFrom:self.charcteristicsToNotify];
    [self.bleManager setServicesToNotifyWhenTheyAreDiscoverd:self.servicesToBeNotifedOfWhenFound];
}

- (void)startGettingHardwareData
{
    self.harwareTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                         target:self
                                                       selector:@selector(getHardwareData:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)getHardwareData:(NSTimer *)timer
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.selectedLock) {
        [self.bleManager readValueForPeripheralNamed:self.selectedLock.name
                                      forServiceUUID:[self uuidForService:SLLockManagerServiceHardware]
                               andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo]];
    }
}

- (void)shouldEnterSearchMode:(BOOL)shouldSearch
{
    self.shouldSearch = shouldSearch;
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

- (void)writeToPeripheralForLockName:(NSString *)lockName
                             service:(SLLockManagerService)service
                      characteristic:(SLLockManagerCharacteristic)characteristic
                                data:(NSData *)data
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *serviceUUID = [self uuidForService:service];
    NSString *characteristicUUID = [self uuidForCharacteristic:characteristic];

    [self.bleManager writeToPeripheralWithName:lockName
                                   serviceUUID:serviceUUID
                            characteristicUUID:characteristicUUID
                                          data:data];
}

- (void)readValueFromPeripheralForLockName:(NSString *)lockName
                                   service:(SLLockManagerService)service
                            characteristic:(SLLockManagerCharacteristic)characteristic
{
    NSLog(@"reading value from lock: %@, for service: %@, for characteristic: %@",
          lockName,
          [self uuidForService:service],
          [self uuidForCharacteristic:characteristic]);
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
            return turnOn ? SLLockManagerValueOn: SLLockManagerValueOff;
            break;
        case SLLockManagerCharacteristicSecurityState:
            return turnOn ? SLLockManagerValueOn : SLLockManagerValueOff;
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
    if (locks && locks.count > 0) {
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
        case SLLockManagerCharacteristicSecurityState:
            characteristicString = @"5E05";
            break;
        case SLLockManagerCharacteristicPublicKey:
            characteristicString = @"5E02";
            break;
        case SLLockManagerCharacteristicSignedMessage:
            characteristicString = @"5E01";
            break;
        case SLLockManagerCharacteristicChallengeData:
            characteristicString = @"5E04";
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

- (void)handleHardwareServiceForLockNamed:(NSString*)lockName data:(NSData *)data
{
    if (data.length != 6) {
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
            temp = bytes[i];
        } else {
            rssi = bytes[i];
        }
    }
    
    NSLog(@"hardware values -- voltage: %@, temp: %@, rssi: %@", @(batteryVoltage), @(temp), @(rssi));
    NSDictionary *values = @{@"batteryVoltage":@(batteryVoltage),
                             @"temperature":@(temp),
                             @"rssiStrength":@(rssi)
                             };
    
    [self updateValues:values forLock:lockName forValue:SLLockManagerValueServiceHardware];
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
    
    uint16_t xmav = 0;
    uint16_t ymav = 0;
    uint16_t zmav = 0;
    uint16_t xvar = 0;
    uint16_t yvar = 0;
    uint16_t zvar = 0;
    
    uint8_t *bytes = (uint8_t *)data.bytes;
    
    for (int i=0; i < data.length; i++) {
        if (i == 0 || i == 1) {
            xmav += bytes[i] << ((i % 2)*CHAR_BIT);
        } else if (i == 2 || i == 3) {
            ymav += bytes[i] << ((i % 2)*CHAR_BIT);
        } else if (i == 4 || i == 5) {
            zmav += bytes[i] << ((i % 2)*CHAR_BIT);
        } else if (i == 6 || i == 7) {
            xvar += bytes[i] << ((i % 2)*CHAR_BIT);
        } else if (i == 8 || i == 9) {
            yvar += bytes[i] << ((i % 2)*CHAR_BIT);
        } else if (i == 10 || i == 11) {
            zvar += bytes[i] << ((i % 2)*CHAR_BIT);
        }
    }
    
    NSDictionary *values = @{@(SLAccerometerDataXMav):@(xmav),
                             @(SLAccerometerDataYMav):@(ymav),
                             @(SLAccerometerDataZMav):@(zmav),
                             @(SLAccerometerDataXVar):@(xvar),
                             @(SLAccerometerDataYVar):@(yvar),
                             @(SLAccerometerDataZVar):@(zvar)
                             };
    
    [self updateValues:values forLock:lockName forValue:SLLockManagerValueServiceAccelerometer];
}

- (void)handleSecurityStateUpdateForLockNamed:(NSString *)lockName data:(NSData *)data
{
    if (data.length > 1) {
        NSLog(@"Error reading security state data. The data should contain 1 bytes but has: %lul",
              (unsigned long)data.length);
        return;
    }
    
    u_int8_t *bytes = (u_int8_t *)data.bytes;
    u_int8_t value = bytes[0];
    
    if (value == 3 || value == 4) {
        NSLog(@"Successfully wrote challenge data to %@", lockName);
        [NSNotificationCenter.defaultCenter postNotificationName:kSLNotificationLockPaired
                                                          object:nil];
        return;
    }
    
    if (value != 0 && value != 1 && value != 2) {
        NSLog(@"Error: updating security state");
        return;
    }
    
    if (value == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (![ud objectForKey:SLUserDefaultsSignedMessage]) {
            return;
        }
        
        NSString *signedMessage = [ud objectForKey:SLUserDefaultsSignedMessage];
        NSLog(@"will write signed message %@", signedMessage);
        [self writeToPeripheralForLockName:lockName
                                   service:SLLockManagerServiceSecurity
                            characteristic:SLLockManagerCharacteristicSignedMessage
                                      data:[signedMessage bytesString]];
        return;
    }
    
    NSLog(@"Attempting to get challenge data from %@", lockName);
    [self.bleManager readValueForPeripheralNamed:lockName
                            forServiceUUID:[self uuidForService:SLLockManagerServiceSecurity]
                           andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]];
}

- (void)handleChallengeDataForLockNamed:(NSString *)lockName data:(NSData *)data
{
    if (data.length != 32) {
        NSLog(@"Challenge data from lock is not 32 bytes");
        return;
    }
    
    NSMutableString *challengeString = [NSMutableString new];
    uint8_t *bytes = (uint8_t *)data.bytes;
    for (int i=0; i < data.length; i++) {
        [challengeString appendFormat:@"%d", bytes[i]];
    }
    
    
    NSLog(@"Received challenge data from lock: %@", challengeString);
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"challenge_data"];
    NSString *challegeKey = [ud objectForKey:SLUserDefaultsChallengeKey];
    NSDictionary *challengeObject = @{@"c_key": challegeKey,
                                      @"c_data": challengeString
                                      };
    
    [SLRestManager.sharedManager postObject:challengeObject
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyChallengeData subRoutes:subRoutes additionalHeaders:additionalHeaders
                                 completion:^(NSDictionary *responseDict) {
                                     NSLog(@"received response: %@", responseDict);
                                     if (!responseDict || !responseDict[@"challenge_data"]) {
                                         // TODO figure out what to do when this happens. UI? Retry?
                                         NSLog(@"Error getting challenge data from server");
                                         return;
                                     }
                                     
                                     NSString *serverChallengeString = responseDict[@"challenge_data"];
                                     NSLog(@"Recieved challenge data from server: %@", serverChallengeString);
                                     NSData *challengeData = [serverChallengeString bytesString];
                                     NSLog(@"Will write challenge data with length %@", @(challengeData.length));
                                     [self.bleManager writeToPeripheralWithName:lockName
                                                                    serviceUUID:[self uuidForService:SLLockManagerServiceSecurity]
                                                             characteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]
                                                                           data:challengeData];
                                 }];
}

- (void)updateValues:(NSDictionary *)values forLock:(NSString *)lockName forValue:(SLLockManagerValueService)service
{
    SLLockValue *lockValue;
    if (self.lockValues[@(service)]) {
        lockValue = self.lockValues[@(service)];
    } else {
        lockValue = [[SLLockValue alloc] initWithMaxCount:3 andLockName:lockName];
        lockValue.delegate = self;
        self.lockValues[@(service)] = lockValue;
    }
    
    [lockValue updateValuesWithValues:values];
}

- (void)checkAutoUnlockForLock:(SLLock *)lock
{
    BOOL updateLockState = YES;
    static NSInteger rssiStrength = 50;
    if (lock.rssiStrength.integerValue < rssiStrength && lock.isLocked.boolValue) {
        lock.isLocked = @(NO);
    } else if (lock.rssiStrength.integerValue > rssiStrength && !lock.isLocked.boolValue) {
        lock.isLocked = @(YES);
    } else {
        updateLockState = NO;
    }
    
    if (updateLockState) {
        [self setLockStateForLock:lock];
    }
}

- (void)handlePublicKeyConnectionPhase:(SLLock *)lock
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *publicKey = [ud objectForKey:SLUserDefaultsPublicKey];

    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceSecurity
                        characteristic:SLLockManagerCharacteristicPublicKey
                                  data:publicKey.bytesString];
    
    self.lockConnectionPhases[lock.name] = @(SLLockManagerConnectionPhaseChallengeKey);
}

- (void)handleChallengeKeyConnectionPhase:(SLLock *)lock
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"keys"];
    [SLRestManager.sharedManager getRequestWithServerKey:SLRestManagerServerKeyMain
                                                 pathKey:SLRestManagerPathKeyChallengeKey
                                                 subRoutes:subRoutes
                                       additionalHeaders:additionalHeaders
                                              completion:^(NSDictionary *responseDict) {
                                                  if (!responseDict) {
                                                      // TODO figure out how to handle this
                                                      NSLog(@"Error could not retrieve challenge key from server.");
                                                      return;
                                                  }
                                                  
                                                  NSString *challengeKey = responseDict[@"challenge_key"];
                                                  [ud setObject:challengeKey forKey:SLUserDefaultsChallengeKey];
            
                                                  [self writeToPeripheralForLockName:lock.name
                                                                             service:SLLockManagerServiceSecurity
                                                                      characteristic:SLLockManagerCharacteristicPublicKey
                                                                                data:challengeKey.bytesString];
                                                
                                                  self.lockConnectionPhases[lock.name] = @(SLLockManagerConnectionPhaseSignedMessage);
                                              }];
}

- (void)handleSignedMessageConnectionPhase:(SLLock *)lock
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *signedMessage = [ud objectForKey:SLUserDefaultsSignedMessage];
    
    [self writeToPeripheralForLockName:lock.name
                               service:SLLockManagerServiceSecurity
                        characteristic:SLLockManagerCharacteristicSignedMessage
                                  data:signedMessage.bytesString];
}

- (void)handleLockStateForLockNamed:(NSString *)lockName data:(NSData *)data
{
    
}

- (NSDictionary *)factoryAndNonFactoryNameForName:(NSString *)name
{
    NSDictionary *names;
    NSString *factoryName = nil;
    NSString *nonFactoryName = nil;
    NSArray *parts;
    
    if ([name rangeOfString:@"-"].location == NSNotFound) {
        // lock is not in factory mode
        parts = [name componentsSeparatedByString:@" "];
        if (parts.count != 2) {
            NSLog(@"Error parsing lock name and factory name");
        } else {
            factoryName = [parts componentsJoinedByString:@"-"];
            nonFactoryName = name;
        }
    } else {
        // lock is in factory mode
        parts = [name componentsSeparatedByString:@"-"];
        if (parts.count != 2) {
            NSLog(@"Error parsing lock name and factory name");
        } else {
            factoryName = name;
            nonFactoryName = [parts componentsJoinedByString:@" "];;
        }
    }
    
    if (factoryName && nonFactoryName) {
        names = @{@"factory": factoryName,
                  @"nonFactory": nonFactoryName
                  };
    }
    
    return names;
}
#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger
       discoveredPeripheral:(SEBLEPeripheral *)peripheral
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLUser *currentUser = [self.databaseManger currentUser];
    NSDictionary *lockDict = [self lockFromPeripheral:peripheral];
    NSNumber *isNew = lockDict[@"isNew"];
    SLLock *lock = lockDict[@"lock"];
    [lock setInitialProperties:@{}];
    [lock setCurrentLocation:currentUser.location];
    
    if (!isNew.boolValue && !self.locks[lock.name] && !lock.isInFactoryMode) {
        self.lockConnectionPhases[lock.name] = @(SLLockManagerConnectionPhaseSignedMessage);
        self.locksToAdd[lock.name] = lock;
        [self addLock:lock];
        return;
    }
    
    if ((!self.locksToAdd[lock.name] &&
        !self.locks[lock.name]) &&
        ([self.namesToConnect containsObject:peripheral.peripheral.name] || self.shouldSearch)) {
        
        if (![self.namesToConnect containsObject:peripheral.peripheral.name]) {
            [self.namesToConnect addObject:peripheral.peripheral.name];
        }
        
        self.locksToAdd[lock.name] = lock;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        SLRestManager *restManager = [SLRestManager sharedManager];
        
        NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
        NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
        NSDictionary *additionalHeaders = @{@"Authorization": authValue};
        NSArray *subRoutes = @[currentUser.userId, @"keys"];
        NSDictionary *lockData = @{@"mac_id":lock.macAddress};

        [SLRestManager.sharedManager postObject:lockData
                                      serverKey:SLRestManagerServerKeyMain
                                        pathKey:SLRestManagerPathKeyKeys
                                      subRoutes:subRoutes
                              additionalHeaders:additionalHeaders
                                     completion:^(NSDictionary *responseDict) {
            if (responseDict && responseDict[@"signed_message"] && responseDict[@"public_key"] && responseDict[@"message"]) {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                
                [ud setObject:responseDict[@"signed_message"] forKey:SLUserDefaultsSignedMessage];
                [ud setObject:responseDict[@"public_key"] forKey:SLUserDefaultsPublicKey];
                [ud setObject:responseDict[@"message"] forKey:SLUserDefaultsChallengeKey];
                [ud synchronize];

                [self addLock:lock];
            }
        }];
    
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
        connectedPeripheral:(SEBLEPeripheral *)peripheral
{
    [peripheral.peripheral discoverServices:nil];
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
        [self handleHardwareServiceForLockNamed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet]]) {
        [self handleMagnetForLockNamed:peripheral.peripheral.name data:data];
    } else if([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLock]]) {
        [self handleLockStateForLockNamed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer]]) {
        [self handleAccelerometerForLockNamed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState]]) {
        [self handleSecurityStateUpdateForLockNamed:peripheral.peripheral.name data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]]) {
        [self handleChallengeDataForLockNamed:peripheral.peripheral.name data:data];
    }
}

- (void)bleInterfaceManagerIsPoweredOn:(SEBLEInterfaceMangager *)interfaceManager
{
    NSLog(@"blue tooth manager powered on");
    self.bleIsPoweredOn = YES;
    
    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    if (user && user.locks.count > 0) {
        self.shouldSearch = YES;
        [self.bleManager startScan];
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
     disconnectedPeripheral:(SEBLEPeripheral *)peripheral
{
    if ([self.namesToConnect containsObject:peripheral.peripheral.name]) {
        return;
    }
    
    if ([self.selectedLock.name isEqualToString:peripheral.peripheral.name]) {
        self.selectedLock = nil;
    }
    
    if (self.locks[peripheral.peripheral.name]) {
        [self.locks removeObjectForKey:peripheral.peripheral.name];
    }
    
    if (self.locksToAdd[peripheral.peripheral.name]) {
        [self.locksToAdd removeObjectForKey:peripheral.peripheral.name];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDisconnectedLock
                                                        object:@{@"lockName":peripheral.peripheral.name}];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
                 peripheral:(SEBLEPeripheral *)peripheral
changedUpdateStateForCharacteristic:(NSString *)characteristicUUID
{
    if ([characteristicUUID isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState]]) {
        SLLock *lock = self.locks[peripheral.peripheral.name];
        if (self.lockConnectionPhases[lock.name]) {
            NSNumber *phaseNumber = self.lockConnectionPhases[lock.name];
            SLLockManagerConnectionPhase phase = (SLLockManagerConnectionPhase)phaseNumber.unsignedIntegerValue;
            switch (phase) {
                case SLLockManagerConnectionPhasePublicKey:
                    [self handlePublicKeyConnectionPhase:lock];
                    break;
                case SLLockManagerConnectionPhaseChallengeKey:
                    [self handleChallengeKeyConnectionPhase:lock];
                case SLLockManagerConnectionPhaseSignedMessage:
                    [self handleSignedMessageConnectionPhase:lock];
                default:
                    break;
            }
        }
    }
}

#pragma mark - SLLockValue delegate methods
- (void)lockValueMeanUpdated:(SLLockValue *)lockValue mean:(NSDictionary *)meanValues
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"%@ updated mean values: %@", lockValue.name, meanValues);
    SLLock *lock = self.locks[lockValue.name];
    if (lockValue == self.lockValues[@(SLLockManagerValueServiceAccelerometer)]) {
        [lock updateAccelerometerValues:meanValues];
        [SLNotificationManager.sharedManager checkIfLockNeedsNotification:lock];
    } else {
        [lock updateProperties:meanValues];
        [self checkAutoUnlockForLock:lock];
    }
}

@end
