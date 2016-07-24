//
//  SLAccelerometerValues.h
//  Skylock
//
//  Created by Andre Green on 8/26/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLAccelerometerData) {
    SLAccelerometerDataXMav,
    SLAccelerometerDataYMav,
    SLAccelerometerDataZMav,
    SLAccelerometerDataXVar,
    SLAccelerometerDataYVar,
    SLAccelerometerDataZVar
};

@interface SLAccelerometerValues : NSObject

@property (nonatomic, copy) NSNumber *xmav;
@property (nonatomic, copy) NSNumber *xvar;
@property (nonatomic, copy) NSNumber *ymav;
@property (nonatomic, copy) NSNumber *yvar;
@property (nonatomic, copy) NSNumber *zmav;
@property (nonatomic, copy) NSNumber *zvar;

- (id)initWithValues:(NSDictionary *)values;
+ (id)accelerometerValuesWithValues:(NSDictionary *)values;
- (void)setValues:(NSDictionary *)values;
- (NSDictionary *)asDictionary;
- (NSDictionary *)asReadableDictionary;

@end
