//
//  SLNotificationEmergencyView.h
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationView.h"
@class SLNotificationEmergencyView;

@protocol SLNotificationEmergencyViewDelegate <SLNotficationViewDelegate>

- (void)notificationEmergencyViewHelpButtonPressed:(SLNotificationEmergencyView *)notificationView;
- (void)notificationEmergencyViewIgnoreButtonPressed:(SLNotificationEmergencyView *)notificationView;

@end

@interface SLNotificationEmergencyView : SLNotificationView

@property (nonatomic, weak) id <SLNotificationEmergencyViewDelegate> emergencyDelegate;

- (void)updateTimerValue:(NSNumber *)value;

@end
