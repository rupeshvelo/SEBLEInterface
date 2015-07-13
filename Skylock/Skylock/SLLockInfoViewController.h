//
//  SLLockInfoViewController.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLLockInfoViewHeader.h"
#import "SLLockInfoMiddleView.h"
#import "SLLockInfoBottomView.h"

@class SLLockInfoViewController;


typedef NS_ENUM(NSUInteger, SLLockInfoViewControllerAction) {
    SLLockInfoViewControllerActionNone,
    SLLockInfoViewControllerActionCrash,
    SLLockInfoViewControllerActionSecurity,
    SLLockInfoViewControllerActionSharing
};

@protocol SLLockInfoViewControllerDelegate <NSObject>

- (void)lockInfoViewController:(SLLockInfoViewController *)livc action:(SLLockInfoViewControllerAction)action;

@end
@interface SLLockInfoViewController : UIViewController <SLLockInfoViewHeaderDelegate, SLLockMiddleViewDelegate, SLLockInfoBottomViewDelegate>

@property (nonatomic, weak) id <SLLockInfoViewControllerDelegate> delegate;
@property (nonatomic, strong) SLLock *lock;
@property (nonatomic, strong) SLLockInfoMiddleView *middleView;

@end
