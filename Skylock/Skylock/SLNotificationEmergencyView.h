//
//  SLNotificationEmergencyView.h
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationView.m"

@protocol SLNotificationEmergencyViewDelegate <SLNotificationViewDelegate>

- (void)notificationViewHelpButtonPressed:(SLNotificationEmergencyView *)notificationView;
- (void)notificationViewIgnoreButtonPressed:(SLNotificationEmergencyView *)notificationView;

@end

@interface SLNotificationEmergencyView : SLNotificationView

@end
