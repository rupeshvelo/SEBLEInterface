//
//  SLSlideViewController.h
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLAddLockViewController.h"
#import "SLSlideControllerOptionsView.h"
#import "SLSlideTableViewHeader.h"
#import "SLCirclePicView.h"

@class SLSlideViewController;
@class SLDbUser;

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

- (void)slideViewControllerViewAccountPressed:(SLSlideViewController *)slvc forUser:(SLDbUser *)user;

@end


@interface SLSlideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SLAddLockViewControllerDelegate, SLSlideControllerOptionsViewDelegate, SLSlideTableViewHeaderDelegate>

@property (nonatomic, weak) id <SLSlideViewControllerDelegate>delegate;

@end
