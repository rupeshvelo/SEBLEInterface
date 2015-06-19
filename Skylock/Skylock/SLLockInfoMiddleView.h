//
//  SLLockInfoMiddleView.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLLock;
@class SLLockInfoMiddleView;


typedef NS_ENUM(NSUInteger, SLLockInfoMiddleViewButton) {
    SLLockInfoMiddleViewButtonNone,
    SLLockInfoMiddleViewButtonCrash,
    SLLockInfoMiddleViewButtonSecurity,
    SLLockInfoMiddleViewButtonSharing
};


@protocol SLLockMiddleViewDelegate <NSObject>

- (void)middleViewCrashButtonPressed:(SLLockInfoMiddleView *)middleView;
- (void)middleViewSecurityButtonPressed:(SLLockInfoMiddleView *)middleView;
- (void)middleViewSharingButtonPressed:(SLLockInfoMiddleView *)middleView;

@end

@interface SLLockInfoMiddleView : UIView

@property (nonatomic, weak) id <SLLockMiddleViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andLock:(SLLock *)lock;

@end
