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

@synthesize isShallowConnection;
@synthesize batteryVoltage;
@synthesize wifiStrength;
@synthesize cellStrength;
@synthesize lastTime;
@synthesize distanceAway;
@synthesize rssiStrength;
@synthesize isLocked;
@synthesize temperature;
@synthesize accelerometerVales;

- (void)setInitialProperties:(NSDictionary *)dictionary
{
    self.batteryVoltage = dictionary[@"batteryVoltage"] ? dictionary[@"batteryVoltage"] : @(0);
    self.wifiStrength = dictionary[@"wifiStrength"] ? dictionary[@"wifiStrength"] : @(0);
    self.cellStrength = dictionary[@"cellStrength"] ? dictionary[@"cellStrength"] : @(0);
    self.lastTime = dictionary[@"lastTime"] ? dictionary[@"lastTime"] : @(0);
    self.distanceAway = dictionary[@"distanceAway"] ? dictionary[@"distanceAway"] : @(0);
    self.rssiStrength = dictionary[@"rssiStrength"] ? dictionary[@"rssiStrength"] : @(0);
    self.temperature = dictionary[@"temperature"] ? dictionary[@"temperature"] : @(0);
    self.isLocked = dictionary[@"isLocked"] ? dictionary[@"isLocked"] : @(NO);
    self.isShallowConnection = dictionary[@"isShallowConnection"] ? dictionary[@"isShallowConnection"] : @(NO);
}

- (void)updateProperties:(NSDictionary *)dictionary
{
    if (dictionary[@"batteryVoltage"]) {
        self.batteryVoltage = dictionary[@"batteryVoltage"];
    }
    
    if (dictionary[@"wifiStrength"]) {
        self.wifiStrength = dictionary[@"wifiStrength"];
    }
    
    if (dictionary[@"cellStrength"]) {
        self.cellStrength = dictionary[@"cellStrength"];
    }
    
    if (dictionary[@"lastTime"]) {
        self.lastTime = dictionary[@"lastTime"];
    }
    
    if (dictionary[@"distanceAway"]) {
        self.distanceAway = dictionary[@"distanceAway"];
    }
    
    if (dictionary[@"rssiStrength"]) {
        self.rssiStrength = dictionary[@"rssiStrength"];
    }
    
    if (dictionary[@"isLocked"]) {
        self.isLocked = dictionary[@"isLocked"];
    }
    
    if (dictionary[@"temperature"]) {
        self.temperature = dictionary[@"temperature"];
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

- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary
{
    if (dictionary[@"name"]) {
        self.name = dictionary[@"name"];
    }
    
    if (dictionary[@"uuid"]) {
        self.uuid = dictionary[@"uuid"];
    }
    
    if (dictionary[@"latitude"]) {
        self.latitude = dictionary[@"latitude"];
    }
    
    if (dictionary[@"longitude"]) {
        self.longitude = dictionary[@"longitude"];
    }
    
    if (dictionary[@"isCurrentLock"]) {
        self.isCurrentLock = dictionary[@"isCurrentLock"];
    }
    
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
    if (self.givenName && self.givenName.length > 0) {
        return self.givenName;
    }
    
    if (self.name) {
        return self.name;
    }
    
    return @"";
}

- (BOOL)isInFactoryMode
{
    return [self.name rangeOfString:@"-"].location != NSNotFound;
}

- (CLLocationCoordinate2D)location
{
    return CLLocationCoordinate2DMake(self.latitude.doubleValue, self.longitude.doubleValue);
}

- (void)setCurrentLocation:(CLLocationCoordinate2D)location
{
    self.latitude = @(location.latitude);
    self.longitude = @(location.longitude);
}

- (void)switchLockNameToProvisioned
{
    if (!self.isInFactoryMode) {
        return;
    }
    
    NSArray *parts = [self.name componentsSeparatedByString:@"-"];
    self.name = [NSString stringWithFormat:@"%@ %@", parts[0], parts[1]];
}

@end
