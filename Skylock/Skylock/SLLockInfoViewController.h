//
//  SLLockInfoViewController.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLLockInfoViewController;
@class SLLock;

typedef NS_ENUM(NSUInteger, SLLockInfoViewControllerAction) {
    SLLockInfoViewControllerActionNone,
    SLLockInfoViewControllerActionCrash,
    SLLockInfoViewControllerActionSecurity,
    SLLockInfoViewControllerActionSharing,
    SLLockInfoViewControllerActionChangeSize
};

@protocol SLLockInfoViewControllerDelegate <NSObject>

- (void)lockInfoViewController:(SLLockInfoViewController *)livc
            shouldIncreaseSize:(BOOL)shouldIncreaseSize;

@end

@interface SLLockInfoViewController : UIViewController

@property (nonatomic, weak) id <SLLockInfoViewControllerDelegate> delegate;
@property (nonatomic, strong) SLLock *lock;
@property (nonatomic, assign)BOOL isUp;

- (void)setUpView;

- (CGRect)crashButtonFrame;
- (CGRect)theftButtonFrame;
- (CGRect)sharingButtonFrame;

- (CGRect)crashLabelFrame;
- (CGRect)theftLabelFrame;
- (CGRect)sharingLabelFrame;

@end
