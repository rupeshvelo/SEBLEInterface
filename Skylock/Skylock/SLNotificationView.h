//
//  SLNotificationView.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNotification.h"

@class SLNotificationView;

@protocol SLNotficationViewDelegate <NSObject>

- (void)notificationsViewTapped:(SLNotificationView *)notificationView;

@end

@interface SLNotificationView : UIView

@property (nonatomic, weak) id <SLNotficationViewDelegate> delegate;
@property (nonatomic, strong) SLNotification *notification;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) NSNumber *timerValue;


- (id)initWithFrame:(CGRect)frame notification:(SLNotification *)notification;
- (void)startCountdown;

@end
