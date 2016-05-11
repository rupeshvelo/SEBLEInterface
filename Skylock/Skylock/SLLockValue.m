//
//  SLLockValue.m
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockValue.h"

@interface SLLockValue()

@property (nonatomic, assign) NSUInteger maxCount;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *values;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, copy) NSString *macAddress;

@end

@implementation SLLockValue

- (id)initWithMaxCount:(NSUInteger)maxCount andMacAddress:(NSString *)macAddress
{
    self = [super init];
    if (self) {
        _count = 0;
        _maxCount = maxCount;
        _macAddress = macAddress;
        _values = [NSMutableArray new];
    }
    
    return self;
}

- (void)updateValuesWithValues:(NSDictionary *)newValues
{
    if (!self.keys) {
        self.keys = newValues.allKeys;
    }

    NSMutableDictionary *values = [NSMutableDictionary new];
    for (NSNumber *key in self.keys) {
        values[key] = newValues[key];
    }
    
    [self.values addObject:values];
    
    self.count++;
    if (self.count == self.maxCount) {
        [self averageValues];
    }
}

- (void)averageValues
{
    __block NSMutableDictionary *aveValues = [NSMutableDictionary new];
    [self.values enumerateObjectsUsingBlock:^(NSDictionary *values, NSUInteger idx, BOOL *stop) {
        for (NSNumber *key in self.keys) {
            if (aveValues[key]) {
                NSNumber *previousValue = aveValues[key];
                NSNumber *currentValue = values[key];
                NSInteger sum = previousValue.integerValue + currentValue.integerValue;
                if (idx == self.values.count - 1) {
                    double ave = (double)sum/(double)self.values.count;
                    aveValues[key] = @(ave);
                } else {
                    aveValues[key] = @(sum);
                }
            } else {
                aveValues[key] = values[key];
            }
        }
    }];
    
    self.count = 0;
    [self.values removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(lockValueMeanUpdated:mean:)]) {
        [self.delegate lockValueMeanUpdated:self mean:aveValues];
    }
}

- (NSString *)getMacAddress
{
    return self.macAddress;
}

@end
