//
//  SLSettingEmergencyView.m
//  Skylock
//
//  Created by Andre Green on 6/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSettingEmergencyView.h"
#import "SLConstants.h"

@interface SLSettingEmergencyView()

@property (nonatomic, strong) UILabel *pinCodeTitleLabel;
@property (nonatomic, strong) UILabel *pinCodeInfoLabel;
@property (nonatomic, strong) UILabel *setPinTitleLabel;
@property (nonatomic, strong) UILabel *pinCodeLabel;
@property (nonatomic, strong) UIButton *autoUnlockButton;

@end


@implementation SLSettingEmergencyView

- (UILabel *)pinCodeTitleLabel
{
    if (!_pinCodeTitleLabel) {
        _pinCodeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       self.bounds.size.width - 2*self.xPaddingScaler,
                                                                       .2*self.bounds.size.height)];
        _pinCodeTitleLabel.text = NSLocalizedString(@"Emergency Pin Code", nil);
        _pinCodeTitleLabel.font = SLConstantsDefaultFont;
        [self addSubview:_pinCodeTitleLabel];
    }
    
    return _pinCodeTitleLabel;
}

- (UILabel *)pinCodeInfoLabel
{
    if (!_pinCodeInfoLabel) {
        NSString *info = @"A pin code can be set to unlock the lock without a mobile device";
        _pinCodeInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.bounds.size.width - 2*self.xPaddingScaler,
                                                                      .2*self.bounds.size.height)];
        _pinCodeInfoLabel.text = NSLocalizedString(info, nil);
        _pinCodeInfoLabel.font = SLConstantsDefaultFont;
        [self addSubview:_pinCodeInfoLabel];
    }
    
    return _pinCodeInfoLabel;
}

- (UILabel *)setPinTitleLabel
{
    if (!_setPinTitleLabel) {
        _setPinTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.bounds.size.width,
                                                                      .2*self.bounds.size.height)];
        _setPinTitleLabel.text = NSLocalizedString(@"SET PIN ON LOCK", nil);
        _setPinTitleLabel.font = SLConstantsDefaultFont;
        _setPinTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_setPinTitleLabel];
    }
    
    return _setPinTitleLabel;
}

- (UILabel *)pinCodeLabel
{
    if (!_pinCodeLabel) {
        _pinCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  self.bounds.size.width,
                                                                  .2*self.bounds.size.height)];
        _pinCodeLabel.text = NSLocalizedString(@"3 4 5 6", nil);
        _pinCodeLabel.font = SLConstantsDefaultFont;
        _pinCodeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_pinCodeLabel];
    }
    
    return _pinCodeLabel;
}

- (UIButton *)autoUnlockButton
{
    if (!_autoUnlockButton) {
        _autoUnlockButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       self.bounds.size.width - 2*self.xPaddingScaler,
                                                                       .2*self.bounds.size.height)];
        [_autoUnlockButton addTarget:self
                              action:@selector(autoUnlockButtonPressed)
                    forControlEvents:UIControlEventTouchDown];
        [_autoUnlockButton setTitle:NSLocalizedString(@"Auto Unlock", nil)
                           forState:UIControlStateNormal];
        [_autoUnlockButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _autoUnlockButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:_autoUnlockButton];
    }
    
    return _autoUnlockButton;
}

- (void)layoutSubviews
{
    self.pinCodeTitleLabel.frame = CGRectMake(self.xPaddingScaler*self.bounds.size.width,
                                              0.0f,
                                              self.pinCodeTitleLabel.bounds.size.width,
                                              self.pinCodeTitleLabel.bounds.size.height);
    
    self.pinCodeInfoLabel.frame = CGRectMake(self.pinCodeTitleLabel.frame.origin.x,
                                             CGRectGetMaxY(self.pinCodeInfoLabel.frame),
                                             self.pinCodeInfoLabel.frame.size.width,
                                             self.pinCodeInfoLabel.frame.size.height);
    
    self.setPinTitleLabel.frame = CGRectMake(0.0f,
                                             CGRectGetMaxY(self.pinCodeInfoLabel.frame),
                                             self.setPinTitleLabel.frame.size.width,
                                             self.setPinTitleLabel.frame.size.height);
    
    self.pinCodeLabel.frame = CGRectMake(0.0f,
                                         CGRectGetMaxY(self.setPinTitleLabel.frame),
                                         self.pinCodeLabel.frame.size.width,
                                         self.pinCodeLabel.frame.size.height);
    
    self.autoUnlockButton.frame = CGRectMake(self.pinCodeTitleLabel.frame.origin.x,
                                             CGRectGetMaxY(self.pinCodeLabel.frame),
                                             self.autoUnlockButton.frame.size.width,
                                             self.autoUnlockButton.frame.size.height);
}

- (void)autoUnlockButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(settingEmergencyView:autoUnlockState:)]) {
        [self.delegate settingEmergencyView:self autoUnlockState:self.autoUnlockButton.isSelected];
    }
}

@end
