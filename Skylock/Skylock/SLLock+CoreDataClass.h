//
//  SLLock+CoreDataClass.h
//  Ellipse
//
//  Created by Andre Green on 11/27/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class SLDbLockSharedContact, SLUser, SLAccelerometerValues;

NS_ASSUME_NONNULL_BEGIN

@interface SLLock : NSManagedObject

typedef NS_ENUM(NSUInteger, SLLockParameterRange) {
    SLLockParameterRangeZero,
    SLLockParameterRangeOne,
    SLLockParameterRangeTwo,
    SLLockParameterRangeThree,
    SLLockParameterRangeFour,
};

typedef NS_ENUM(NSUInteger, SLLockParameterType) {
    SLLockParameterTypeBattery,
    SLLockParameterTypeRSSI
};

typedef NS_ENUM(NSUInteger, SLLockPosition) {
    SLLockPositionUnlocked = 0,
    SLLockPositionLocked = 1,
    SLLockPositionMiddle = 2,
    SLLockPositionInvalid = 3
};

@property (nonatomic, copy) NSNumber * isShallowConnection;
@property (nonatomic, copy) NSNumber *batteryVoltage;
@property (nonatomic, copy) NSNumber *wifiStrength;
@property (nonatomic, copy) NSNumber *cellStrength;
@property (nonatomic, copy) NSNumber *lastTime;
@property (nonatomic, copy) NSNumber *distanceAway;
@property (nonatomic, copy) NSNumber *rssiStrength;
@property (nonatomic, copy) NSNumber *temperature;
@property (nonatomic, strong) SLAccelerometerValues *accelerometerVales;

- (NSDictionary *)asDictionary;
- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary;
- (void)updateAccelerometerValues:(NSDictionary *)dictionary;
- (void)setInitialProperties:(NSDictionary *)dictionary;
- (void)updateProperties:(NSDictionary *)dictionary;
- (void)updatePropertiesWithServerDictionary:(NSDictionary *)dictionary;
- (NSString *)displayName;
- (BOOL)isInFactoryMode;
- (CLLocationCoordinate2D)location;
- (void)setCurrentLocation:(CLLocationCoordinate2D)location;
- (void)switchLockNameToProvisioned;
- (SLLockParameterRange)rangeForParameterType:(SLLockParameterType)type;

@end

NS_ASSUME_NONNULL_END

#import "SLLock+CoreDataProperties.h"
