//
//  SLLock.m
//  Skylock
//
//  Created by Andre Green on 6/17/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLock.h"
// stadlib.h just here for testing...remove when shipping app
#include <stdlib.h>

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

- (id)initTestWithName:(NSString *)name
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
    self = [self  initWithName:name
                          uuid:uuid
              batteryRemaining:batteryRemaining
                  wifiStrength:wifiStrength
                  cellStrength:cellStrength
                      lastTime:lastTime
                  distanceAway:distanceAway
                      isLocked:isLocked
                     isCrashOn:isCrashOn
                   isSharingOn:isSharingOn
                  isSecurityOn:isSecurityOn
                      latitude:latitude
                     longitude:longitude];
    if (self) {
        NSDictionary *location = self.testLocation;
        _latitude = location[@"latitude"];
        _longitude = location[@"longitude"];
    }
    
    return self;
}

+ (id)lockWithName:(NSString *)name uuid:(NSString *)uuid;
{
    return  [[self alloc] initTestWithName:name
                                      uuid:uuid
                          batteryRemaining:@(67)
                              wifiStrength:@(40)
                              cellStrength:@(34)
                                  lastTime:@(0)
                              distanceAway:@(0)
                                  isLocked:@(NO)
                                 isCrashOn:@(NO)
                               isSharingOn:@(NO)
                              isSecurityOn:@(NO)
                                  latitude:@(0)
                                 longitude:@(0)];
}

+ (id)lockWithDbDictionary:(NSDictionary *)dbDictionary
{
    return [[self alloc] initTestWithName:dbDictionary[@"name"]
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

- (NSDictionary *)testLocation
{
    int target = arc4random() % 4;
    NSNumber *latitude;
    NSNumber *longitude;
    
    switch (target) {
        case 0:
            latitude = @(37.767895);
            longitude = @(-122.453178);
            break;
        case 1:
            latitude = @(37.794550);
            longitude = @(-122.427877);
            break;
        case 2:
            latitude = @(37.752481);
            longitude = @(-122.427877);
        case 3:
            latitude = @(37.778368);
            longitude = @(-122.485277);
        default:
            break;
    }
    
    return @{@"latitude":latitude,
             @"longitude":longitude
             };
}
@end
