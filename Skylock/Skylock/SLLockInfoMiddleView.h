//
//  SLLockInfoMiddleView.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLLockInfoViewBase.h"

@class SLLock;
@class SLLockInfoMiddleView;


typedef NS_ENUM(NSUInteger, SLLockInfoMiddleViewButton) {
    SLLockInfoMiddleViewButtonNone,
    SLLockInfoMiddleViewButtonCrash,
    SLLockInfoMiddleViewButtonSecurity,
    SLLockInfoMiddleViewButtonSharing
};


@protocol SLLockMiddleViewDelegate <NSObject>

- (void)middleViewCrashButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn;
- (void)middleViewSecurityButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn;
- (void)middleViewSharingButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn;

@end

@interface SLLockInfoMiddleView : SLLockInfoViewBase

@property (nonatomic, weak) id <SLLockMiddleViewDelegate> delegate;


@end
