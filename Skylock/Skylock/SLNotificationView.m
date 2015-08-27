//
//  SLNotificationView.m
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationView.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"
#import "SLNotification.h"

#define kSLNotificationTheftViewTimerValue  30

@interface SLNotificationView()

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *ratingView;
@property (nonatomic, strong) UIImageView *timerIcon;

@end

@implementation SLNotificationView
- (id)initWithFrame:(CGRect)frame notification:(SLNotification *)notification
{
    self = [super initWithFrame:frame];
    if (self) {
        _notification = notification;
        
        UITapGestureRecognizer *tgr = [UITapGestureRecognizer new];
        [tgr addTarget:self action:@selector(viewTapped)];
        tgr.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tgr];
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3.0f;
    }
    
    return self;
}

- (UIImageView *)icon
{
    if (!_icon) {
        UIImage *image = self.iconImage;
        _icon = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_icon];
    }
    
    return _icon;
}

- (UILabel *)headerLabel
{
    if (!_headerLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        CGSize size = [self.notification.mainText sizeWithFont:font maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 size.width,
                                                                 size.height)];
        _headerLabel.font = font;
        _headerLabel.textColor = [UIColor colorWithRed:97 green:97 blue:100];
        _headerLabel.text = self.notification.mainText;
        [self addSubview:_headerLabel];
    }
    
    return _headerLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        CGSize size = [self.notification.detailText sizeWithFont:font maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 size.width,
                                                                 size.height + 1)];
        _detailLabel.font = font;
        _detailLabel.textColor = [UIColor colorWithRed:146 green:148 blue:151];
        _detailLabel.text = self.notification.detailText;
        [self addSubview:_detailLabel];
    }
    
    return _detailLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        CGSize size = [self.notification.displayDateString sizeWithFont:font
                                                                maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                               0.0f,
                                                               size.width,
                                                               size.height)];
        _timeLabel.font = font;
        _timeLabel.textColor = [UIColor colorWithRed:146 green:148 blue:151];
        _timeLabel.text = self.notification.displayDateString;
        [self addSubview:_timeLabel];
    }
    
    return _timeLabel;
}

- (UIImageView *)timerIcon
{
    if (!_timerIcon) {
        UIImage *image = [UIImage imageNamed:@"icon_timer"];
        _timerIcon = [[UIImageView alloc] initWithImage:image];
        _timerIcon.hidden = self.notification.type != SLNotificationTypeCrashPre;
        [self addSubview:_timerIcon];
    }
    
    return _timerIcon;
}

- (UILabel *)countDownLabel
{
    if (!_countDownLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        NSString *text = @"30s";
        CGSize size = [text sizeWithFont:font maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    size.width,
                                                                    size.height)];
        _countDownLabel.font = font;
        _countDownLabel.textColor = [UIColor colorWithRed:97 green:97 blue:100];
        [self addSubview:_countDownLabel];
    }
    
    return _countDownLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.icon.frame = CGRectMake(12.0,
                                 12.0,
                                 self.icon.frame.size.width,
                                 self.icon.frame.size.height);
    
    self.headerLabel.frame = CGRectMake(CGRectGetMaxX(self.icon.frame) + 10.0f,
                                        self.icon.frame.origin.y,
                                        self.headerLabel.frame.size.width,
                                        self.headerLabel.frame.size.height);
    
    self.timeLabel.frame = CGRectMake(self.bounds.size.width - self.timeLabel.bounds.size.width - 12.0f,
                                      self.icon.frame.origin.y,
                                      self.timeLabel.frame.size.width,
                                      self.timeLabel.frame.size.height);
    
    self.detailLabel.frame = CGRectMake(self.headerLabel.frame.origin.x,
                                        CGRectGetMaxY(self.icon.frame) - self.detailLabel.frame.size.height,
                                        self.detailLabel.frame.size.width,
                                        self.detailLabel.frame.size.height);
    
    self.countDownLabel.frame = CGRectMake(self.bounds.size.width - self.countDownLabel.bounds.size.width - 12.0f,
                                           self.detailLabel.frame.origin.y,
                                           self.countDownLabel.bounds.size.width,
                                           self.countDownLabel.bounds.size.height);
    
    self.timerIcon.frame = CGRectMake(self.countDownLabel.frame.origin.x - self.timerIcon.bounds.size.width - 5.0f,
                                      CGRectGetMaxY(self.countDownLabel.frame) - self.timerIcon.bounds.size.height,
                                      self.timerIcon.bounds.size.width,
                                      self.timerIcon.bounds.size.height);
}

- (void)viewTapped
{
    if ([self.delegate respondsToSelector:@selector(notificationsViewTapped:)]) {
        [self.delegate notificationsViewTapped:self];
    }
}

- (UIImage *)iconImage
{
    NSString *imageName;
    switch (self.notification.type) {
        case SLNotificationTypeCrashPre:
            imageName = @"img_crashalert_red";
            break;
        case SLNotificationTypeCrashPost:
            imageName = @"img_crashalert_red";
            break;
        case SLNotificationTypeTheftLow:
            imageName = @"img_theftalert_yellow";
            break;
        case SLNotificationTypeTheftMedium:
            imageName = @"img_theftalert_yellow";
            break;
        case SLNotificationTypeTheftHigh:
            imageName = @"img_theftalert_yellow";
            break;
        default:
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (void)startCountdown
{
    [self.notification startCountdown];
}

@end
