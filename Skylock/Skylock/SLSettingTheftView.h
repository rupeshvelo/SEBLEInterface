//
//  SLSettingTheftView.h
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewBase.h"

@class SLSettingTheftView;

@protocol SLSettingTheftViewDelegate <NSObject>

- (void)settingTheftView:(SLSettingTheftView *)theftView alertSwitchValueChangedTo:(BOOL)state;

- (void)settingTheftView:(SLSettingTheftView *)theftView sensitivityValueChangedTo:(NSNumber *)newValue;
@end


@interface SLSettingTheftView : SLLockInfoViewBase

@property (nonatomic, weak) id <SLSettingTheftViewDelegate> delegate;

@end
