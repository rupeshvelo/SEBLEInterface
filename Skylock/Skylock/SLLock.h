//
//  SLLock.h
//  Skylock
//
//  Created by Andre Green on 1/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class SLDbLockSharedContact, SLUser, SLAccelerometerValues;

NS_ASSUME_NONNULL_BEGIN

@interface SLLock : NSManagedObject

typedef NS_ENUM(NSUInteger, SLLockBatteryState) {
    SLLockBatteryStateNone,
    SLLockBatteryState1,
    SLLockBatteryState2,
    SLLockBatteryState3,
    SLLockBatteryState4,
    SLLockBatteryState5,
    SLLockBatteryState6,
    SLLockBatteryState7
};

typedef NS_ENUM(NSUInteger, SLLockCellSignalState) {
    SLLockCellSignalStateNone,
    SLLockCellSignalState1,
    SLLockCellSignalState2,
    SLLockCellSignalState3,
    SLLockCellSignalState4,
    SLLockCellSignalState5
};

typedef NS_ENUM(NSUInteger, SLLockWifiSignalState) {
    SLLockWifiSignalStateNone,
    SLLockWifiSignalState1,
    SLLockWifiSignalState2,
    SLLockWifiSignalState3,
    SLLockWifiSignalState4,
    SLLockWifiSignalState5
};


@property (nonatomic, copy) NSNumber *batteryVoltage;
@property (nonatomic, copy) NSNumber *wifiStrength;
@property (nonatomic, copy) NSNumber *cellStrength;
@property (nonatomic, copy) NSNumber *lastTime;
@property (nonatomic, copy) NSNumber *distanceAway;
@property (nonatomic, copy) NSNumber *rssiStrength;
@property (nonatomic, copy) NSNumber *isLocked;
@property (nonatomic, copy) NSNumber *isCrashOn;
@property (nonatomic, copy) NSNumber *isSharingOn;
@property (nonatomic, copy) NSNumber *isSecurityOn;
@property (nonatomic, copy) NSNumber *temperature;

@property (nonatomic, strong) SLAccelerometerValues *accelerometerVales;


- (SLLockCellSignalState)cellSignalState;
- (SLLockBatteryState)batteryState;
- (SLLockWifiSignalState)wifiState;
- (NSDictionary *)asDictionary;
- (void)updateAccelerometerValues:(NSDictionary *)dictionary;
- (void)setInitialProperties:(NSDictionary *)dictionary;
- (void)updateProperties:(NSDictionary *)dictionary;
- (NSString *)displayName;
- (BOOL)isInFactoryMode;
- (CLLocationCoordinate2D)location;
- (void)setCurrentLocation:(CLLocationCoordinate2D)location;
- (void)switchLockNameToProvisioned;

@end

NS_ASSUME_NONNULL_END

#import "SLLock+CoreDataProperties.h"
