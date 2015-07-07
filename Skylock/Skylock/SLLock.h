//
//  SLLock.h
//  Skylock
//
//  Created by Andre Green on 6/17/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLLockBatteryState) {
    SLLockBatteryStateNone,
    SLLockBatteryState1,
    SLLockBatteryState2,
    SLLockBatteryState3,
    SLLockBatteryState4,
    SLLockBatteryState5
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
    SLLockPropertyLockId,
    SLLockPropertyName,
    SLLockPropertyUUID,
    SLLockPropertyBatteryRemaining,
    SLLockPropertyWifiStrength,
    SLLockPropertyCellStrength,
    SLLockPropertyLastTime,
    SLLockPropertyDistanceAway,
    SLLockPropertyIsLocked,
    SLLockPropertyIsCrashOn,
    SLLockPropertyIsSharingOn,
    SLLockPropertyIsSecurityOn,
    SLLockPropertyLatitude,
    SLLockPropertyLongitude
};

@interface SLLock : NSObject

@property (nonatomic, copy) NSNumber *lockId;
@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *batteryRemaining;
@property (nonatomic, copy) NSNumber *wifiStrength;
@property (nonatomic, copy) NSNumber *cellStrength;
@property (nonatomic, copy) NSNumber *lastTime;
@property (nonatomic, copy) NSNumber *distanceAway;
@property (nonatomic, copy) NSNumber *isLocked;
@property (nonatomic, copy) NSNumber *isCrashOn;
@property (nonatomic, copy) NSNumber *isSharingOn;
@property (nonatomic, copy) NSNumber *isSecurityOn;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;

- (id)initWithName:(NSString *)name
              UUID:(NSString *)UUID
  batteryRemaining:(NSNumber *)batteryRemaining
      wifiStrength:(NSNumber *)wifiStrength
      cellStrength:(NSNumber *)cellStrength
          lastTime:(NSNumber *)lastTime
      distanceAway:(NSNumber *)distanceAway
          isLocked:(NSNumber *)isLocked
         isCrashOn:(NSNumber *)isCrashOn
       isSharingOn:(NSNumber *)isSharingOn
      isSecurityOn:(NSNumber *)isSecurityOn;

+ (id)lockWithName:(NSString *)name UUID:(NSString *)UUID;
+ (id)lockWithDataBaseDictionary:(NSDictionary *)dictionary;
- (SLLockBatteryState)batteryState;
- (SLLockCellSignalState)cellSignalState;
- (SLLockWifiSignalState)wifiState;
- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)asDbDictionary;
- (NSArray *)valuesForDbColumns;
@end
