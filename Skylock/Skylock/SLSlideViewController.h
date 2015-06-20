//
//  SLSlideViewController.h
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSlideViewController;

typedef NS_ENUM(NSUInteger, SLSlideViewControllerButtonAction) {
    SLSlideViewControllerButtonActionExit
};

@protocol SLSliceViewControllerDelegate <NSObject>

- (void)slideViewController:(SLSlideViewController *)slvc buttonPushed:(SLSlideViewControllerButtonAction)action;

@end


@interface SLSlideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SLSliceViewControllerDelegate>delegate;

@end
