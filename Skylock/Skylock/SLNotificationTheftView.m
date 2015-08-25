//
//  SLNotificationTheftView.m
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationTheftView.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"
#import "SLNotification.h"

#define kSLNotificationTheftViewTimerValue  30

@interface SLNotificationTheftView()

@property (nonatomic, strong) UIImageView *theftIcon;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *ratingView;
@property (nonatomic, strong) UIImageView *timerIcon;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, strong) NSNumber *timerValue;
@property (nonatomic, strong) SLNotification *notification;

@end

@implementation SLNotificationTheftView

- (UIImageView *)theftIcon
{
    if (!_theftIcon) {
        UIImage *image = [UIImage imageNamed:@"theft-alert-icon"];
        _theftIcon = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_theftIcon];
    }
    
    return _theftIcon;
}

- (UILabel *)headerLabel
{
    if (!_headerLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        CGSize size = [self.notification.mainText sizeWithFont:font maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        _headerLabel.font = font;
        _headerLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0];
        _headerLabel.text = self.notification.mainText;
        [self addSubview:_headerLabel];
    }
    
    return _headerLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue " size:11];
        CGSize size = [self.notification.detailText sizeWithFont:font maxSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        _detailLabel.font = font;
        _detailLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0];
        _detailLabel.text = self.notification.detailText;
        [self addSubview:_detailLabel];
    }
    
    return _detailLabel;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        
        _timeLabel = [UILabel alloc] initWithFrame:<#(CGRect)#>
    }
}


- (id)initWithFrame:(CGRect)frame notification:(SLNotification *)notification
{
    self = [super initWithFrame:frame];
    if (self) {
        _notification = notification;
    }
    
    return self;
}

@end
