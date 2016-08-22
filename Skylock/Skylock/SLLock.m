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

#define kSLLockMaxRssiStrength      -50.0f
#define kSLLockMinRssiStrength      -100.f
#define kSLLockMaxBatteryStrength   3500.0f
#define kSLLockMinBatteryStrength   2100.0f

@implementation SLLock

@synthesize isShallowConnection;
@synthesize batteryVoltage;
@synthesize wifiStrength;
@synthesize cellStrength;
@synthesize lastTime;
@synthesize distanceAway;
@synthesize rssiStrength;
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
    
    if (dictionary[@"temperature"]) {
        self.temperature = dictionary[@"temperature"];
    }
}

- (SLLockParameterRange)rangeForParameterType:(SLLockParameterType)type
{
    SLLockParameterRange range;
    if (type == SLLockParameterTypeBattery) {
        if (self.batteryVoltage.floatValue > 3175.0f) {
            range = SLLockParameterRangeFour;
        } else if (self.batteryVoltage.floatValue > 3050.0f) {
            range = SLLockParameterRangeThree;
        } else if (self.batteryVoltage.floatValue > 2925.0f) {
            range = SLLockParameterRangeTwo;
        } else if (self.batteryVoltage.floatValue > 2800.0f) {
            range = SLLockParameterRangeOne;
        } else {
            range = SLLockParameterRangeZero;
        }
    } else {
        if (self.rssiStrength.floatValue > -62.5f) {
            range = SLLockParameterRangeFour;
        } else if (self.rssiStrength.floatValue > -75.0f) {
            range = SLLockParameterRangeThree;
        } else if (self.rssiStrength.floatValue > -82.5f) {
            range = SLLockParameterRangeTwo;
        } else if (self.rssiStrength.floatValue > -100.0f) {
            range = SLLockParameterRangeOne;
        } else {
            range = SLLockParameterRangeZero;
        }
    }

    return range;
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
