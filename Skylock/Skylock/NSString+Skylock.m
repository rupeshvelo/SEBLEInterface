//
//  NSString+Skylock.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "NSString+Skylock.h"
#import "SLConstants.h"

@implementation NSString (Skylock)

- (instancetype)stringWithDistance:(NSNumber *)distance
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    // should figure out a way to do this that does not involve hard coding the distance unit
    // probably should be a server side fix, or an option that the user can configure
    if (distance.integerValue < SLConstantsFeetInMile) {
        return [NSString stringWithFormat:@"%@ft away", distance];
    } else {
        float miles = distance.floatValue/(float)SLConstantsFeetInMile;
        return [NSString stringWithFormat:@"%.1fmi away", miles];
    }
}

@end
