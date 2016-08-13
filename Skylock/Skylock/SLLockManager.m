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
#import "Ellipse-Swift.h"
#import <Security/Security.h>
#import "SLUserDefaults.h"
#import "SLUser.h"
#import <CommonCrypto/CommonHMAC.h>

#define kSLLockNameEllipse  @"ellipse"
#define kSLLockNameSkylock  @"skylock"
#define kSLLockNameSkyboot  @"skyboot"
#define kSLLockNameEllboot  @"ellboot"

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
    SLLockManagerCharacteristicResetLock,
    SLLockManagerCharacteristicCommandStatus,
    SLLockManagerCharacteristicWriteFirware,
    SLLockManagerCharacteristicFirmwareUpdateDone,
    SLLockManagerCharacteristicSerialNumber
};

typedef NS_ENUM(NSUInteger, SLLockManagerCharacteristicState) {
    SLLockManagerCharacteristicStateNone,
    SLLockManagerCharacteristicStateLedOn,
    SLLockManagerCharacteristicStateLedOff,
    SLLockManagerCharacteristicStateOpenLock,
    SLLockManagerCharacteristicStateCloseLock
};

typedef NS_ENUM(NSUInteger, SLLockManagerConnectionPhase) {
    SLLockManagerConnectionPhaseNone,
    SLLockManagerConnectionPhasePublicKey,
    SLLockManagerConnectionPhaseChallengeKey,
    SLLockManagerConnectionPhaseChallengeData,
    SLLockManagerConnectionPhaseSignedMessage,
    SLLockManagerConnectionPhaseConnected
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
    SLLockManagerValueResetLock         = 0xBC,
    SLLockManagerValueBootMode          = 0xBB
} SLLockMangerValue;

typedef NS_ENUM(NSUInteger, SLLockManagerValueService) {
    SLLockManagerValueServiceAccelerometer,
    SLLockManagerValueServiceHardware,
};

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, strong) SLDatabaseManager *databaseManger;
@property (nonatomic, assign) BOOL bleIsPoweredOn;
@property (nonatomic, strong) NSTimer *harwareTimer;
@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) NSMutableDictionary *lockValues;
@property (nonatomic, strong) NSMutableSet *namesToConnect;
@property (nonatomic, assign) SLLockManagerConnectionPhase currentConnectionPhase;
@property (nonatomic, assign) BOOL shouldEnterActiveSearch;
@property (nonatomic, strong) SLKeychainHandler *keychainHandler;
@property (nonatomic, strong) NSMutableArray *locksFoundInActiveSearch;
@property (nonatomic, strong) NSMutableDictionary *notConnectPeripherals;
@property (nonatomic, strong) NSMutableSet *addressesToPermenantlyDelete;
@property (nonatomic, strong) NSMutableArray *firmware;
@property (nonatomic, assign) BOOL isInBootMode;
@property (nonatomic, assign) NSUInteger firmwareMaxCount;

// testing
@property (nonatomic, strong) NSArray *testLocks;

@end

@implementation SLLockManager

- (id)init
{
    self = [super init];
    if (self) {
        _locks                          = [NSMutableDictionary new];
        _lockValues                     = [NSMutableDictionary new];
        _namesToConnect                 = [NSMutableSet new];
        _databaseManger                 = [SLDatabaseManager sharedManager];
        _keychainHandler                = [SLKeychainHandler new];
        _bleIsPoweredOn                 = NO;
        _shouldEnterActiveSearch        = NO;
        _isInBootMode                   = NO;
        _currentConnectionPhase         = SLLockManagerConnectionPhaseNone;
        _locksFoundInActiveSearch       = [NSMutableArray new];
        _notConnectPeripherals          = [NSMutableDictionary new];
        _addressesToPermenantlyDelete   = [NSMutableSet new];
        _firmware                       = [NSMutableArray new];
        _firmwareMaxCount               = 0;
    }
    
    return self;
}

- (SEBLEInterfaceMangager *)bleManager
{
    if (!_bleManager) {
        _bleManager = [SEBLEInterfaceMangager sharedManager];
        _bleManager.delegate = self;
    }
    
    return _bleManager;
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
    return @[kSLLockNameSkylock,
             kSLLockNameEllipse,
             kSLLockNameEllboot,
             kSLLockNameSkyboot];
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
                           [self uuidForCharacteristic:SLLockManagerCharacteristicButtonLockSequence],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicResetLock],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicCommandStatus],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicWriteFirware],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicFirmwareUpdateDone],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicTXPowerControl],
                           [self uuidForCharacteristic:SLLockManagerCharacteristicSerialNumber]
                           ];
    
    return [NSSet setWithArray:readChars];
}

- (NSSet *)charcteristicsToNotify
{
    NSArray *notifyChars = @[[self uuidForCharacteristic:SLLockManagerCharacteristicMagnet],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicAccelerometer],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState],
                             [self uuidForCharacteristic:SLLockManagerCharacteristicCommandStatus]
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
    self.selectedLock.lastConnected = [NSDate date];
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
    } else if (self.selectedLock && [self.selectedLock.macAddress isEqualToString:lock.macAddress]) {
        [self connectLock:lock];
    } else if (!self.selectedLock) {
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
    self.currentConnectionPhase = lock.isInFactoryMode ?
    SLLockManagerConnectionPhasePublicKey : SLLockManagerConnectionPhaseSignedMessage;
    
    self.locks[lock.macAddress] = lock;
    [self.bleManager addPeripheralWithKey:lock.macAddress];
    
    if (!lock.isShallowConnection.boolValue) {
        [self saveLockToDatabase:lock];
        
        [self.databaseManger saveLogEntry:[NSString stringWithFormat:@"Connecting lock: %@", lock.name]];
        [self.databaseManger saveLockConnectedDate:lock];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerStartedConnectingLock
                                                            object:lock];
    }
}

- (void)permenantlyRemoveLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    if (self.locks[lock.macAddress]) {
        // Lock is a current lock that the user is connected to
        [self.addressesToPermenantlyDelete addObject:lock.macAddress];
        [self.bleManager removePeripheralForKey:lock.macAddress];
    } else {
        NSArray *dbLocks = [self.databaseManger locksForCurrentUser];
        for (SLLock *dbLock in dbLocks) {
            if ([dbLock.macAddress isEqualToString:lock.macAddress]) {
                [self.databaseManger deleteLock:dbLock withCompletion:^(BOOL success) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDisconnectedLock
                                                                        object:dbLock.macAddress];
                }];
                break;
            }
        }
    }
}

- (void)removeUnconnectedLocks
{
    [self.bleManager removeNotConnectPeripherals];
}

- (void)removeAllShallowConnectedLocks
{
    
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

- (void)updateLock:(SLLock *)lock withValues:(NSDictionary *)values
{
    [lock updateProperties:values];
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

- (BOOL)isScanning
{
    return self.bleManager.isCurrentlyScanning;
}

- (BOOL)isBlePoweredOn
{
    return self.bleIsPoweredOn;
}

- (NSArray *)locksDiscoveredInSearch
{
    return self.locksFoundInActiveSearch;
}

- (void)clearAvaliableLocks
{
    [self.locksFoundInActiveSearch removeAllObjects];
    [self.notConnectPeripherals removeAllObjects];
}

- (void)startBlueToothManager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    [SLDatabaseManager.sharedManager saveLogEntry:
     [NSString stringWithFormat:@"Starting bluetooth manager"]];
    
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
    if (self.selectedLock && !self.isInBootMode) {
        [self.bleManager readValueForPeripheralWithKey:self.selectedLock.macAddress
                                        forServiceUUID:[self uuidForService:SLLockManagerServiceHardware]
                                 andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo]];
    }
}

- (void)shouldEnterActiveSearchMode:(BOOL)shouldSearch
{
    self.shouldEnterActiveSearch = shouldSearch;
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
}

- (void)toggleTheftForLock:(SLLock *)lock
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
        NSLog(@"saving lock: %@ was a %@", lock.name, success ? @"success":@"failure");
    }];
}

- (NSArray *)unconnectedLocksForCurrentUser
{
    NSArray *locks = [self.databaseManger locksForCurrentUser];
    if (!self.selectedLock) {
        return locks;
    }
    
    NSMutableArray *unconnectedLocks = [NSMutableArray new];
    for (SLLock *dbLock in locks) {
        if (![self.selectedLock.macAddress isEqualToString:dbLock.macAddress]) {
            [unconnectedLocks addObject:dbLock];
        }
    }
    
    return unconnectedLocks;
}

- (NSArray *)allLocksForCurrentUser
{
    return [self.databaseManger locksForCurrentUser];
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
            characteristicString = @"5E46";
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
        case SLLockManagerCharacteristicWriteFirware:
            characteristicString = @"5D02";
            break;
        case SLLockManagerCharacteristicFirmwareUpdateDone:
            characteristicString = @"5D04";
            break;
        case SLLockManagerCharacteristicButtonLockSequence:
            characteristicString = @"5E84";
            break;
        case SLLockManagerCharacteristicResetLock:
            characteristicString = @"5E81";
            break;
        case SLLockManagerCharacteristicCommandStatus:
            characteristicString = @"5E05";
            break;
        case SLLockManagerCharacteristicSerialNumber:
            characteristicString = @"5E83";
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

- (void)checkLockOpenOrClosed
{
    if (!self.selectedLock) {
        return;
    }
    
    [self readValueFromPeripheralForMacAddress:self.selectedLock.macAddress
                                       service:SLLockManagerServiceHardware
                                characteristic:SLLockManagerCharacteristicLock];
}

- (void)handleHardwareServiceForMacAddress:(NSString*)macAddress data:(NSData *)data
{
    if (data.length != 13) {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerUpdatedHardwareValues
                                                        object:macAddress];
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
    
    NSDictionary *values = @{@(SLAccelerometerDataXMav):@(xmav),
                             @(SLAccelerometerDataYMav):@(ymav),
                             @(SLAccelerometerDataZMav):@(zmav),
                             @(SLAccelerometerDataXVar):@(xvar),
                             @(SLAccelerometerDataYVar):@(yvar),
                             @(SLAccelerometerDataZVar):@(zvar)
                             };
    
    [self updateValues:values forLockMacAddress:macAddress forValue:SLLockManagerValueServiceAccelerometer];
}

- (void)handleSecurityStateUpdateForLockMacAddress:(NSString *)macAddress
                                              UUID:(NSString *)uuid
                                              data:(NSData *)data
{
    if (data.length != 1) {
        NSLog(@"Error reading security state data. The data should contain 1 bytes but has: %lul bytes",
              (unsigned long)data.length);
        return;
    }
    
//    SLLock *lock;
//    if (self.selectedLock && [self.selectedLock.macAddress isEqualToString:lock.macAddress]) {
//        lock = self.selectedLock;
//    } else {
//        for (SLLock *unaddedLock in self.locksFoundInActiveSearch) {
//            if ([unaddedLock.macAddress isEqualToString:macAddress]) {
//                lock = unaddedLock;
//                break;
//            }
//        }
//    }
//    
//    if (!lock) {
//        NSLog(@"Failed while trying to update security state of an unknown lock %@", macAddress);
//        return;
//    }
//    
//    if (lock.isShallowConnection.boolValue) {
//        NSLog(@"lock %@ is a shallow connetion. Will not read security info", lock.name);
//        [self.notConnectPeripherals removeObjectForKey:lock.macAddress];
//        [self.bleManager removeNotConnectPeripheralForKey:lock.macAddress];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerShallowlyConnectedLock
//                                                            object:lock];
//        return;
//    }
    
    SLLock *lock = self.selectedLock;
    
    u_int8_t *bytes = (u_int8_t *)data.bytes;
    u_int8_t value = bytes[0];
    
    NSLog(@"handle secturity state update has value of %@ for phase %@", @(value), @(self.currentConnectionPhase));
    
    if (value == 130) {
        NSLog(@"Got lock error message. Should notify user here.");
        return;
    }
    
    if (value != 0 && value != 1 && value != 2 && value != 3 && value != 4) {
        NSLog(@"Error: updating security state got value: %@", @(value));
        [SLDatabaseManager.sharedManager saveLogEntry:
         [NSString stringWithFormat:@"Error: updating security state got value: %@", @(value)]];
        [self disconnectFromLockWithAddress:lock.macAddress];
        return;
    }
    
    
    if (value == 0) {
        if (self.currentConnectionPhase == SLLockManagerConnectionPhaseChallengeKey) {
            self.currentConnectionPhase = SLLockManagerConnectionPhaseSignedMessage;
            [self handleChallengeKeyConnectionPhase:macAddress];
        } else if (self.currentConnectionPhase == SLLockManagerConnectionPhaseSignedMessage) {
            // TODO update current connection phase for this case
            [self handleSignedMessageConnectionPhase:macAddress];
        } else {
            NSLog(@"handle security state has value of %@ but the phase %@ is not correct",
                  @(value),
                  @(self.currentConnectionPhase));
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
    
    if (lock.isInFactoryMode) {
        NSLog(@"lock name before saving: %@", lock.macAddress);
        [lock switchLockNameToProvisioned];
        NSLog(@"lock name after switching name: %@", lock.name);
        [self.databaseManger saveLockToDb:lock withCompletion:nil];
        
        [self.bleManager updateConnectPeripheralKey:macAddress
                                             newKey:lock.macAddress];
    }
    
    if (self.currentConnectionPhase == SLLockManagerConnectionPhaseConnected) {
        [self handleCommandStatusUpdate:macAddress data:data];
    } else {
        self.currentConnectionPhase = SLLockManagerConnectionPhaseConnected;
        
        [self.bleManager stopScan];
        [self setCurrentLock:lock];
        
        [self checkCommandStatusForLockWithMacAddress:macAddress];
        [self setTxMaxPower];
        [self flashLEDs];
        
//        SLUser *user = [SLDatabaseManager.sharedManager currentUser];
//        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(37.358727, -120.618269);
//        [lock setCurrentLocation:location];
//        [self.databaseManger saveLock:lock];
        
        [self.bleManager readValueForPeripheralWithKey:lock.macAddress
                                        forServiceUUID:[self uuidForService:SLLockManagerServiceHardware]
                                 andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicHardwareInfo]];
        
        [NSNotificationCenter.defaultCenter postNotificationName:kSLNotificationLockPaired
                                                          object:lock];        
    }
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
    
    SLUser *user = [self.databaseManger currentUser];
    NSString *challengeKey = [self.keychainHandler getItemForUsername:user.userId
                                                 additionalSeviceInfo:macAddress
                                                          handlerCase:SLKeychainHandlerCaseChallengeKey];
    
    NSLog(@"challege key length: %@", @(challengeKey.length));
    
    NSData *challengeResult = [self SHA256WithDataString:[NSString stringWithFormat:@"%@%@",
                                                          challengeKey,
                                                          challengeString]];
    
    [self writeToLockWithMacAddress:macAddress
                            service:SLLockManagerServiceSecurity
                     characteristic:SLLockManagerCharacteristicChallengeData
                               data:challengeResult];
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
    SLUser *user = [self.databaseManger currentUser];
    NSString *publicKey = [self.keychainHandler getItemForUsername:user.userId
                                              additionalSeviceInfo:macAddress
                                                       handlerCase:SLKeychainHandlerCasePublicKey];
    
    [self writeToLockWithMacAddress:macAddress
                            service:SLLockManagerServiceSecurity
                     characteristic:SLLockManagerCharacteristicPublicKey
                               data:publicKey.bytesString];
    
    self.currentConnectionPhase = SLLockManagerConnectionPhaseChallengeKey;
}

- (void)handleChallengeKeyConnectionPhase:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];
    SLRestManager *restManager = [SLRestManager sharedManager];
    NSString *token = [self.keychainHandler getItemForUsername:user.userId
                                          additionalSeviceInfo:nil
                                                   handlerCase:SLKeychainHandlerCaseRestToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"challenge_key"];
    [restManager getRequestWithServerKey:SLRestManagerServerKeyMain
                                 pathKey:SLRestManagerPathKeyChallengeKey
                               subRoutes:subRoutes
                       additionalHeaders:additionalHeaders
                              completion:^(NSUInteger status, NSDictionary *responseDict) {
                                  if (!responseDict || !responseDict[@"challenge_key"]) {
                                      // TODO figure out how to handle this gracefully
                                      NSLog(@"Error could not retrieve challenge key from server.");
                                      return;
                                  }
                                  
                                  NSString *challengeKey = responseDict[@"challenge_key"];
                                  [self.keychainHandler setItemForUsername:user.userId
                                                                inputValue:challengeKey
                                                      additionalSeviceInfo:macAddress
                                                               handlerCase:SLKeychainHandlerCaseChallengeKey];
                                  
                                  [self writeToLockWithMacAddress:macAddress
                                                          service:SLLockManagerServiceSecurity
                                                   characteristic:SLLockManagerCharacteristicChallengeKey
                                                             data:challengeKey.bytesString];
                                  
                                  self.currentConnectionPhase = SLLockManagerConnectionPhaseSignedMessage;
                              }];
}

- (void)handleChallengeDataConnectionPhase:(NSString *)lockName challengeString:(NSString *)challengeString
{
    
}

- (void)handleSignedMessageConnectionPhase:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];
    NSString *signedMessage = [self.keychainHandler getItemForUsername:user.userId
                                                  additionalSeviceInfo:macAddress
                                                           handlerCase:SLKeychainHandlerCaseSignedMessage];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                        object:@{@"lock": lock}];
}

- (void)handleLockSequenceWriteForMacAddress:(NSString *)macAddress data:(NSData *)data
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockSequenceWritten
                                                        object:nil];
}

- (void)handleCommandStatusUpdate:(NSString *)macAddress data:(NSData *)data
{
    char *bytes = (char *)data.bytes;
    uint16_t value = bytes[0];
    NSString *message = [NSString stringWithFormat:
                         @"Command status updated/read with value %@", @(value)];
    NSLog(@"%@", message);
    [SLDatabaseManager.sharedManager saveLogEntry:message];
}

- (void)handleReadFirmwareVersion:(NSString *)macAddress data:(NSData *)data
{
    char *bytes = (char *)data.bytes;
    NSLog(@"update for %@", macAddress);
    NSMutableArray *values = [NSMutableArray new];
    for (int i=0; i < data.length; i++) {
        int byte = bytes[i];
        NSLog(@"byte # %d:%d",i, byte);
        [values addObject:@(byte)];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerReadFirmwareVersion
                                                        object:values];
}

- (void)handleReadSerialNumber:(NSString *)macAddress data:(NSData *)data
{
    char *bytes = (char *)data.bytes;
    NSString *serialNumber = [NSString stringWithFormat:@"%s", bytes];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerReadSerialNumber
                                                        object:serialNumber];
}

- (void)readCommandStatusForMacAddress:(NSString *)macAddress
{
    [self.bleManager readValueForPeripheralWithKey:macAddress
                                    forServiceUUID:[self uuidForService:SLLockManagerServiceSecurity]
                             andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicCommandStatus]];
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

- (void)updateFirmwareForCurrentLock
{
    [SLRestManager.sharedManager getRequestWithServerKey:SLRestManagerServerKeyMain
                                                 pathKey:SLRestManagerPathKeyFirmwareUpdate
                                               subRoutes:nil
                                       additionalHeaders:nil
                                              completion:^(NSUInteger status, NSDictionary *responseDict) {
                                                  if (responseDict && responseDict[@"payload"]) {
                                                      NSArray *payload = responseDict[@"payload"];
                                                      [self.firmware removeAllObjects];
                                                      // Doing this in reverse order so on writing to the lock
                                                      // we can just pop the last value off the firmware array.
                                                      // This is an 0(1) vs 0(n) which would be the runtime each
                                                      // time we got an item from the front of the array.
                                                      for (NSDictionary *payloadDict in payload.reverseObjectEnumerator) {
                                                          if (payloadDict[@"boot_loader"]) {
                                                              [self.firmware addObject:payloadDict[@"boot_loader"]];
                                                          }
                                                      }
                                                      
                                                      self.firmwareMaxCount = self.firmware.count;
                                                      [self resetSeletedLockToBootMode];
                                                  }
                                              }];
}

- (void)readSerialNumberForCurrentLock
{
    if (!self.selectedLock) {
        return;
    }
    
    [self.bleManager readValueForPeripheralWithKey:self.selectedLock.macAddress
                                    forServiceUUID:[self uuidForService:SLLockManagerServiceConfiguration]
                             andCharacteristicUUID:[self uuidForCharacteristic:SLLockManagerCharacteristicSerialNumber]];
}

- (void)deleteLockFromCurrentUserAccountWithMacAddress:(NSString *)macAddress
{
    SLUser *user = [self.databaseManger currentUser];
    SLRestManager *restManager = [SLRestManager sharedManager];
    NSString *token = [self.keychainHandler getItemForUsername:user.userId
                                          additionalSeviceInfo:nil
                                                   handlerCase:SLKeychainHandlerCaseRestToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[user.userId, @"deletelock"];
    SLLock *lock = self.locks[macAddress];
    if (!lock) {
        NSArray *dbLocks = [self.databaseManger locksForCurrentUser];
        for (SLLock *dbLock in dbLocks) {
            if ([dbLock.macAddress isEqualToString:macAddress]) {
                lock = dbLock;
                break;
            }
        }
    }
    
    if (!lock) {
        return;
    }
    
    [SLRestManager.sharedManager postObject:@{@"mac_id":lock.macAddress}
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyUsers subRoutes:subRoutes
                          additionalHeaders:additionalHeaders
                                 completion:^(NSUInteger status, NSDictionary *responseDict) {
                                     // TODO the server currently returns an empty payload for this url
                                     // and the server is always returning an error. When that is fixed,
                                     // this should be updated
                                     u_int8_t value = (u_int8_t)SLLockManagerValueResetLock;
                                     NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
                                     
                                     [self writeToLockWithMacAddress:lock.macAddress
                                                             service:SLLockManagerServiceConfiguration
                                                      characteristic:SLLockManagerCharacteristicResetLock
                                                                data:data];
                                     [self permenantlyRemoveLock:lock];
                                 }];
}

- (void)factoryResetCurrentLock
{
    if (!self.selectedLock) {
        return;
    }
    
    u_int8_t value = (u_int8_t)SLLockManagerValueResetLock;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self writeToLockWithMacAddress:self.selectedLock.macAddress
                            service:SLLockManagerServiceConfiguration
                     characteristic:SLLockManagerCharacteristicResetLock
                               data:data];
}

- (void)readFirmwareDataForLockAddress:(NSString *)macAddress
{
    [self readValueFromPeripheralForMacAddress:macAddress
                                       service:SLLockManagerServiceConfiguration
                                characteristic:SLLockManagerCharacteristicCodeVersion];
}

- (void)resetSeletedLockToBootMode
{
    if (!self.selectedLock) {
        return;
    }
    
    self.isInBootMode = YES;
    if (self.selectedLock.isInBootMode) {
        [self handleLockResetWithAddress:self.selectedLock.macAddress success:YES];
    } else {
        u_int8_t value = (u_int8_t)SLLockManagerValueBootMode;
        NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
        
        SLLock *lock = self.locks.allValues[self.locks.count - 1];
        [self writeToLockWithMacAddress:lock.macAddress
                                service:SLLockManagerServiceConfiguration
                         characteristic:SLLockManagerCharacteristicResetLock
                                   data:data];
    }
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
    NSLog(@"%@", self.selectedLock);
    
    if ([self.selectedLock.macAddress isEqualToString:macAddress]) {
        self.selectedLock = nil;
        [self.bleManager startScan];
    }
    
    if (self.locks[macAddress]) {
        [self.locks removeObjectForKey:macAddress];
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

- (void)checkCommandStatusForLockWithMacAddress:(NSString *)macAddress
{
    [self readValueFromPeripheralForMacAddress:macAddress
                                       service:SLLockManagerServiceSecurity
                                characteristic:SLLockManagerCharacteristicCommandStatus];
}

- (void)flashLEDs
{
    if (!self.selectedLock) {
        return;
    }
    
    [self flashLEDsForLock:self.selectedLock];
//    u_int8_t values[4] = {0x01, 0x00, 0x20, 0x20};
//    [self writeToLockWithMacAddress:self.selectedLock.macAddress
//                            service:SLLockManagerServiceHardware
//                     characteristic:SLLockManagerCharacteristicLed
//                               data:[NSData dataWithBytes:&values length:4]];
}

- (void)setTxMaxPower
{
    if (!self.selectedLock) {
        return;
    }
    
    u_int8_t value = (u_int8_t)0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    
    [self writeToLockWithMacAddress:self.selectedLock.macAddress
                            service:SLLockManagerServiceHardware
                     characteristic:SLLockManagerCharacteristicTXPowerControl
                               data:data];
}

- (void)turnLEDsOff:(NSTimer *)timer
{
    NSDictionary *info = timer.userInfo;
    if (!info[@"lock"]) {
        return;
    }
    
    SLLock *lock = info[@"lock"];
    BOOL shouldBlink = NO;
    if ([self.selectedLock.macAddress isEqualToString:lock.macAddress]) {
        shouldBlink = YES;
    } else {
        for (SLLock *unaddedLock in self.locksFoundInActiveSearch) {
            if ([unaddedLock.macAddress isEqualToString:lock.macAddress]) {
                shouldBlink = YES;
                break;
            }
        }
    }
    
    if (shouldBlink) {
        [self writeToLockWithMacAddress:self.selectedLock.macAddress
                                service:SLLockManagerServiceHardware
                         characteristic:SLLockManagerCharacteristicLed
                                 turnOn:NO];
    }
    
    [timer invalidate];
}

- (void)flashLEDsForLock:(SLLock *)lock
{
    [self writeToLockWithMacAddress:lock.macAddress
                            service:SLLockManagerServiceHardware
                     characteristic:SLLockManagerCharacteristicLed
                             turnOn:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(turnLEDsOff:)
                                   userInfo:@{@"lock": lock}
                                    repeats:NO];
}

- (void)connectToSelectedLockWithName:(NSString *)name
{
    SLUser *currentUser = [self.databaseManger currentUser];
    self.selectedLock.name = name;
    [self saveLockToDatabase:self.selectedLock];
    
    if (self.selectedLock.isInFactoryMode) {
        self.currentConnectionPhase = SLLockManagerConnectionPhasePublicKey;
    } else {
        if ([self.keychainHandler getItemForUsername:currentUser.userId
                                additionalSeviceInfo:self.selectedLock.macAddress
                                         handlerCase:SLKeychainHandlerCasePublicKey] &&
            [self.keychainHandler getItemForUsername:currentUser.userId
                                additionalSeviceInfo:self.selectedLock.macAddress
                                         handlerCase:SLKeychainHandlerCaseSignedMessage])
        {
            self.currentConnectionPhase = SLLockManagerConnectionPhaseSignedMessage;
        } else {
            self.currentConnectionPhase = SLLockManagerConnectionPhaseChallengeKey;
        }
    }
    
    SEBLEPeripheral *peripheral = self.notConnectPeripherals[name.macAddress];
    [self.bleManager setNotConnectedPeripheral:peripheral forKey:self.selectedLock.macAddress];
    [self addLock:self.selectedLock];
    
    NSString *message = [NSString stringWithFormat:@"found %@ in database...connecting", self.selectedLock.name];
    NSLog(@"%@", message);
    [self.databaseManger saveLogEntry:message];
    
}

- (BOOL)periphrealIsInBootMode:(NSString *)name
{
    NSString *lowercaseName = name.lowercaseString;
    return ([lowercaseName containsString:kSLLockNameSkyboot] || [lowercaseName containsString:kSLLockNameEllipse]);
}

- (void)foundLockWhileInActiveSearchForName:(NSString *)name
{
    NSString *message = [NSString stringWithFormat:@"In active search mode and will notify that: %@ is nearby",
                         name];
    [self.databaseManger saveLogEntry:message];
    NSLog(@"%@", message);
    
    SEBLEPeripheral *peripheral = self.notConnectPeripherals[name.macAddress];
    SLLock *unaddedLock = [self lockWithName:name CBUUID:peripheral.CBUUIDAsString];
    [self.locksFoundInActiveSearch addObject:unaddedLock];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDiscoverdLock
                                                        object:unaddedLock];
}

- (void)changeCurrentLockGivenNameToName:(NSString *)newName
{
    if (!self.selectedLock || !newName) {
        return;
    }
    
    self.selectedLock.givenName = newName;
    [self.databaseManger saveLock:self.selectedLock];
}

- (void)handleLockResetWithAddress:(NSString *)macAddress success:(BOOL)success
{
    if (!self.locks[macAddress]) {
        NSLog(@"Could not remove lock: %@. It is not in lock manager's locks", macAddress);
        return;
    }
    
    if (self.isInBootMode) {
        NSLog(@"Updating firmware. There are %@ values left to write.", @(self.firmware.count));
        if (self.firmware.count == 0) {
            u_int8_t value = 0x01;
            NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
            [self writeToLockWithMacAddress:macAddress
                                    service:SLLockManagerServiceBoot
                             characteristic:SLLockManagerCharacteristicFirmwareUpdateDone
                                       data:data];
        } else {
            NSString *firmwareString = self.firmware[self.firmware.count - 1];
            [self.firmware removeLastObject];
            NSData *data = firmwareString.bytesString;
            [self writeToLockWithMacAddress:macAddress
                                    service:SLLockManagerServiceBoot
                             characteristic:SLLockManagerCharacteristicWriteFirware
                                       data:data];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerFirmwareUpdateState
                                                                object:@((double)self.firmware.count/(double)self.firmwareMaxCount)];
        }
    } else {
        NSDictionary *info = @{@"macAddress": macAddress,
                               @"succes": @(success)
                               };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationRemoveLockForUser
                                                            object:info];
        
        SLLock *lock = self.locks[macAddress];
        [self permenantlyRemoveLock:lock];
    }    
}

- (void)connectToNewLockNamed:(NSString *)name
{
    SLUser *currentUser = [self.databaseManger currentUser];
    
    SEBLEPeripheral *peripheral = self.notConnectPeripherals[name.macAddress];
    self.selectedLock = [self lockWithName:name CBUUID:peripheral.CBUUIDAsString];
    [self.selectedLock setInitialProperties:@{}];
    self.currentConnectionPhase = self.selectedLock.isInFactoryMode ?
    SLLockManagerConnectionPhaseChallengeKey : SLLockManagerConnectionPhaseSignedMessage;
    
    //[lock setCurrentLocation:currentUser.location];
    [self.bleManager setNotConnectedPeripheral:peripheral forKey:self.selectedLock.macAddress];
    
    SLRestManager *restManager = [SLRestManager sharedManager];
    NSString *token = [self.keychainHandler getItemForUsername:currentUser.userId
                                          additionalSeviceInfo:nil
                                                   handlerCase:SLKeychainHandlerCaseRestToken];
    NSString *authValue = [restManager basicAuthorizationHeaderValueUsername:token password:@""];
    NSDictionary *additionalHeaders = @{@"Authorization": authValue};
    NSArray *subRoutes = @[currentUser.userId, @"keys"];
    NSDictionary *lockData = @{@"mac_id": self.selectedLock.macAddress};
    
    [restManager postObject:lockData
                  serverKey:SLRestManagerServerKeyMain
                    pathKey:SLRestManagerPathKeyKeys
                  subRoutes:subRoutes
          additionalHeaders:additionalHeaders
                 completion:^(NSUInteger status, NSDictionary *responseDict) {
                     NSString *infoMessage;
                     if (responseDict && responseDict[@"signed_message"] &&
                         responseDict[@"public_key"] &&
                         responseDict[@"message"])
                     {
                         [self.keychainHandler setItemForUsername:currentUser.userId
                                                       inputValue:responseDict[@"signed_message"]
                                             additionalSeviceInfo:self.selectedLock.macAddress
                                                      handlerCase:SLKeychainHandlerCaseSignedMessage];
                         [self.keychainHandler setItemForUsername:currentUser.userId
                                                       inputValue:responseDict[@"public_key"]
                                             additionalSeviceInfo:self.selectedLock.macAddress
                                                      handlerCase:SLKeychainHandlerCasePublicKey];
                         
                         infoMessage = [NSString stringWithFormat:@"received signed message and public key from server for: %@",
                                        name];
                         NSLog(@"%@", infoMessage);
                         [SLDatabaseManager.sharedManager saveLogEntry:infoMessage];
                         
                         [self addLock:self.selectedLock];
                     } else {
                         infoMessage = @"Error: failed to retreive keys from server";
                         NSLog(@"%@", infoMessage);
                         [self.databaseManger saveLogEntry:infoMessage];
                     }
                 }];
}

- (void)connectToLockWithName:(NSString *)lockName
{
    NSArray *dbLocks = [self.databaseManger locksForCurrentUser];
    SLLock *lock;
    NSString *macAddress = lockName.macAddress;
    for (SLLock *dbLock in dbLocks) {
        if ([dbLock.macAddress isEqualToString:macAddress]) {
            lock = dbLock;
            break;
        }
    }
    
    if (lock) {
        // TODO: should add a check if the keys for this lock are in the user's keychain
        self.selectedLock = lock;
        [self connectToSelectedLockWithName:self.selectedLock.name];
        return;
    }
    
    [self connectToNewLockNamed:lockName];
}

- (void)shallowConnectLock:(SLLock *)lock
{
    lock.isShallowConnection = @(YES);
    SEBLEPeripheral *peripheral = self.notConnectPeripherals[lock.macAddress];
    [self.bleManager setNotConnectedPeripheral:peripheral forKey:lock.macAddress];
    [self addLock:lock];
}

- (void)disconnectFromLockWithAddress:(NSString *)macAddress
{
    if (!self.locks[macAddress]) {
        return;
    }
    
    if (self.selectedLock && [macAddress isEqualToString:self.selectedLock.macAddress]) {
        [self.databaseManger saveLock:self.selectedLock];
    }
    
    [self.bleManager disconnectFromPeripheralWithKey:macAddress];
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
    [SLDatabaseManager.sharedManager saveLogEntry: [NSString stringWithFormat:@"found peripheral: %@", name]];
    NSString *macAddress = name.macAddress;
    self.notConnectPeripherals[macAddress] = peripheral;
    
    NSArray *dbLocks = self.databaseManger.locksForCurrentUser;
    if (dbLocks.count == 0 && [self name]) {
        
    }
    if (!self.selectedLock) {
        SLLock *currentLock = [self.databaseManger getCurrentLockForCurrentUser];
        if (currentLock) {
            NSLog(@"Current user lock from db is %@, or %@", currentLock.name, currentLock.displayName);
        }
        
        if ([macAddress isEqualToString:currentLock.macAddress]) {
            self.selectedLock = currentLock;
        }
    }
    
    if (self.shouldEnterActiveSearch) {
        [self foundLockWhileInActiveSearchForName:name];
    } else if (self.selectedLock && [macAddress isEqualToString:self.selectedLock.macAddress]) {
        [self.databaseManger saveLogEntry:[NSString stringWithFormat:
                                           @"Current lock is %@. Found peripheral with matching id: %@",
                                           self.selectedLock.name,
                                           name]];
        [self connectToSelectedLockWithName:name];
    } else {
        [self.notConnectPeripherals removeObjectForKey:macAddress];
        [self.databaseManger saveLogEntry:[NSString stringWithFormat:
                                           @"Current lock is %@. Will not connect to %@",
                                           self.selectedLock ? self.selectedLock.name : @"nil",
                                           name]];
    }
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
    
    NSString *serviceUUID = [NSString stringWithFormat:@"%@", service.UUID];
    if ([[self uuidForService:SLLockManagerServiceHardware] isEqualToString:serviceUUID])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationHardwareServiceFound
                                                            object:peripheralName.macAddress];
    } else if ([[self uuidForService:SLLockManagerServiceBoot] isEqualToString:serviceUUID]
               && ([peripheralName.lowercaseString containsString:@"skyboot"] || [peripheralName.lowercaseString containsString:@"ellboot"]))
    {
        self.isInBootMode = YES;
        [self handleLockResetWithAddress:peripheralName.macAddress success:YES];
    }
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
        [self handleSecurityStateUpdateForLockMacAddress:macAddress UUID:uuid data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicChallengeData]]) {
        [self handleChallengeDataForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLed]]) {
        [self handleLEDStateForLockMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicButtonLockSequence]]) {
        [self handleLockSequenceWriteForMacAddress:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicCodeVersion]]) {
        [self handleReadFirmwareVersion:macAddress data:data];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSerialNumber]]) {
        [self handleReadSerialNumber:macAddress data:data];
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
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicResetLock]]) {
        [self handleLockResetWithAddress:macAddress success:success];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicCommandStatus]]) {
        [self handleCommandStatusUpdate:macAddress data:nil];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicWriteFirware]]) {
        [self handleLockResetWithAddress:macAddress success:success];
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicFirmwareUpdateDone]]) {
        self.isInBootMode = NO;
    } else if ([uuid isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicTXPowerControl]]) {
        NSLog(@"Turned power up %@", success ? @"successfully" : @"unseccessfully");
    }
}

- (void)bleInterfaceManagerIsPoweredOn:(SEBLEInterfaceMangager *)interfaceManager
{
    NSLog(@"blue tooth manager powered on");
    self.bleIsPoweredOn = YES;
    
    SLUser *user = [self.databaseManger currentUser];
    if (user) {
        for (SLLock *lock in user.locks.allObjects) {
            NSLog(@"lock %@ is current lock %@", lock.name, lock.isCurrentLock);
            if (lock.isCurrentLock.boolValue) {
                [self.bleManager startScan];
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerBlePoweredOn
                                                        object:nil];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
disconnectedPeripheralNamed:(NSString *)peripheralName
{
    NSLog(@"Disconnected lock: %@", peripheralName);
    NSString *macAddress = peripheralName.macAddress;
    if (!self.locks[macAddress]) {
        NSLog(@"Can't disconnect lock: %@. There is no matching address in locks", macAddress);
        return;
    }
    
    self.shouldEnterActiveSearch = NO;
    
    SLLock *lock = self.locks[macAddress];
    if ([self isLockConnected:lock]) {
        [self.locks removeObjectForKey:lock.macAddress];
    }
    
    if ([self.selectedLock.macAddress isEqualToString:lock.macAddress]) {
        self.selectedLock = nil;
    }
    
    if (![self.addressesToPermenantlyDelete containsObject:lock.macAddress]) {
        NSLog(@"lock: %@ was not set for deletion", lock.macAddress);
        [self startScan];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDisconnectedLock
                                                            object:macAddress];
        return;
    }
    
    [self.addressesToPermenantlyDelete removeObject:lock.macAddress];
    
    if ([self.namesToConnect containsObject:lock.macAddress]) {
        [self.namesToConnect removeObject:lock.macAddress];
        [self.bleManager setDeviceNamesToConnectTo:self.namesToConnect];
    }
    
    [self.databaseManger deleteLock:lock withCompletion:nil];
    
    SLUser *user = [self.databaseManger currentUser];
    [self.keychainHandler deleteItemForUsername:user.userId
                          additionalServiceInfo:lock.macAddress
                                    handlerCase:SLKeychainHandlerCaseChallengeKey];
    
    [self.keychainHandler deleteItemForUsername:user.userId
                          additionalServiceInfo:lock.macAddress
                                    handlerCase:SLKeychainHandlerCasePublicKey];
    
    [self.keychainHandler deleteItemForUsername:user.userId
                          additionalServiceInfo:lock.macAddress
                                    handlerCase:SLKeychainHandlerCaseSignedMessage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerDisconnectedLock
                                                        object:macAddress];
}

- (void)bleInterfaceManager:(SEBLEInterfaceMangager *)interfaceManager
             peripheralName:(NSString *)peripheralName
changedUpdateStateForCharacteristic:(NSString *)characteristicUUID
{
    NSString *macAddress = peripheralName.macAddress;
    if ([characteristicUUID isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicSecurityState]]) {
        switch (self.currentConnectionPhase) {
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
    } else if ([characteristicUUID isEqualToString:[self uuidForCharacteristic:SLLockManagerCharacteristicLock]]) {
        [self checkLockOpenOrClosed];
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationLockManagerUpdatedLock
                                                            object:lockValue.getMacAddress];
    }
}

@end
