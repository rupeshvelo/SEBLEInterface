//
//  SLSlideViewController.h
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLAddLockViewController.h"
#import "SLSlideTableViewHeader.h"
#import "SLCirclePicView.h"
#import "SLLockTableViewCell.h"
#import "SLEditLockTableViewCell.h"

@class SLSlideViewController;

typedef NS_ENUM(NSUInteger, SLSlideViewControllerButtonAction) {
    SLSlideViewControllerButtonActionNone,
    SLSlideViewControllerButtonActionExit,
    SLSlideViewControllerButtonActionAddLock,
    SLSlideViewControllerButtonActionStore,
    SLSlideViewControllerButtonActionHelp,
    SLSlideViewControllerButtonActionSharing,
    SLSlideViewControllerButtonActionLockSelected,
    SLSlideViewControllerButtonActionLockDeselected,
    SLSlideViewControllerButtonActionRename,
    SLSlideViewControllerButtonActionViewAccount
};

@protocol SLSlideViewControllerDelegate <NSObject>

- (void)slideViewController:(SLSlideViewController *)slvc actionOccured:(SLSlideViewControllerButtonAction)action options:(NSDictionary *)options;

@end


@interface SLSlideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SLAddLockViewControllerDelegate, SLSlideTableViewHeaderDelegate, SLLockTableViewCellDelegate, SLEditLockTableViewCellDelegate>

@property (nonatomic, weak) id <SLSlideViewControllerDelegate>delegate;

@end
