//
//  SLLock.h
//  Skylock
//
//  Created by Andre Green on 6/17/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SLLock;
@class SLAccelerometerValues;

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

typedef NS_ENUM(NSUInteger, SLLockProperty) {
    SLLockPropertyName,
    SLLockPropertyUUID,
    SLLockPropertyBatteryVoltage,
    SLLockPropertyWifiStrength,
    SLLockPropertyCellStrength,
    SLLockPropertyLastTime,
    SLLockPropertyDistanceAway,
    SLLockPropertyRSSIStrength,
    SLLockPropertyIsLocked,
    SLLockPropertyIsCrashOn,
    SLLockPropertyIsSharingOn,
    SLLockPropertyIsSecurityOn,
    SLLockPropertyLatitude,
    SLLockPropertyLongitude,
    SLLockPropertyTemperature,
    SLLockPropertyAccelerometerValues
};



@interface SLLock : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *name;
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
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSNumber *temperature;
@property (nonatomic, strong) SLAccelerometerValues *accelerometerVales;

- (id)initWithName:(NSString *)name
              uuid:(NSString *)uuid
    batteryVoltage:(NSNumber *)batteryVoltage
      wifiStrength:(NSNumber *)wifiStrength
      cellStrength:(NSNumber *)cellStrength
          lastTime:(NSNumber *)lastTime
      distanceAway:(NSNumber *)distanceAway
      rssiStrength:(NSNumber *)rssiStrength
          isLocked:(NSNumber *)isLocked
         isCrashOn:(NSNumber *)isCrashOn
       isSharingOn:(NSNumber *)isSharingOn
      isSecurityOn:(NSNumber *)isSecurityOn
          latitude:(NSNumber *)latitude
         longitude:(NSNumber *)longitude;

+ (id)lockWithName:(NSString *)name uuid:(NSString *)uuid;
+ (id)lockWithDbDictionary:(NSDictionary *)dbDictionary;
- (SLLockBatteryState)batteryState;
- (SLLockCellSignalState)cellSignalState;
- (SLLockWifiSignalState)wifiState;
- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)asDbDictionary;
- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary;
- (void)updateAccelerometerValues:(NSDictionary *)dictionary;
- (NSString *)displayName;

@end
