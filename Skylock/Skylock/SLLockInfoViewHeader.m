//
//  SLLockInfoViewHeader.m
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewHeader.h"
#import "SLLock.h"
#import "SLConstants.h"

@interface SLLockInfoViewHeader()

@property (nonatomic, strong) UILabel *lockNameLabel;
@property (nonatomic, strong) UIImageView *batteryImageView;
@property (nonatomic, strong) UIImageView *wifiImageView;
@property (nonatomic, strong) UIImageView *cellSignalImageView;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UILabel *distanceAwayLabel;
@property (nonatomic, strong) UILabel *lastLabel;
@property (nonatomic, assign) SLLock *lock;

@end


@implementation SLLockInfoViewHeader

- (id)initWithFrame:(CGRect)frame andLock:(SLLock *)lock
{
    self = [super initWithFrame:frame];
    if (self) {
        _lock = lock;
    }
    
    return self;
}

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        UIImage *settingImage = [UIImage imageNamed:@"settings-icon"];
        _settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     settingImage.size.width,
                                                                     settingImage.size.height)];
        [_settingsButton setBackgroundImage:settingImage forState:UIControlStateNormal];
        [_settingsButton addTarget:self
                            action:@selector(settingsButtonPressed)
                  forControlEvents:UIControlEventTouchDown];
        [self addSubview:_settingsButton];
    }
    
    return _settingsButton;
}

- (UIImageView *)batteryImageView
{
    if (!_batteryImageView) {
        _batteryImageView = [[UIImageView alloc] initWithImage:[self batteryImage]];
        [self addSubview:_batteryImageView];
    }
    
    return _batteryImageView;
}

- (UIImageView *)cellSignalImageView
{
    if (_cellSignalImageView) {
        _cellSignalImageView = [[UIImageView alloc] initWithImage:[self cellSignalImage]];
        [self addSubview:_cellSignalImageView];
    }

    return _cellSignalImageView;
}

- (UIImageView *)wifiImageView
{
    if (!_wifiImageView) {
        _wifiImageView = [[UIImageView alloc] initWithImage:[self wifiImage]];
        [self addSubview:_wifiImageView];
    }
    
    return _wifiImageView;
}

- (UILabel *)lastLabel
{
    if (!_lastLabel) {
        CGSize maxSize = CGSizeMake(.2*self.bounds.size.width, 20.0f);
        NSString *labelText = self.lastLabelText;
        CGRect labelFrame = [labelText boundingRectWithSize:maxSize
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:SLConstantsDefaultFont}
                                                    context:nil];
        _lastLabel.frame = labelFrame;
        _lastLabel.text = labelText;
        [self addSubview:_lastLabel];
    }
    
    return _lastLabel;
}

- (UILabel *)distanceAwayLabel
{
    if (!_distanceAwayLabel) {
        CGSize maxSize = CGSizeMake(.2*self.bounds.size.width, 20.0f);
        NSString *labelText = self.distanceAwayLabelText;
        CGRect labelFrame = [labelText  boundingRectWithSize:maxSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:SLConstantsDefaultFont}
                                                     context:nil];
        _distanceAwayLabel.frame = labelFrame;
        _distanceAwayLabel.text = labelText;
        [self addSubview:_distanceAwayLabel];
    }
    
    return _distanceAwayLabel;
}

- (UILabel *)lockNameLabel
{
    if (!_lockNameLabel) {
        CGSize maxNameSize = CGSizeMake(.2*self.bounds.size.width, 20.0f);
        CGRect labelFrame = [_lock.name boundingRectWithSize:maxNameSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:SLConstantsDefaultFont}
                                                     context:nil];
        _lockNameLabel.frame = labelFrame;
        _lockNameLabel.text = NSLocalizedString(self.lock.name, nil);
        [self addSubview:_lockNameLabel];
    }
    
    return _lockNameLabel;
}

- (void)layoutSubviews
{
    static CGFloat yPaddingScaler = .1f;
    static CGFloat xPaddingScaler = .1f;
    
    CGFloat y0 = yPaddingScaler*self.bounds.size.height;
    CGFloat x0 = xPaddingScaler*self.bounds.size.width;

    self.lockNameLabel.frame = CGRectMake(x0,
                                          y0,
                                          self.lockNameLabel.bounds.size.width,
                                          self.lockNameLabel.bounds.size.height);
    
    self.settingsButton.frame = CGRectMake(self.bounds.size.width - x0,
                                           y0,
                                           self.settingsButton.bounds.size.width,
                                           self.settingsButton.bounds.size.height);
    
    self.wifiImageView.frame = CGRectMake(.5f*(self.bounds.size.width - self.wifiImageView.frame.size.width),
                                          y0,
                                          self.wifiImageView.bounds.size.width,
                                          self.wifiImageView.bounds.size.height);
    
    self.batteryImageView.frame = CGRectMake(self.wifiImageView.frame.origin.x - 1.2f*self.batteryImageView.bounds.size.width,
                                             y0,
                                             self.batteryImageView.bounds.size.width,
                                             self.batteryImageView.bounds.size.height);
    
    self.cellSignalImageView.frame = CGRectMake(self.wifiImageView.frame.origin.x + self.wifiImageView.bounds.size.width + 10.0f,
                                                y0,
                                                self.cellSignalImageView.bounds.size.width,
                                                self.cellSignalImageView.bounds.size.height);
    
    self.lastLabel.frame = CGRectMake(x0,
                                      self.lockNameLabel.frame.origin.x + self.lockNameLabel.frame.size.height + y0,
                                      self.lastLabel.bounds.size.width,
                                      self.lastLabel.bounds.size.height);
    
    self.distanceAwayLabel.frame = CGRectMake(self.batteryImageView.frame.origin.x,
                                              self.lastLabel.frame.origin.y,
                                              self.distanceAwayLabel.bounds.size.width,
                                              self.distanceAwayLabel.bounds.size.height);
}

- (UIImage *)batteryImage
{
    NSString *imageName;
    switch (self.lock.batteryState) {
        case SLLockBatteryStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockBatteryState1:
            imageName = @"somename";
            break;
        case SLLockBatteryState2:
            imageName = @"somename";
            break;
        case SLLockBatteryState3:
            imageName = @"somename";
            break;
        case SLLockBatteryState4:
            imageName = @"somename";
            break;
        case SLLockBatteryState5:
            imageName = @"somename";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (UIImage *)cellSignalImage
{
    NSString *imageName;
    switch (self.lock.cellSignalState) {
        case SLLockCellSignalStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockCellSignalState1:
            imageName = @"somename";
            break;
        case SLLockCellSignalState2:
            imageName = @"somename";
            break;
        case SLLockCellSignalState3:
            imageName = @"somename";
            break;
        case SLLockCellSignalState4:
            imageName = @"somename";
            break;
        case SLLockCellSignalState5:
            imageName = @"somename";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (UIImage *)wifiImage
{
    NSString *imageName;
    switch (self.lock.wifiState) {
        case SLLockWifiSignalStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockWifiSignalState1:
            imageName = @"somename";
            break;
        case SLLockWifiSignalState2:
            imageName = @"somename";
            break;
        case SLLockWifiSignalState3:
            imageName = @"somename";
            break;
        case SLLockWifiSignalState4:
            imageName = @"somename";
            break;
        case SLLockWifiSignalState5:
            imageName = @"somename";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (void)settingsButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(lockInfoViewHeaderSettingButtonPressed:)]) {
        [self.delegate lockInfoViewHeaderSettingButtonPressed:self];
    }
}

- (NSString *)lastTimeString
{
    // move this to an extension of NSString...when you're on the ground
    // and can look up how to do it
    
    if (self.lock.lastTime.integerValue < 60) {
        return [NSString stringWithFormat:@"%@", self.lock.lastTime];
    } else {
        NSUInteger hours = self.lock.lastTime.integerValue/60;
        NSUInteger minutes = self.lock.lastTime.integerValue%60;
        return [NSString stringWithFormat:@"%@:%@", @(hours), @(minutes)];
    }
}

- (NSString *)lastLabelText
{
    NSString *last = NSLocalizedString(@"Last", nil);
    return [NSString stringWithFormat:@"%@:%@", last, self.lastTimeString];
}

- (NSString *)distanceAwayString
{
    // should figure out a way to do this that does not involve hard coding the distance unit
    // probably should be a server side fix, or an option that the user can configure
    if (self.lock.distanceAway.integerValue < 5280) {
        return [NSString stringWithFormat:@"%@ ft", self.lock.distanceAway];
    } else {
        CGFloat miles = self.lock.distanceAway.floatValue/5250.0;
        return [NSString stringWithFormat:@"%.1f mi", miles];
    }
}

- (NSString *)distanceAwayLabelText
{
    NSString *away = NSLocalizedString(@"away", nil);
    return [NSString stringWithFormat:@"%@ %@", self.distanceAwayString, away];
}
            
@end
