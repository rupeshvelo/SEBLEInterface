//
//  SLNotificationViewController.h
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNotificationView.h"
#import "SLNotificationEmergencyView.h"

@class SLNotificationViewController;
@class SLNotification;

@protocol SLNotificationViewControllerDelegate <NSObject>

- (void)notificationVCWantsDismiss:(SLNotificationViewController *)notificationVC;

@end


@interface SLNotificationViewController : UIViewController <SLNotficationViewDelegate, SLNotificationEmergencyViewDelegate>

@property (nonatomic, weak) id <SLNotificationViewControllerDelegate> delegate;

- (void)dismissNotification:(SLNotification *)notificaion;
- (void)addNewNotficationViewForNotification:(SLNotification *)notification;

@end
