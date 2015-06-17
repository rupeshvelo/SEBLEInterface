//
//  SLLockInfoViewHeader.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SLLockInfoViewHeaderBatteryState) {
    SLLockInfoViewHeaderBatteryStateNone,
    SLLockInfoViewHeaderBatteryState0,
    SLLockInfoViewHeaderBatteryState1,
    SLLockInfoViewHeaderBatteryState2,
    SLLockInfoViewHeaderBatteryState3,
    SLLockInfoViewHeaderBatteryState4
};

typedef NS_ENUM(NSUInteger, SLLockInfoViewHeaderCellSignalState) {
    SLLockInfoViewHeaderCellSignalStateNone,
    SLLockInfoViewHeaderCellSignalState0,
    SLLockInfoViewHeaderCellSignalState1,
    SLLockInfoViewHeaderCellSignalState2,
    SLLockInfoViewHeaderCellSignalState3,
    SLLockInfoViewHeaderCellSignalState4
};

@interface SLLockInfoViewHeader : UIView



- (void)setBatteryImage:(SLLockInfoViewHeaderBatteryState)batteryState;
- (void)setCellSignalImage:(SLLockInfoViewHeaderCellSignalState)cellState;

- (SLLockInfoViewHeaderBatteryState)SLLockBatteryState;
- (SLLockInfoViewHeaderCellSignalState)SLCellSignalState;

@end
