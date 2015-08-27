//
//  SLNotificationEmergencyView.m
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationEmergencyView.h"

@interface SLNotificationEmergencyView()

@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *ignoreButton;

@end

@implementation SLNotificationEmergencyView
- (id)initWithFrame:(CGRect)frame notification:(SLNotification *)notification
{
    self = [super initWithFrame:frame notification:notification];
    if (self) {
        [self startCountdown];
    }
    
    return self;
}

- (UIButton *)helpButton
{
    if (!_helpButton) {
        UIImage *image = [UIImage imageNamed:@"btn_help"];
        _helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_helpButton setImage:image forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self addSubview:_helpButton];
    }

    return _helpButton;
}

- (UIButton *)ignoreButton
{
    if (!_ignoreButton) {
        UIImage *image = [UIImage imageNamed:@"btn_ignore"];
        _ignoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   image.size.width,
                                                                   image.size.height)];
        [_ignoreButton setImage:image forState:UIControlStateNormal];
        [_ignoreButton addTarget:self action:@selector(ignoreButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self addSubview:_ignoreButton];
    }
    
    return _ignoreButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.helpButton.frame = CGRectMake(12.0f,
                                       self.bounds.size.height - self.helpButton.bounds.size.height - 12.0f,
                                       self.helpButton.bounds.size.width,
                                       self.helpButton.bounds.size.height);
    
    self.ignoreButton.frame = CGRectMake(self.bounds.size.width - self.ignoreButton.bounds.size.width - 12.0f,
                                         self.helpButton.frame.origin.y,
                                         self.ignoreButton.bounds.size.width,
                                         self.ignoreButton.bounds.size.height);
}

- (void)helpButtonPressed
{
    if ([self.emergencyDelegate respondsToSelector:@selector(notificationEmergencyViewHelpButtonPressed:)]) {
        [self.emergencyDelegate notificationEmergencyViewHelpButtonPressed:self];
    }
}

- (void)ignoreButtonPressed
{
    if ([self.emergencyDelegate respondsToSelector:@selector(notificationEmergencyViewIgnoreButtonPressed:)]) {
        [self.emergencyDelegate notificationEmergencyViewIgnoreButtonPressed:self];
    }
}

- (void)updateTimerValue:(NSNumber *)value
{
    self.timerValue = value;
    self.countDownLabel.text = [NSString stringWithFormat:@"%@s", self.timerValue];
}
@end
