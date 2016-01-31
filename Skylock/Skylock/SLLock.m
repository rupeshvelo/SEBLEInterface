//
//  SLLock.m
//  Skylock
//
//  Created by Andre Green on 1/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLLock.h"
#import "SLDbLockSharedContact.h"
#import "SLUser.h"
#import "SLAccelerometerValues.h"


@implementation SLLock

@dynamic batteryVoltage;
@dynamic wifiStrength;
@dynamic cellStrength;
@dynamic lastTime;
@dynamic distanceAway;
@dynamic rssiStrength;
@dynamic isLocked;
@dynamic isCrashOn;
@dynamic isSharingOn;
@dynamic isSecurityOn;
@dynamic temperature;
@dynamic accelerometerVales;

- (void)updateProperties:(NSDictionary *)dictionary
{
    if (dictionary[@"batteryVoltage"]) {
        self.batteryVoltage = dictionary[@"batteryVoltage"];
    }
    
    if (dictionary[@"wifiStrength"]) {
        self.batteryVoltage = dictionary[@"wifiStrength"];
    }
    
    if (dictionary[@"cellStrength"]) {
        self.batteryVoltage = dictionary[@"cellStrength"];
    }
    
    if (dictionary[@"lastTime"]) {
        self.batteryVoltage = dictionary[@"lastTime"];
    }
    
    if (dictionary[@"distanceAway"]) {
        self.distanceAway = dictionary[@"distanceAway"];
    }
    
    if (dictionary[@"rssiStrength"]) {
        self.distanceAway = dictionary[@"rssiStrength"];
    }
    
    if (dictionary[@"isLocked"]) {
        self.distanceAway = dictionary[@"isLocked"];
    }
    
    if (dictionary[@"isCrashOn"]) {
        self.distanceAway = dictionary[@"isCrashOn"];
    }
    
    if (dictionary[@"isSharingOn"]) {
        self.distanceAway = dictionary[@"isSharingOn"];
    }
    
    if (dictionary[@"isSecurityOn"]) {
        self.distanceAway = dictionary[@"isSecurityOn"];
    }
    
    if (dictionary[@"temperature"]) {
        self.distanceAway = dictionary[@"temperature"];
    }
    
    if (dictionary[@"accelerometerVales"]) {
        self.distanceAway = dictionary[@"accelerometerVales"];
    }
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
    if (self.batteryVoltage.floatValue > 0.0 && self.batteryVoltage.floatValue <= 10.0) {
        batState = SLLockBatteryState1;
    } else if (self.batteryVoltage.floatValue > 25.0 && self.batteryVoltage.floatValue <= 33.0) {
        batState = SLLockBatteryState2;
    } else if (self.batteryVoltage.floatValue > 33.0 && self.batteryVoltage.floatValue <= 50.0) {
        batState = SLLockBatteryState3;
    } else if (self.batteryVoltage.floatValue > 50.0 && self.batteryVoltage.floatValue <= 66.0) {
        batState = SLLockBatteryState4;
    } else if (self.batteryVoltage.floatValue > 66.0 && self.batteryVoltage.floatValue <= 75.0) {
        batState = SLLockBatteryState5;
    } else if (self.batteryVoltage.floatValue > 75.0 && self.batteryVoltage.floatValue <= 100.0) {
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

- (NSDictionary *)asDictionary
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *db = @{@"name":self.name,
                         @"uuid":self.uuid,
                         @"latitude":self.latitude,
                         @"longitude":self.longitude,
                         @"isCurrentLock":self.isCurrentLock
                         };
    return db;
}


- (void)updateAccelerometerValues:(NSDictionary *)dictionary
{
    if (!self.accelerometerVales) {
        self.accelerometerVales = [SLAccelerometerValues accelerometerValuesWithValues:dictionary];
    } else {
        [self.accelerometerVales setValues:dictionary];
    }
}

- (NSString *)displayName
{
    static NSInteger maxLength = 8;
    if (self.name.length <= maxLength) {
        return self.name;
    }
    
    return [self.name substringToIndex:maxLength];
}

- (NSString *)macAddress
{
    NSArray *parts;
    if (self.isInFactoryMode) {
        parts = [self.name componentsSeparatedByString:@"-"];
    } else {
        parts = [self.name componentsSeparatedByString:@" "];
    }
    
    return parts[1];
}

- (BOOL)isInFactoryMode
{
    return [self.name rangeOfString:@"-"].location != NSNotFound;
}

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

@end
