//
//  SLSlideViewController.h
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLAddLockViewController.h"

@class SLSlideViewController;

typedef NS_ENUM(NSUInteger, SLSlideViewControllerButtonAction) {
    SLSlideViewControllerButtonActionNone,
    SLSlideViewControllerButtonActionExit,
    SLSlideViewcontrollerButtonActionAddLock,
    SLSlideViewControllerButtonActionStore,
    SLSlideViewControllerButtonActionSettings,
    SLSlideViewControllerButtonActionHelp,
    SLSlideViewControllerButtonActionLockSelected
};

@protocol SLSlideViewControllerDelegate <NSObject>

- (void)slideViewController:(SLSlideViewController *)slvc buttonPushed:(SLSlideViewControllerButtonAction)action options:(NSDictionary *)options;

@end


@interface SLSlideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SLAddLockViewControllerDelegate>

@property (nonatomic, weak) id <SLSlideViewControllerDelegate>delegate;

@end
