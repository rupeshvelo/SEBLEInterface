//
//  SLAccelerometerValues.m
//  Skylock
//
//  Created by Andre Green on 8/26/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAccelerometerValues.h"

@implementation SLAccelerometerValues

- (id)initWithValues:(NSDictionary *)values
{
    self = [super init];
    if (self) {
        [self setValues:values];
    }
    
    return self;
}

+ (id)accelerometerValuesWithValues:(NSDictionary *)values
{
    return [[self alloc] initWithValues:values];
}

- (void)setValues:(NSDictionary *)values
{
    [values enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *obj, BOOL *stop) {
        switch (key.unsignedIntegerValue) {
            case SLAccelerometerDataXMav:
                self.xmav = obj;
                break;
            case SLAccelerometerDataYMav:
                self.ymav = obj;
                break;
            case SLAccelerometerDataZMav:
                self.zmav = obj;
                break;
            case SLAccelerometerDataXVar:
                self.xvar = obj;
                break;
            case SLAccelerometerDataYVar:
                self.yvar = obj;
                break;
            case SLAccelerometerDataZVar:
                self.zvar = obj;
                break;
            default:
                break;
        }
    }];
}

- (NSDictionary *)asDictionary
{
    return @{@(SLAccelerometerDataXMav): self.xmav,
             @(SLAccelerometerDataXVar): self.xvar,
             @(SLAccelerometerDataYMav): self.ymav,
             @(SLAccelerometerDataYVar): self.yvar,
             @(SLAccelerometerDataZMav): self.zmav,
             @(SLAccelerometerDataZVar): self.zvar
             };
}

- (NSDictionary *)asReadableDictionary
{
    return @{@"xmav": self.xmav,
             @"xvar": self.xvar,
             @"ymav": self.ymav,
             @"yvar": self.yvar,
             @"zmav": self.zmav,
             @"zvar": self.zvar
             };
}

@end
