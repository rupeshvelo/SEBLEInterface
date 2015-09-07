//
//  SLMainTutorialViewController.h
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLMainTutorialViewController;

@interface SLMainTutorialViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, assign) BOOL shouldDismiss;

@end
