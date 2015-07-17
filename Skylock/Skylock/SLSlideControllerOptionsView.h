//
//  SLSlideControllerOptionsView.h
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSlideControllerOptionsView;

@protocol SLSlideControllerOptionsViewDelegate <NSObject>

- (void)addLockPressedOnSlideControllerOptionsView:(SLSlideControllerOptionsView *)optionsView;

- (void)storePressedOnSlideControllerOptionsView:(SLSlideControllerOptionsView *)optionsView;

- (void)settingsPressedOnSlideControllerOptionsView:(SLSlideControllerOptionsView *)optionsView;

- (void)helpPressedOnSlideControllerOptionsView:(SLSlideControllerOptionsView *)optionsView;

@end

@interface SLSlideControllerOptionsView : UIView

@property (nonatomic, weak) id <SLSlideControllerOptionsViewDelegate> delegate;
@end
