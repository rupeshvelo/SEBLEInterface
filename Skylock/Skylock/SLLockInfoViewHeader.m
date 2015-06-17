//
//  SLLockInfoViewHeader.m
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewHeader.h"


@interface SLLockInfoViewHeader()

@property (nonatomic, strong) UILabel *lockName;
@property (nonatomic, strong) UIImageView *batteryImageView;
@property (nonatomic, strong) UIImageView *wifiImageView;
@property (nonatomic, strong) UIImageView *cellSignalImageView;
@property (nonatomic, strong) UIImageView *settingsImageView;
@property (nonatomic, strong) UIImageView *lastImageView;
@property (nonatomic, strong) UIImageView *distanceAwayImageView;

@property (nonatomic, assign) SLLockInfoViewHeaderBatteryState batteryState;
@property (nonatomic, assign) SLLockInfoViewHeaderCellSignalState cellState;

@end


@implementation SLLockInfoViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lockName               = [UILabel new];
        _batteryImageView       = [UIImageView new];
        _wifiImageView          = [UIImageView new];
        _cellSignalImageView    = [UIImageView new];
        _settingsImageView      = [UIImageView new];
        _lastImageView          = [UIImageView new];
        _distanceAwayImageView  = [UIImageView new];
        
        _batteryState = SLLockInfoViewHeaderBatteryStateNone;
        _cellState = SLLockInfoViewHeaderCellSignalStateNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    
}

- (void)setBatteryImage:(SLLockInfoViewHeaderBatteryState)batteryState
{
    NSString *imageName;
    self.batteryState = batteryState;
    switch (self.batteryState) {
        case SLLockInfoViewHeaderBatteryStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockInfoViewHeaderBatteryState0:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderBatteryState1:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderBatteryState2:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderBatteryState3:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderBatteryState4:
            imageName = @"somename";
            break;
    }
    
    if (imageName) {
        self.batteryImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
    }
}

- (void)setCellSignalImage:(SLLockInfoViewHeaderCellSignalState)cellState
{
    NSString *imageName;
    self.cellState = cellState;
    switch (self.cellState) {
        case SLLockInfoViewHeaderCellSignalStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockInfoViewHeaderCellSignalState0:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderCellSignalState1:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderCellSignalState2:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderCellSignalState3:
            imageName = @"somename";
            break;
        case SLLockInfoViewHeaderCellSignalState4:
            imageName = @"somename";
            break;
    }
    
    if (imageName) {
        self.cellSignalImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
    }
    
}

- (SLLockInfoViewHeaderBatteryState)SLLockBatteryState
{
    return self.batteryState;
}

- (SLLockInfoViewHeaderCellSignalState)SLCellSignalState
{
    return self.cellState;
}

@end
