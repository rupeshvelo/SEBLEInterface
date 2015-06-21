//
//  SLSettingEmergencyView.h
//  Skylock
//
//  Created by Andre Green on 6/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewBase.h"

@class SLSettingEmergencyView;

@protocol SLSettingEmergencyViewDelegate <NSObject>

- (void)settingEmergencyView:(SLSettingEmergencyView *)emergencyView autoUnlockState:(BOOL)stateOn;

@end
@interface SLSettingEmergencyView : SLLockInfoViewBase

@property (nonatomic, weak) id <SLSettingEmergencyViewDelegate> delegate;
@end
