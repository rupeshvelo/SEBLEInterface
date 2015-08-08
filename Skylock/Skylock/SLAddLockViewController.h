//
//  SLAddLockViewController.h
//  Skylock
//
//  Created by Andre Green on 7/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SLAddLockViewController;
@class SLLock;


@protocol SLAddLockViewControllerDelegate <NSObject>

- (void)addLockViewController:(SLAddLockViewController *)alvc didAddLock:(SLLock *)lock;
- (void)addLockViewControllerWantsDismiss:(SLAddLockViewController *)alvc;
@end

@interface SLAddLockViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <SLAddLockViewControllerDelegate> delegate;

@end
