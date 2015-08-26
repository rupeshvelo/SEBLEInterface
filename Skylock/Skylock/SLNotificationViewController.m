//
//  SLNotificationViewController.m
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationViewController.h"
#import "SLNotificationSmallView.h"
#import "SLNotificationLargeView.h"
#import "SLNotificationManager.h"
#import "SLNotification.h"

#define kSLNotificationsVCPadding           12.0f
#define kSLNotificationsVCLargeViewHeight   116.0f
#define kSLNotificationsVCSmallViewHeight   65.0f
#define kSLNotificationsVCGap               5.0f


@interface SLNotificationViewController()

@property (nonatomic, strong) NSArray *notifications;

@end

@implementation SLNotificationViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.notifications = [SLNotificationManager.manager getNotifications];
    CGFloat y = kSLNotificationsVCPadding;
    for (SLNotification *notification in self.notifications) {
        if (notification.type == SLNotificationTypeCrashPre) {
            CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                      y,
                                      self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                      kSLNotificationsVCLargeViewHeight);
            SLNotificationLargeView *largeView = [[SLNotificationLargeView alloc] initWithFrame:frame
                                                                                   notification:notification];
            [self.view addSubview:largeView];
        } else {
            CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                      y,
                                      self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                      kSLNotificationsVCLargeViewHeight);
            SLNotificationSmallView *smallView = [[SLNotificationSmallView alloc] initWithFrame:frame
                                                                                   notification:notification];
            notification.delegate = self;
        }
    }
}
@end
