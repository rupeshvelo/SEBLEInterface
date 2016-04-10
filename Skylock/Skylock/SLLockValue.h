//
//  SLLockValue.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLLockValue;

@protocol SLLockValueDelegate <NSObject>

- (void)lockValueMeanUpdated:(SLLockValue *)lockValue mean:(NSDictionary *)meanValues;

@end


@interface SLLockValue : NSObject


@property (nonatomic, weak) id <SLLockValueDelegate> delegate;

- (id)initWithMaxCount:(NSUInteger)maxCount andMacAddress:(NSString *)macAddress;
- (void)updateValuesWithValues:(NSDictionary *)newValues;
- (NSString *)getMacAddress;

@end
