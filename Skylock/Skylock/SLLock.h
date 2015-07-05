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
    SLLockPropertyName,
    SLLockPropertyLockId,
    SLLockPropertyBatteryRemaining,
    SLLockPropertyWifiStrength,
    SLLockPropertyCellStrength,
    SLLockPropertyLastTime,
    SLLockPropertyDistanceAway,
    SLLockPropertyIsLocked,
    SLLockPropertyIsCrashOn,
    SLLockPropertyIsSharingOn,
    SLLockPropertyIsSecurityOn
};

@interface SLLock : NSObject

@property (nonatomic, copy) NSString *lockId;
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


- (id)initWithName:(NSString *)name
            lockId:(NSString *)lockId
  batteryRemaining:(NSNumber *)batteryRemaining
      wifiStrength:(NSNumber *)wifiStrength
      cellStrength:(NSNumber *)cellStrength
          lastTime:(NSNumber *)lastTime
      distanceAway:(NSNumber *)distanceAway
          isLocked:(NSNumber *)isLocked
         isCrashOn:(NSNumber *)isCrashOn
       isSharingOn:(NSNumber *)isSharingOn
      isSecurityOn:(NSNumber *)isSecurityOn;

+ (id)lockWithName:(NSString *)name lockId:(NSString *)lockId;
- (SLLockBatteryState)batteryState;
- (SLLockCellSignalState)cellSignalState;
- (SLLockWifiSignalState)wifiState;
- (NSDictionary *)dictionaryRepresentation;

@end
