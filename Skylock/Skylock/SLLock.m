//
//  SLLock.m
//  Skylock
//
//  Created by Andre Green on 6/17/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLock.h"

@implementation SLLock

- (id)initWithName:(NSString *)name
              uuid:(NSString *)uuid
  batteryRemaining:(NSNumber *)batteryRemaining
      wifiStrength:(NSNumber *)wifiStrength
      cellStrength:(NSNumber *)cellStrength
          lastTime:(NSNumber *)lastTime
      distanceAway:(NSNumber *)distanceAway
          isLocked:(NSNumber *)isLocked
         isCrashOn:(NSNumber *)isCrashOn
       isSharingOn:(NSNumber *)isSharingOn
      isSecurityOn:(NSNumber *)isSecurityOn
          latitude:(NSNumber *)latitude
         longitude:(NSNumber *)longitude
{
    self = [super init];
    if (self) {
        _name               = name;
        _uuid               = uuid;
        _batteryRemaining   = batteryRemaining;
        _wifiStrength       = wifiStrength;
        _cellStrength       = cellStrength;
        _lastTime           = lastTime;
        _distanceAway       = distanceAway;
        _isLocked           = isLocked;
        _isCrashOn          = isCrashOn;
        _isSharingOn        = isSharingOn;
        _isSecurityOn       = isSecurityOn;
        _latitude           = latitude;
        _longitude          = longitude;
    }
    
    return self;
}

+ (id)lockWithName:(NSString *)name uuid:(NSString *)uuid;
{
    return [[self alloc] initWithName:name
                                 uuid:uuid
                     batteryRemaining:@(0)
                         wifiStrength:@(0)
                         cellStrength:@(0)
                             lastTime:@(0)
                         distanceAway:@(0)
                             isLocked:@(NO)
                            isCrashOn:@(NO)
                          isSharingOn:@(NO)
                         isSecurityOn:@(NO)
                             latitude:@(37.761663)
                            longitude:@(-122.422855)];
}

+ (id)lockWithDbDictionary:(NSDictionary *)dbDictionary
{
    return [[self alloc] initWithName:dbDictionary[@"name"]
                                 uuid:dbDictionary[@"uuid"]
                     batteryRemaining:@(87)
                         wifiStrength:@(55)
                         cellStrength:@(98)
                             lastTime:@(0)
                         distanceAway:@(0)
                             isLocked:@(NO)
                            isCrashOn:@(NO)
                          isSharingOn:@(NO)
                         isSecurityOn:@(NO)
                             latitude:dbDictionary[@"latitude"]
                            longitude:dbDictionary[@"longitude"]];
    
}

- (SLLockCellSignalState)cellSignalState
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLockCellSignalState cellState = SLLockCellSignalStateNone;
    if (self.cellStrength.floatValue > 0.0 && self.cellStrength.floatValue <= 20.0) {
        cellState = SLLockCellSignalState1;
    } else if (self.cellStrength.floatValue > 20.0 && self.cellStrength.floatValue <= 40.0) {
        cellState = SLLockCellSignalState2;
    } else if (self.cellStrength.floatValue > 40.0 && self.cellStrength.floatValue <= 60.0) {
        cellState = SLLockCellSignalState3;
    } else if (self.cellStrength.floatValue > 60.0 && self.cellStrength.floatValue <= 80.0) {
        cellState = SLLockCellSignalState4;
    } else if (self.cellStrength.floatValue > 80.0 && self.cellStrength.floatValue <= 100.0) {
        cellState = SLLockCellSignalState5;
    }
    
    return cellState;
}

- (SLLockBatteryState)batteryState
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLockBatteryState batState = SLLockBatteryStateNone;
    if (self.batteryRemaining.floatValue > 0.0 && self.batteryRemaining.floatValue <= 10.0) {
        batState = SLLockBatteryState1;
    } else if (self.batteryRemaining.floatValue > 25.0 && self.batteryRemaining.floatValue <= 33.0) {
        batState = SLLockBatteryState2;
    } else if (self.batteryRemaining.floatValue > 33.0 && self.batteryRemaining.floatValue <= 50.0f) {
        batState = SLLockBatteryState3;
    } else if (self.batteryRemaining.floatValue > 50.0 && self.batteryRemaining.floatValue <= 66.0f) {
        batState = SLLockBatteryState4;
    } else if (self.batteryRemaining.floatValue > 66.0 && self.batteryRemaining.floatValue <= 75.0f) {
        batState = SLLockBatteryState5;
    } else if (self.batteryRemaining.floatValue > 75.0 && self.batteryRemaining.floatValue <= 100.0f) {
        batState = SLLockBatteryState6;
    }
    
    return batState;
}

- (SLLockWifiSignalState)wifiState
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLockWifiSignalState wifiState = SLLockWifiSignalStateNone;
    if (self.wifiStrength.floatValue > 0.0 && self.wifiStrength.floatValue <= 20.0) {
        wifiState = SLLockWifiSignalState1;
    } else if (self.wifiStrength.floatValue > 20.0 && self.wifiStrength.floatValue <= 40.0) {
        wifiState = SLLockWifiSignalState2;
    } else if (self.wifiStrength.floatValue > 40.0 && self.wifiStrength.floatValue <= 60.0f) {
        wifiState = SLLockWifiSignalState3;
    } else if (self.wifiStrength.floatValue > 60.0 && self.wifiStrength.floatValue <= 80.0f) {
        wifiState = SLLockWifiSignalState4;
    } else if (self.wifiStrength.floatValue > 80.0 && self.wifiStrength.floatValue <= 100.0f) {
        wifiState = SLLockWifiSignalState3;
    }
    
    return wifiState;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableDictionary *dictRep = [NSMutableDictionary new];
    for (NSNumber *property in self.propertiesArray) {
        dictRep[property] = [self getPropertyOrNull:property.unsignedIntegerValue];
    }
    
    return dictRep;
}

- (NSDictionary *)asDbDictionary
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *db = @{@"name":self.name,
                         @"uuid":self.uuid,
                         @"latitude":self.latitude,
                         @"longitude":self.longitude
                         };
    return db;
}

- (id)getPropertyOrNull:(SLLockProperty)property
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self valueForKey:[self keyForProperty:property]];
}

- (NSString *)keyForProperty:(SLLockProperty)property
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    switch (property) {
        case SLLockPropertyName:
            return @"name";
            break;
        case SLLockPropertyBatteryRemaining:
            return @"batteryRemaining";
            break;
        case SLLockPropertyWifiStrength:
            return @"wifiStrength";
            break;
        case SLLockPropertyCellStrength:
            return @"cellStrength";
            break;
        case SLLockPropertyLastTime:
            return @"lastTime";
            break;
        case SLLockPropertyDistanceAway:
            return @"distanceAway";
            break;
        case SLLockPropertyIsLocked:
            return @"isLocked";
            break;
        case SLLockPropertyIsCrashOn:
            return @"isCrashOn";
            break;
        case SLLockPropertyIsSharingOn:
            return @"isSharingOn";
            break;
        case SLLockPropertyIsSecurityOn:
            return @"isSecurityOn";
            break;
        case SLLockPropertyLatitude:
            return @"latitude";
            break;
        case SLLockPropertyLongitude:
            return @"longitude";
            break;
        case SLLockPropertyUUID:
            return @"UUID";
            break;
        default:
            return nil;
            break;
    }
}

- (NSArray *)propertiesArray
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return @[@(SLLockPropertyName),
             @(SLLockPropertyUUID),
             @(SLLockPropertyBatteryRemaining),
             @(SLLockPropertyWifiStrength),
             @(SLLockPropertyCellStrength),
             @(SLLockPropertyLastTime),
             @(SLLockPropertyDistanceAway),
             @(SLLockPropertyIsLocked),
             @(SLLockPropertyIsCrashOn),
             @(SLLockPropertyIsSharingOn),
             @(SLLockPropertyIsSecurityOn)
             ];
}
@end
