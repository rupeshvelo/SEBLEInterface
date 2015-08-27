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
            case SLAccerometerDataXMav:
                self.xmav = obj;
                break;
            case SLAccerometerDataYMav:
                self.ymav = obj;
                break;
            case SLAccerometerDataZMav:
                self.zmav = obj;
                break;
            case SLAccerometerDataXVar:
                self.xvar = obj;
                break;
            case SLAccerometerDataYVar:
                self.yvar = obj;
                break;
            case SLAccerometerDataZVar:
                self.zvar = obj;
                break;
            default:
                break;
        }
    }];
}

- (NSDictionary *)asDictionary
{
    return @{@(SLAccerometerDataXMav): self.xmav,
             @(SLAccerometerDataXVar): self.xvar,
             @(SLAccerometerDataYMav): self.ymav,
             @(SLAccerometerDataYVar): self.yvar,
             @(SLAccerometerDataZMav): self.zmav,
             @(SLAccerometerDataZVar): self.zvar
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
