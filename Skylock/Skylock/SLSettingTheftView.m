//
//  SLSettingTheftView.m
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSettingTheftView.h"
#import "SLConstants.h"

@interface SLSettingTheftView()

@property (nonatomic, strong) UILabel *theftTitleLabel;
@property (nonatomic, strong) UISwitch *alertSwitch;
@property (nonatomic, strong) UILabel *theftInfoLabel;
@property (nonatomic, strong) UILabel *sensitivityLabel;
@property (nonatomic, strong) UISlider *sensitivitySlider;
@property (nonatomic, strong) UILabel *sensitivityInfoLabel;

@end

@implementation SLSettingTheftView

- (UILabel *)theftTitleLabel
{
    if (!_theftTitleLabel) {
        _theftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     .75*self.bounds.size.width - 2*self.xPaddingScaler*self.bounds.size.width,
                                                                     .25*self.bounds.size.height)];
        _theftTitleLabel.text = NSLocalizedString(@"Theft Alert", nil);
        _theftTitleLabel.font = SLConstantsDefaultFont;
        [self addSubview:_theftTitleLabel];
    }
    
    return _theftTitleLabel;
}

- (UISwitch *)alertSwitch
{
    if (!_alertSwitch) {
        _alertSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  100.0f,
                                                                  .25*self.bounds.size.height)];
        [_alertSwitch addTarget:self
                         action:@selector(alertSwitchValueChanged)
               forControlEvents:UIControlEventValueChanged];
        _alertSwitch.onTintColor = SLConstantsSwitchTeal;
        [self addSubview:_alertSwitch];
    }
    
    return _alertSwitch;
}

- (UILabel *)theftInfoLabel
{
    if (!_theftInfoLabel) {
        NSString *info = @"Theft alerts are sent when tampering or vibrations on a lock are detected.";
        _theftInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.bounds.size.width - 2*self.xPaddingScaler*self.bounds.size.width,
                                                                    .25*self.bounds.size.height)];
        _theftInfoLabel.text = NSLocalizedString(info, nil);
        _theftInfoLabel.font = SLConstantsDefaultFont;
        _theftInfoLabel.numberOfLines = 0;
        [self addSubview:_theftInfoLabel];
    }
    
    return _theftInfoLabel;
}

- (UILabel *)sensitivityLabel
{
    if (!_sensitivityLabel) {
        _sensitivityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      .25*self.bounds.size.width,
                                                                      .25*self.bounds.size.height)];
        _sensitivityLabel.text = NSLocalizedString(@"Sensitivity", nil);
        _sensitivityLabel.font = SLConstantsDefaultFont;
        [self addSubview:_sensitivityLabel];
    }
    
    return _sensitivityLabel;
}

- (UISlider *)sensitivitySlider
{
    if (!_sensitivitySlider) {
        _sensitivitySlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        .5*self.bounds.size.width,
                                                                        .25*self.bounds.size.height)];
        [_sensitivitySlider addTarget:self
                               action:@selector(sensitivitySliderValueChanged)
                     forControlEvents:UIControlEventValueChanged];
        _sensitivitySlider.minimumValue = 0.0;
        _sensitivitySlider.maximumValue = 100.0;
        [self addSubview:_sensitivitySlider];
    }
    
    return _sensitivitySlider;
}

- (UILabel *)sensitivityInfoLabel
{
    if (!_sensitivityInfoLabel) {
        NSString *info = @"Medium sensitivity (recommended) is a balanced approach to security. Prolonged lock motion will trigger an alert.";
        _sensitivityInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          self.bounds.size.width - 2*self.xPaddingScaler*self.bounds.size.width,
                                                                          .25*self.bounds.size.height)];
        _sensitivityInfoLabel.text = NSLocalizedString(info, nil);
        _sensitivityInfoLabel.font = SLConstantsDefaultFont;
        _sensitivityInfoLabel.numberOfLines = 0;
        [self addSubview:_sensitivityInfoLabel];
    }
    
    return _sensitivityInfoLabel;
}

- (void)layoutSubviews
{
    CGFloat xPadding = self.xPaddingScaler*self.bounds.size.width;
    self.theftTitleLabel.frame = CGRectMake(xPadding,
                                            0.0f,
                                            self.theftTitleLabel.frame.size.width,
                                            self.theftTitleLabel.frame.size.height);
    
    self.alertSwitch.frame = CGRectMake(self.bounds.size.width - xPadding - self.alertSwitch.bounds.size.width,
                                        .5*(self.theftTitleLabel.frame.size.height - self.alertSwitch.bounds.size.height),
                                        self.alertSwitch.bounds.size.width,
                                        self.alertSwitch.bounds.size.height);
    
    self.theftInfoLabel.frame = CGRectMake(xPadding,
                                           CGRectGetMaxY(self.theftTitleLabel.frame),
                                           self.theftInfoLabel.frame.size.width,
                                           self.theftInfoLabel.frame.size.height);
    
    self.sensitivityLabel.frame = CGRectMake(xPadding,
                                             CGRectGetMaxY(self.theftInfoLabel.frame),
                                             self.sensitivityLabel.frame.size.width,
                                             self.sensitivityLabel.frame.size.height);
    
    self.sensitivitySlider.frame = CGRectMake(self.bounds.size.width - xPadding - self.sensitivitySlider.frame.size.width,
                                              self.sensitivityLabel.frame.origin.y,
                                              self.sensitivitySlider.frame.size.width,
                                              self.sensitivitySlider.frame.size.height);
    
    self.sensitivityInfoLabel.frame = CGRectMake(xPadding,
                                                 CGRectGetMaxY(self.sensitivityLabel.frame),
                                                 self.sensitivityInfoLabel.frame.size.width,
                                                 self.sensitivityInfoLabel.frame.size.height);
}

- (void)alertSwitchValueChanged
{
    if ([self.delegate respondsToSelector:@selector(settingTheftView:alertSwitchValueChangedTo:)]) {
        [self.delegate settingTheftView:self alertSwitchValueChangedTo:self.alertSwitch.isOn];
    }
}

- (void)sensitivitySliderValueChanged
{
    if ([self.delegate respondsToSelector:@selector(settingTheftView:sensitivityValueChangedTo:)]) {
        [self.delegate settingTheftView:self sensitivityValueChangedTo:@(self.sensitivitySlider.value)];
    }
}
@end
