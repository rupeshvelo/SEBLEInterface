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
#import <CommonCrypto/CommonHMAC.h>

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
    SLLockManagerCharacteristicChallengeData,
    SLLockManagerCharacteristicChallengeKey,
    SLLockManagerCharacteristicCodeVersion,
    SLLockManagerCharacteristicButtonLockSequence,
    SLLockManagerCharacteristicRemoveLock
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
    SLLockManagerConnectionPhaseChallengeData,
    SLLockManagerConnectionPhaseSignedMessage
};

typedef enum {
    SLLockManagerValueOff               = 0x00,
    SLLockManagerValueLedOn             = 0x4F,
    SLLockManagerValueOn                = 0x01,
    SLLockManagerValueLockLocked        = 0x01,
    SLLockManagerValueLockOpen          = 0x00,
    SLLockManagerValueLockIntermediate  = 0x02,
    SLLockManagerValueLockInvalid       = 0x03,
    SLLockManagerValueTopButton         = 0x01,
    SLLockManagerValueRightButton       = 0x02,
    SLLockManagerValueBottomButton      = 0x04,
    SLLockManagerValueLeftButton        = 0x08,
    SLLockManagerValueRemoveLock        = 0xBC
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
    return !!self.locks[lock.macAddress];
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
                           [self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicChallengeKey],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicCodeVersion],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicButtonLockSequence]
                           ];
    
    return [NSSet setWithArray:readChars];
}

- (NSSet *)charcteristicsToNotify
{
    NSArray *notifyChars = @[[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState],
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
    [self.databaseManger setCurrentLock:self.selectedLock];
    
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
    [self.databaseManger deselectAllLocks];
}

- (void)addLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isLockConnected:lock]) {
        NSLog(@"Duplicate lock: %@", lock.name);
    } else if (self.locksToAdd[lock.macAddress]) {
        [self connectLock:lock];
    } else {
        for (SLLock *dbLock in [self.databaseManger allLocks]) {
            if ([dbLock.macAddress isEqualToString:lock.macAddress]) {
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
    self.lockConnectionPhases[lock.macAddress] = @(phase);
    self.locks[lock.macAddress] = lock;
    [self.bleManager addPeripheralWithKey:lock.macAddress];
    
    [self saveLockToDatabase:lock];
    
    if (self.locksToAdd[lock.macAddress]) {
        [self.locksToAdd removeObjectForKey:lock.macAddress];
    }
    
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Connecting lock: %@", lock.name]];
}

- (void)addLocksFromDb:(NSArray *)locks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [locks enumerateObjectsUsingBlock:^(SLLock *lock, NSUInteger idx, BOOL *stop) {
        [self.namesToConnect addObject:lock.macAddress];
    }];
    
    [self.bleManager setDeviceNamesToConnectTo:self.namesToConnect];
}

- (void)removeLock:(SLLock *)lock
{
    // Explicitly called by user to disconnect the lock
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self isLockConnected:lock]) {
        [self.locks removeObjectForKey:lock.macAddress];
    }
    
    if ([self.namesToConnect containsObject:lock.macAddress]) {
        [self.namesToConnect removeObject:lock.macAddress];
        [self.bleManager setDeviceNamesToConnectTo:self.namesToConnect];
        [self.bleManager removePeripheralForKey:lock.macAddress];
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
        prevLocksDict[lock.macAddress] = lock;
    }
    
    NSMutableArray *newLocks = [NSMutableArray new];
    [self.locks enumerateKeysAndObjectsUsingBlock:^(NSString *name, SLLock *lock, BOOL *stop) {
        prevLocksDict[name] ? [prevLocksDict removeObjectForKey:name] : [newLocks addObject:lock];
    }];
    
    return @{@"new": newLocks,
             @"removed": prevLocksDict.allValues
             };
}

- (SLLock *)lockWithName:(NSString *)name CBUUID:(NSString *)cbuuid
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    return [self.databaseManger newLockWithName:name
                                                    andUUID:cbuuid];
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
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Starting bluetooth scan"]];
}

- (void)stopScan
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.bleManager stopScan];
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Stopping bluetooth scan"]];
}

- (void)startBlueToothManager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Starting bluetooth manager"]];
    
    for (SLLock *lock in [self.databaseManger allLocks]) {
        NSLog(@"lock in database: %@", lock.name);
    }
    
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
        [self.bleManager readValueForPeripheralWithKey:self.selectedLock.macAddress
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
    [self writeToLockWithMacAddress:lock.macAddress
                            service:SLLockManagerServiceHardware
                     characteristic:SLLockManagerCharacteristicLock
                             turnOn:!lock.isLocked.boolValue];
}

- (void)toggleCrashForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self writeToLockWithMacAddress:lock.macAddress
                            service:SLLockManagerServiceHardware
                     characteristic:SLLockManagerCharacteristicLed
                             turnOn:!lock.isCrashOn.boolValue];
}

- (void)toggleSecurityForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
}

- (void)toggleSharingForLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)writeToLockWithMacAddress:(NSString *)macAddress
                          service:(SLLockManagerService)service
                   characteristic:(SLLockManagerCharacteristic)characteristic
                           turnOn:(BOOL)turnOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    u_int8_t value = [self valueForCharacteristic:characteristic turnOn:turnOn];
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self writeToLockWithMacAddress:macAddress
                            service:service
                     characteristic:characteristic
                               data:data];
}

- (void)writeToLockWithMacAddress:(NSString *)macAddress
                 service:(SLLockManagerService)service
          characteristic:(SLLockManagerCharacteristic)characteristic
                    data:(NSData *)data
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *serviceUUID = [self uuidForService:service];
    NSString *characteristicUUID = [self uuidForCharacteristic:characteristic];

    [self.bleManager writeToPeripheralWithKey:macAddress
                                  serviceUUID:serviceUUID
                           characteristicUUID:characteristicUUID
                                         data:data];
}

- (void)readValueFromPeripheralForMacAddress:(NSString *)macAddress
                                     service:(SLLockManagerService)service
                              characteristic:(SLLockManagerCharacteristic)characteristic
{
    NSString *serviceUUID = [self uuidForService:service];
    NSString *characteristicUUID = [self uuidForCharacteristic:characteristic];
    NSLog(@"Attempting to read value from lock: %@, for service: %@, for characteristic: %@",
          macAddress,
          serviceUUID,
          characteristicUUID);
    [self.bleManager readValueForPeripheralWithKey:macAddress
                                    forServiceUUID:serviceUUID
                             andCharacteristicUUID:characteristicUUID];
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
            return turnOn ? SLLockManagerValueOn : SLLockManagerValueOff;
            break;
        case SLLockManagerCharacteristicSecurityState:
            return turnOn ? SLLockManagerValueOn : SLLockManagerValueOff;
            break;
        default:
            return SLLockManagerCharacteristicStateNone;
            break;
    }
}

- (void)saveLockToDatabase:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    SLUser *currentUser = self.databaseManger.currentUser;
    lock.user = currentUser;
    
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
        case SLLockManagerCharacteristicSignedMessage:
            characteristicString = @"5E01";
            break;
        case SLLockManagerCharacteristicPublicKey:
            characteristicString = @"5E02";
            break;
        case SLLockManagerCharacteristicChallengeKey:
            characteristicString = @"5E03";
            break;
        case SLLockManagerCharacteristicChallengeData:
            characteristicString = @"5E04";
            break;
        case SLLockManagerCharacteristicSecurityState:
            characteristicString = @"5E05";
            break;
        case SLLockManagerCharacteristicCodeVersion:
            characteristicString = @"5D01";
            break;
        case SLLockManagerCharacteristicButtonLockSequence:
            characteristicString = @"5E84";
            break;
        case SLLockManagerCharacteristicRemoveLock:
            characteristicString = @"5E81";
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

- (void)handleHardwareServiceForMacAddress:(NSString*)macAddress data:(NSData *)data
{
    if (data.length != 12) {
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
    
    [self updateValues:values forLockMacAddress:macAddress forValue:SLLockManagerValueServiceHardware];
}

- (void)handleMagnetForLockMacAddress:(NSString *)macAddress data:(NSData *)data
{
    
}

- (void)handleAccelerometerForLockMacAddress:(NSString *)macAddress data:(NSData *)data
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
    
    [self updateValues:values forLockMacAddress:macAddress forValue:SLLockManagerValueServiceAccelerometer];
}

- (void)handleSecurityStateUpdateForLockMacAddress:(NSString *)macAddress data:(NSData *)data
{
    if (data.length != 1) {
        NSLog(@"Error reading security state data. The data should contain 1 bytes but has: %lul bytes",
              (unsigned long)data.length);
        return;
    }
    
    u_int8_t *bytes = (u_int8_t *)data.bytes;
    u_int8_t value = bytes[0];
    
    NSNumber *phaseNumber = self.lockConnectionPhases[macAddress];
    SLLockManagerConnectionPhase phase = (SLLockManagerConnectionPhase)phaseNumber.unsignedIntegerValue;
    NSLog(@"handle secturity state update has value of %@ for phase %@", @(value), @(phase));
    
    if (value != 0 && value != 1 && value != 2 && value != 3 && value != 4) {
        NSLog(@"Error: updating security state got value: %@", @(value));
        [SLDatabaseManager.sharedManager saveLogEntry:
         [NSString stringWithFormat:@"Error: updating security state got value: %@", @(value)]];
        return;
    }
    
    if (value == 0) {
        if (phase == SLLockManagerConnectionPhaseChallengeKey) {
            self.lockConnectionPhases[macAddress] = @(SLLockManagerConnectionPhaseSignedMessage);
            [self handleChallengeKeyConnectionPhase:macAddress];
        } else if (phase == SLLockManagerConnectionPhaseSignedMessage) {
            [self handleSignedMessageConnectionPhase:macAddress];
        } else {
            NSLog(@"handle security state has value of %@ but the phase %@ is not correct", @(value), @(phase));
        }
        
        return;
    }
    
    if (value == 1 || value == 2) {
        NSLog(@"wrote signed message to %@ successfully", macAddress);
        NSLog(@"Attempting to get challenge data from %@", macAddress);
        [SLDatabaseManager.sharedManager saveLogEntry:
         [NSString stringWithFormat:@"wrote signed message to %@ successfully. Attempting to get challenge data", macAddress]];
        [self.bleManager readValueForPeripheralWithKey:macAddress
                                        forServiceUUID:[self uuidForService:SLLockManagerServiceSecurity]
                                 andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]];
        return;
    }
    
    NSLog(@"Successfully wrote challenge data to %@", macAddress);
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Successfully wrote challenge data to %@", macAddress]];
    
    SLLock *lock = self.locks[macAddress];
    if (lock.isInFactoryMode) {
        NSLog(@"lock name before saving: %@", lock.macAddress);
        
        NSLog(@"all locks in db...");
        for (SLLock *dbLock in [self.databaseManger allLocks]) {
            NSLog(@"%@", dbLock.name);
        }
        
        [lock switchLockNameToProvisioned];
        NSLog(@"lock name after switching name: %@", lock.name);
        [self.databaseManger saveLockToDb:lock withCompletion:nil];
        
        NSLog(@"locks in db after saving...");
        for (SLLock *dbLock in [self.databaseManger allLocks]) {
            NSLog(@"%@", dbLock.name);
        }
        
        [self.locks removeObjectForKey:macAddress];
        self.locks[lock.macAddress] = lock;
        [self.bleManager updateConnectPeripheralKey:macAddress newKey:lock.macAddress];
    }
    
    [self.bleManager stopScan];
    [self setCurrentLock:lock];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kSLNotificationLockPaired
                                                      object:@{@"lock": lock}];
}

- (void)handleChallengeDataForLockMacAddress:(NSString *)macAddress data:(NSData *)data
{
    if (data.length != 32) {
        NSLog(@"Challenge data from lock is not 32 bytes");
        return;
    }
    
    NSMutableString *challengeString = [NSMutableString new];
    uint8_t *bytes = (uint8_t *)data.bytes;
    NSDictionary *hexMap = @{@(0): @"0",
                             @(1): @"1",
                             @(2): @"2",
                             @(3): @"3",
                             @(4): @"4",
                             @(5): @"5",
                             @(6): @"6",
                             @(7): @"7",
                             @(8): @"8",
                             @(9): @"9",
                             @(10): @"a",
                             @(11): @"b",
                             @(12): @"c",
                             @(13): @"d",
                             @(14): @"e",
                             @(15): @"f",
                             };
    
    for (int i=0; i < data.length; i++) {
        Byte byte = bytes[i];
        int byteInt = byte;
        int tens = byteInt / 16;
        int ones = byteInt % 16;
        NSString *bytesString = [NSString stringWithFormat:@"%@%@", hexMap[@(tens)], hexMap[@(ones)]];
        [challengeString appendFormat:@"%@", bytesString];
    }
    
    NSLog(@"challenge string length: %@", @(challengeString.length));
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *challengeKey = [ud objectForKey:SLUserDefaultsChallengeKey];
    
    NSLog(@"challege key length: %@", @(challengeKey.length));
    
    NSData *hashedData = [self SHA256WithDataString:[NSString stringWithFormat:@"%@%@", challengeKey, challengeString]];
    
    [self writeToLockWithMacAddress:macAddress
                            service:SLLockManagerServiceSecurity
                     characteristic:SLLockManagerCharacteristicChallengeData
                               data:hashedData];
}

- (void)updateValues:(NSDictionary *)values
   forLockMacAddress:(NSString *)macAddress
            forValue:(SLLockManagerValueService)service
{
    SLLockValue *lockValue;
    if (self.lockValues[@(service)]) {
        lockValue = self.lockValues[@(service)];
    } else {
        lockValue = [[SLLockValue alloc] initWithMaxCount:3 andMacAddress:macAddress];
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

- (void)handlePublicKeyConnectionPhase:(NSString *)macAddress
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *publicKey = [ud objectForKey:SLUserDefaultsPublicKey];

    [self writeToLockWithMacAddress:macAddress
                   service:SLLockManagerServiceSecurity
            characteristic:SLLockManagerCharacteristicPublicKey
                      data:publicKey.bytesString];
    
    self.lockConnectionPhases[macAddress] = @(SLLockManagerConnectionPhaseChallengeKey);
}

- (void)handleChallengeKeyConnectionPhase:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];

    SLRestManager *restManager = [SLRestManager sharedManager];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"challenge_key"];
    [SLRestManager.sharedManager getRequestWithServerKey:SLRestManagerServerKeyMain
                                                 pathKey:SLRestManagerPathKeyChallengeKey
                                                 subRoutes:subRoutes
                                       additionalHeaders:additionalHeaders
                                              completion:^(NSDictionary *responseDict) {
                                                  if (!responseDict || !responseDict[@"challenge_key"]) {
                                                      // TODO figure out how to handle this
                                                      NSLog(@"Error could not retrieve challenge key from server.");
                                                      return;
                                                  }
                                                  
                                                  NSString *challengeKey = responseDict[@"challenge_key"];
                                                  [ud setObject:challengeKey forKey:SLUserDefaultsChallengeKey];
                                                  [ud synchronize];
                                                  
                                                  [self writeToLockWithMacAddress:macAddress
                                                                 service:SLLockManagerServiceSecurity
                                                          characteristic:SLLockManagerCharacteristicChallengeKey
                                                                    data:challengeKey.bytesString];
                                                
                                                  self.lockConnectionPhases[macAddress] = @(SLLockManagerConnectionPhaseSignedMessage);
                                              }];
}

- (void)handleChallengeDataConnectionPhase:(NSString *)lockName challengeString:(NSString *)challengeString
{
    
}

- (void)handleSignedMessageConnectionPhase:(NSString *)macAddress
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *signedMessage = [ud objectForKey:SLUserDefaultsSignedMessage];
    
    [self writeToLockWithMacAddress:macAddress
                            service:SLLockManagerServiceSecurity
                     characteristic:SLLockManagerCharacteristicSignedMessage
                               data:signedMessage.bytesString];
}

- (void)handleLockStateForLockMacAddress:(NSString *)macAddress data:(NSData *)data
{
    // TODO -- Need to check what happens when the lock is neither open or closed
    // or the read was invalid. These cases should be handled in the below switch statement
    char *bytes = (char *)data.bytes;
    uint16_t value = bytes[0];
    BOOL isLocked;
    NSString *notification;
    
    switch (value) {
        case SLLockManagerValueLockOpen:
            isLocked = NO;
            notification = kSLNotificationLockOpened;
            break;
        case SLLockManagerValueLockLocked:
            isLocked = YES;
            notification = kSLNotificationLockClosed;
            break;
        default:
            isLocked = YES;
            notification = kSLNotificationLockClosed;
            break;
    }
    
    SLLock *lock = self.locks[macAddress];
    lock.isLocked = @(isLocked);
    [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                        object:@{@"lock": lock}];
}

- (void)handleLEDStateForLockMacAddress:(NSString *)macAddress data:(NSData *)data
{
    char *bytes = (char *)data.bytes;
    uint16_t value = bytes[0];
    BOOL isOn;
    NSString *notification;
    if (value == SLLockManagerValueLedOn) {
        isOn = YES;
        notification = kSLNotificationLedTurnedOn;
    } else if (value == SLLockManagerValueOff) {
        isOn = NO;
        notification = kSLNotificationLedTurnedOff;
    }
    
    SLLock *lock = self.locks[macAddress];
    lock.isCrashOn = @(isOn);
    [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                        object:@{@"lock": lock}];
}

- (void)handleLockSequenceWriteForMacAddress:(NSString *)macAddress data:(NSData *)data
{
    // TODO post notification that new sequence was accepted or declined
    NSLog(@"updated lock sequence successfully");
}

- (NSDictionary *)factoryAndNonFactoryNameForName:(NSString *)name
{
    NSString *factoryName = nil;
    NSString *nonFactoryName = nil;
    NSArray *parts;
    
    if ([name rangeOfString:@"-"].location == NSNotFound) {
        // lock is not in factory mode
        parts = [name componentsSeparatedByString:@" "];
        if (parts.count == 2) {
            factoryName = [parts componentsJoinedByString:@"-"];
            nonFactoryName = name;
        } else {
            NSLog(@"Error parsing lock name and factory name");
        }
    } else {
        // lock is in factory mode
        parts = [name componentsSeparatedByString:@"-"];
        if (parts.count == 2) {
            factoryName = name;
            nonFactoryName = [parts componentsJoinedByString:@" "];
        } else {
            NSLog(@"Error parsing lock name and factory name");
        }
    }
    
    NSDictionary *names;
    if (factoryName && nonFactoryName) {
        names = @{@"factory": factoryName,
                  @"nonFactory": nonFactoryName
                  };
    }
    
    return names;
}

- (void)updateFirmware
{
    [SLRestManager.sharedManager getRequestWithServerKey:SLRestManagerServerKeyMain
                                                 pathKey:SLRestManagerPathKeyFirmwareUpdate
                                               subRoutes:nil additionalHeaders:nil
                                              completion:^(NSDictionary *responseDict) {
                                                  if (responseDict && responseDict[@"payload"]) {
                                                      NSMutableArray *parts = [NSMutableArray new];
                                                      NSArray *payload = responseDict[@"payload"];
                                                      
                                                      for (NSDictionary *part in payload) {
                                                          [parts addObject:part[@"boot_loader"]];
                                                      }
                                                      
                                                      for (NSString *part in parts) {
                                                          NSLog(@"%@", part);
                                                      }
                                                  }
        
    }];
}

- (void)deleteLockFromCurrentUserAccountWithMacAddress:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"deletelock"];
    SLLock *lock = self.locks[macAddress];
    
    [SLRestManager.sharedManager postObject:@{@"mac_id":lock.macAddress}
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyUsers subRoutes:subRoutes
                          additionalHeaders:additionalHeaders
                                 completion:^(NSDictionary *responseDict) {
                                     // TODO the server currently returns an empty payload for this url
                                     // and the server is always returning an error. When that is fixed,
                                     // this should be updated
                                     
                                     u_int8_t value = (u_int8_t)SLLockManagerValueRemoveLock;
                                     NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
                                     
                                     [self removeLock:lock];

                                     [self writeToLockWithMacAddress:lock.macAddress
                                                             service:SLLockManagerServiceConfiguration
                                                      characteristic:SLLockManagerCharacteristicRemoveLock
                                                                data:data];
                                     
    }];
}

- (void)tempDeleteLockFromCurrentUserAccount:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"deletelock"];
    
    [SLRestManager.sharedManager postObject:@{@"mac_id":macAddress}
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyUsers subRoutes:subRoutes
                          additionalHeaders:additionalHeaders
                                 completion:^(NSDictionary *responseDict) {
                                     
                                 }];
}

- (void)tempReadFirmwareDataForLockAddress:(NSString *)macAddress
{
    [self.bleManager readValueForPeripheralWithKey:macAddress
                                    forServiceUUID:[self uuidForService:SLLockManagerServiceConfiguration]
                             andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicCodeVersion]];
}

- (NSData *)SHA256WithDataString:(NSString *)dataString
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    NSData *data = dataString.bytesString;
    CC_SHA256(data.bytes, (unsigned int)data.length, hash);
    
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];;
}

- (void)removeLockWithMacAddress:(NSString *)macAddress
{
    if ([self.namesToConnect containsObject:macAddress]) {
        return;
    }
    
    if ([self.selectedLock.macAddress isEqualToString:macAddress]) {
        self.selectedLock = nil;
    }
    
    if (self.locks[macAddress]) {
        [self.locks removeObjectForKey:macAddress];
    }
    
    if (self.locksToAdd[macAddress]) {
        [self.locksToAdd removeObjectForKey:macAddress];
    }
    
    [self.bleManager removeNotConnectPeripheralForKey:macAddress];
    [self.bleManager removeConnectedPeripheralForKey:macAddress];
}

- (void)writeTouchPadButtonPushes:(UInt8 *)pushes size:(int)size lock:(SLLock *)lock
{
    static int length = 16;
    if (size > length) {
        NSLog(@"Error: size of touches to write is longer than the maximum allowable number of bytes");
        return;
    }
    
    uint8_t pushData[length];
    for (int i = 0; i < length; i++) {
        pushData[i] = i < size ? pushes[i] : 0x00;
    }
    
    [self writeToLockWithMacAddress:lock.macAddress
                            service:SLLockManagerServiceConfiguration
                     characteristic:SLLockManagerCharacteristicButtonLockSequence
                               data:[NSData dataWithBytes:&pushData length:length]];
}

- (void)readButtonLockSequenceForLock:(SLLock *)lock
{
    [self readValueFromPeripheralForMacAddress:lock.macAddress
                                       service:SLLockManagerServiceConfiguration
                                characteristic:SLLockManagerCharacteristicButtonLockSequence];
}

#pragma mark - SEBLEInterfaceManager Delegate Methods
- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManger
       discoveredPeripheral:(SEBLEPeripheral *)peripheral
       withAdvertisemntData:(NSDictionary *)advertisementData
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSString *name = (advertisementData && advertisementData[@"kCBAdvDataLocalName"]) ?
    advertisementData[@"kCBAdvDataLocalName"] : peripheral.peripheral.name;
    NSLog(@"found peripheral: %@", name);
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"found peripheral: %@", name]];
    NSString *macAddress = name.macAddress;
    if (self.locksToAdd[macAddress]) {
        NSLog(@"Lock %@ already in connection process...", name);
        return;
    }
    
    if (self.locks[macAddress]) {
        [self removeLockWithMacAddress:macAddress];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    SLLockManagerConnectionPhase phase;
    SLUser *currentUser = [self.databaseManger currentUser];
    SLLock *lock = [self.databaseManger getLockWithMacAddress:name.macAddress];
    if (lock) {
        // lock is in the database
        lock.name = name;
        [self saveLockToDatabase:lock];
        
        if (lock.isInFactoryMode) {
            phase = SLLockManagerConnectionPhasePublicKey;
        } else {
            if ([ud objectForKey:SLUserDefaultsPublicKey] && [ud objectForKey:SLUserDefaultsSignedMessage]) {
                phase = SLLockManagerConnectionPhaseSignedMessage;
            } else {
                phase = SLLockManagerConnectionPhaseChallengeKey;
            }
        }
        
        NSLog(@"found %@ in database...connecting", lock.name);

        self.lockConnectionPhases[lock.macAddress] = @(phase);
        self.locksToAdd[lock.macAddress] = lock;
        [self.bleManager setNotConnectedPeripheral:peripheral forKey:lock.macAddress];
        [self addLock:lock];
        
        return;
    }
    
    lock = [self lockWithName:name CBUUID:peripheral.CBUUIDAsString];
    [lock setInitialProperties:@{}];
    phase = lock.isInFactoryMode ?
        SLLockManagerConnectionPhaseChallengeKey : SLLockManagerConnectionPhaseSignedMessage;
    

    //[lock setCurrentLocation:currentUser.location];
    [self.bleManager setNotConnectedPeripheral:peripheral forKey:lock.macAddress];
    self.lockConnectionPhases[macAddress] = @(phase);
    [self.namesToConnect addObject:lock.macAddress];
    self.locksToAdd[lock.macAddress] = lock;
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    
    NSString *token = [ud objectForKey:SLUserDefaultsUserToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[currentUser.userId, @"keys"];
    NSDictionary *lockData = @{@"mac_id": lock.macAddress};

    [SLRestManager.sharedManager postObject:lockData
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyKeys
                                  subRoutes:subRoutes
                          additionalHeaders:additionalHeaders
                                 completion:^(NSDictionary *responseDict) {
        if (responseDict && responseDict[@"signed_message"] &&
            responseDict[@"public_key"] &&
            responseDict[@"message"])
        {
            NSLog(@"messages for lock %@", lock.name);
            [ud setObject:responseDict[@"signed_message"] forKey:SLUserDefaultsSignedMessage];
            [ud setObject:responseDict[@"public_key"] forKey:SLUserDefaultsPublicKey];
            //[ud setObject:responseDict[@"message"] forKey:SLUserDefaultsChallengeKey];
            [ud synchronize];
            
            [SLDatabaseManager.sharedManager saveLogEntry:
             [NSString stringWithFormat:@"received signed message and public key from server for: %@", name]];
            
            [self addLock:lock];
        }
    }];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
        connectedPeripheralNamed:(NSString *)peripheralName
{
    NSString *macAddress = peripheralName.macAddress;
    
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"bluetooth manager connected peripheral %@", peripheralName]];
    
    if ([self.bleManager notConnectedPeripheralForKey:macAddress]) {
        SEBLEPeripheral *peripheral = [self.bleManager notConnectedPeripheralForKey:macAddress];
        [self.bleManager removeNotConnectPeripheralForKey:macAddress];
        [self.bleManager setConnectedPeripheral:peripheral forKey:macAddress];
        [self.bleManager discoverServices:nil forPeripheralWithKey:macAddress];
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
discoveredServicesForPeripheralNamed:(NSString *)peripheralName
{
    [self.bleManager discoverServicesForPeripheralKey:peripheralName.macAddress];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
discoveredCharacteristicsForService:(CBService *)service
         forPeripheralNamed:(NSString *)peripheralName
{
    [self.bleManager discoverCharacteristicsForService:service
                                      forPeripheralKey:peripheralName.macAddress];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
           removePeripheral:(SEBLEPeripheral *)peripheral
{
    
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
          updatedPeripheralNamed:(NSString *)peripheralName
      forCharacteristicUUID:(NSString *)uuid
                   withData:(NSData *)data
{
    NSString *macAddress = peripheralName.macAddress;
    if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo]]) {
        [self handleHardwareServiceForMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet]]) {
        [self handleMagnetForLockMacAddress:macAddress data:data];
    } else if([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLock]]) {
        [self handleLockStateForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer]]) {
        [self handleAccelerometerForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState]]) {
        [self handleSecurityStateUpdateForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]]) {
        [self handleChallengeDataForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLed]]) {
        [self handleLEDStateForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicButtonLockSequence]]) {
        [self handleLockSequenceWriteForMacAddress:macAddress data:data];
    } else {
        char *bytes = (char *)data.bytes;
        NSLog(@"update for %@", uuid);
        for (int i=0; i < data.length; i++) {
            int byte = bytes[i];
            NSLog(@"byte # %d:%d",i, byte);
        }
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
wroteValueToPeripheralNamed:(NSString *)peripheralName
                    forUUID:(NSString *)uuid
           withWriteSuccess:(BOOL)success
{
    NSString *macAddress = peripheralName.macAddress;
    if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLock]]) {
        [self.bleManager readValueForPeripheralWithKey:macAddress
                                        forServiceUUID:[self uuidForService:SLLockManagerServiceHardware]
                                 andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicLock]];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLed]]) {
        [self.bleManager readValueForPeripheralWithKey:macAddress
                                        forServiceUUID:[self uuidForService:SLLockManagerServiceHardware]
                                 andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicLed]];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicButtonLockSequence]]) {
        [self readButtonLockSequenceForLock:self.selectedLock];
    }
}

- (void)bleInterfaceManagerIsPoweredOn:(SEBLEInterfaceMangager *)interfaceManager
{
    NSLog(@"blue tooth manager powered on");
    self.bleIsPoweredOn = YES;
    
    SLUser *user = [self.databaseManger currentUser];
    if (user && user.locks.count > 0) {
        self.shouldSearch = YES;
        [self.bleManager startScan];
    }
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
disconnectedPeripheralNamed:(NSString *)peripheralName
{
    NSString *macAddress = peripheralName.macAddress;
    [self removeLockWithMacAddress:macAddress];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDisconnectedLock
                                                        object:@{@"lockName":macAddress}];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
                 peripheralName:(NSString *)peripheralName
changedUpdateStateForCharacteristic:(NSString *)characteristicUUID
{
    if ([characteristicUUID isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState]]) {
        NSString *macAddress = peripheralName.macAddress;
        if (self.lockConnectionPhases[macAddress]) {
            NSNumber *phaseNumber = self.lockConnectionPhases[macAddress];
            SLLockManagerConnectionPhase phase = (SLLockManagerConnectionPhase)phaseNumber.unsignedIntegerValue;
            switch (phase) {
                case SLLockManagerConnectionPhasePublicKey:
                    [self handlePublicKeyConnectionPhase:macAddress];
                    break;
                case SLLockManagerConnectionPhaseChallengeKey:
                    [self handleChallengeKeyConnectionPhase:macAddress];
                    break;
                case SLLockManagerConnectionPhaseSignedMessage:
                    [self handleSignedMessageConnectionPhase:macAddress];
                    break;
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
    NSLog(@"%@ updated mean values: %@", lockValue.getMacAddress, meanValues);
    SLLock *lock = self.locks[lockValue.getMacAddress];
    if (lockValue == self.lockValues[@(SLLockManagerValueServiceAccelerometer)]) {
        [lock updateAccelerometerValues:meanValues];
        [SLNotificationManager.sharedManager checkIfLockNeedsNotification:lock];
    } else {
        [lock updateProperties:meanValues];
        [self checkAutoUnlockForLock:lock];
    }
}

@end
