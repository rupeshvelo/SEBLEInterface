//
//  SLNotificationViewController.m
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationViewController.h"
#import "SLNotificationView.h"
#import "SLNotificationEmergencyView.h"
#import "SLNotificationManager.h"
#import "SLNotification.h"
#import "UIColor+RGB.h"
#import "SLNotifications.h"

#define kSLNotificationsVCPadding           12.0f
#define kSLNotificationsVCLargeViewHeight   116.0f
#define kSLNotificationsVCSmallViewHeight   65.0f
#define kSLNotificationsVCGap               5.0f


@interface SLNotificationViewController()

@property (nonatomic, strong) NSArray *notifications;
@property (nonatomic, strong) NSMutableArray *notificationViews;
@property (nonatomic, assign) CGFloat maxY;
@end

@implementation SLNotificationViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.notificationViews = [NSMutableArray new];
    
    self.view.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0] colorWithAlphaComponent:.8f];
    self.notifications = [SLNotificationManager.manager getNotifications];
    self.maxY = kSLNotificationsVCPadding + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat viewHeight = 0.0f;
    
    for (SLNotification *notification in self.notifications) {
        if (notification.type == SLNotificationTypeCrashPre) {
            CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                      self.maxY,
                                      self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                      kSLNotificationsVCLargeViewHeight);
            SLNotificationEmergencyView *emergencyView = [[SLNotificationEmergencyView alloc] initWithFrame:frame
                                                                                               notification:notification];
            emergencyView.emergencyDelegate = self;
            [self.view addSubview:emergencyView];
            [self.notificationViews addObject:emergencyView];
            viewHeight = kSLNotificationsVCLargeViewHeight;
        } else {
            CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                      self.maxY,
                                      self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                      kSLNotificationsVCLargeViewHeight);
            SLNotificationView *notificationView = [[SLNotificationView alloc] initWithFrame:frame
                                                                                notification:notification];
            notificationView.delegate = self;
            [self.view addSubview:notificationView];
            [self.notificationViews addObject:notificationView];
            viewHeight = kSLNotificationsVCSmallViewHeight;
        }
        
        self.maxY += kSLNotificationsVCPadding + viewHeight;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationTimerValueUpdated:)
                                                 name:kSLNotificationTimerValueUpdated
                                               object:nil];
    
}

- (void)notificationTimerValueUpdated:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    SLNotification *slNotification = userInfo[@"notification"];
    NSNumber *value = userInfo[@"value"];
    for (UIView *view in self.view.subviews) {
        if ([view isMemberOfClass:[SLNotificationEmergencyView class]]) {
            SLNotificationEmergencyView *emergencyView = (SLNotificationEmergencyView *)view;
            if ([emergencyView.notification.identifier isEqualToString:slNotification.identifier]) {
                [emergencyView updateTimerValue:value];
                break;
            }
        }
    }
}

- (void)notificationsViewTapped:(SLNotificationView *)notificationView
{
    NSLog(@"notification view tapped");
}

- (void)dismissNotification:(SLNotification *)notificaion
{
    
}

- (void)removeNotificationView:(SLNotificationView *)notificationView
{
    NSUInteger index = [self.notificationViews indexOfObject:notificationView];
    CGFloat notificationViewHeight = notificationView.bounds.size.height;
    [self.notificationViews removeObjectAtIndex:index];
    self.maxY -= (notificationViewHeight + kSLNotificationsVCPadding);
    [UIView animateWithDuration:.15 animations:^{
        notificationView.frame = CGRectMake(self.view.bounds.size.width - notificationView.bounds.size.width,
                                            notificationView.frame.origin.y,
                                            notificationView.bounds.size.width,
                                            notificationView.bounds.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            notificationView.frame = CGRectMake(-notificationView.bounds.size.width,
                                                notificationView.frame.origin.y,
                                                notificationView.bounds.size.width,
                                                notificationView.bounds.size.height);
        } completion:^(BOOL finished) {
            [notificationView removeFromSuperview];
            [self reorganizeViewsFromIndex:index withRemovedViewHeight:notificationViewHeight];
        }];
    }];
}

- (void)reorganizeViewsFromIndex:(NSUInteger)startIndex withRemovedViewHeight:(CGFloat)removedViewHeight
{
    for (NSUInteger i=startIndex; i < self.notificationViews.count; i++) {
        SLNotificationView *view = self.notificationViews[i];
        [UIView animateWithDuration:.4 animations:^{
            view.frame = CGRectOffset(view.frame, 0.0f, -removedViewHeight - kSLNotificationsVCPadding);
        }];
    }
}

- (void)addNewNotficationViewForNotification:(SLNotification *)notification
{
    CGFloat viewHeight = 0.0f;
    if (notification.type == SLNotificationTypeCrashPre) {
        CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                  self.maxY,
                                  self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                  kSLNotificationsVCLargeViewHeight);
        SLNotificationEmergencyView *emergencyView = [[SLNotificationEmergencyView alloc] initWithFrame:frame
                                                                                           notification:notification];
        emergencyView.emergencyDelegate = self;
        [self slideNotificationViewIn:emergencyView];
        viewHeight = kSLNotificationsVCLargeViewHeight;
    } else {
        CGRect frame = CGRectMake(kSLNotificationsVCPadding,
                                  self.maxY,
                                  self.view.bounds.size.width - 2*kSLNotificationsVCPadding,
                                  kSLNotificationsVCLargeViewHeight);
        SLNotificationView *notificationView = [[SLNotificationView alloc] initWithFrame:frame
                                                                            notification:notification];
        notificationView.delegate = self;
        [self slideNotificationViewIn:notificationView];
        viewHeight = kSLNotificationsVCSmallViewHeight;
    }
    
    self.maxY += viewHeight + kSLNotificationsVCPadding;
}

- (void)slideNotificationViewIn:(SLNotificationView *)notificationView
{
    CGRect finalFrame = notificationView.frame;
    notificationView.frame = CGRectOffset(finalFrame, -kSLNotificationsVCPadding - finalFrame.size.width, 0.0f);
    [self.view addSubview:notificationView];
    [self.notificationViews addObject:notificationView];
    
    [UIView animateWithDuration:.5f animations:^{
        notificationView.frame = finalFrame;
    }];
}

#pragma mark - SLNotificationEmergencyView delegate methods
- (void)notificationEmergencyViewHelpButtonPressed:(SLNotificationEmergencyView *)notificationView
{
    
}

- (void)notificationEmergencyViewIgnoreButtonPressed:(SLNotificationEmergencyView *)notificationView
{
    [SLNotificationManager.manager dismissNotificationWithId:notificationView.notification.identifier];
    self.notifications = [SLNotificationManager.manager getNotifications];
    if (self.notifications.count == 0 && [self.delegate respondsToSelector:@selector(notificationVCWantsDismiss:)]) {
        [self.delegate notificationVCWantsDismiss:self];
    } else {
        [self removeNotificationView:notificationView];
    }
}

@end
