//
//  SLLockInfoViewController.m
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewController.h"
#import "SLLock.h"
#import "SLConstants.h"
#import "SLLockManager.h"
//#import "SLSettingsViewController.h"
#import "SLNavigationViewController.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"

#define kSLLockInfoViewControllerPadding            12.0f
#define kSLLockInfoViewControllerButtonLabelFont    [UIFont fontWithName:@"Roboto-Regular" size:10.0f]
#define kSLLockInfoViewControllerLabelColor         [UIColor colorWithRed:128 green:128 blue:128]

@interface SLLockInfoViewController()

@property (nonatomic, strong) UILabel *lockNameLabel;
@property (nonatomic, strong) UIImageView *batteryImageView;
@property (nonatomic, strong) UIImageView *wifiImageView;
@property (nonatomic, strong) UIImageView *cellSignalImageView;
@property (nonatomic, strong) UIButton *arrowButton;
@property (nonatomic, assign) CGFloat bottomHeight;

@property (nonatomic, strong) UIButton *crashButton;
@property (nonatomic, strong) UIButton *securityButton;
@property (nonatomic, strong) UIButton *sharingButton;

@property (nonatomic, strong) UILabel *crashLabel;
@property (nonatomic, strong) UILabel *securityLabel;
@property (nonatomic, strong) UILabel *sharingLabel;

@property (nonatomic, strong) UIButton *lockButton;

@end


@implementation SLLockInfoViewController

- (UILabel *)lockNameLabel
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_lockNameLabel) {
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:13.0f];
        CGSize maxSize = CGSizeMake(.5*self.view.bounds.size.width, CGFLOAT_MAX);
        CGSize size = [self.lock.name sizeWithFont:font maxSize:maxSize];
        _lockNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   size.width,
                                                                   size.height)];
        _lockNameLabel.text = self.lock.name;
        _lockNameLabel.font = font;
        [self.view addSubview:_lockNameLabel];
    }
    
    return _lockNameLabel;
}

- (UIImageView *)batteryImageView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_batteryImageView) {
        _batteryImageView = [[UIImageView alloc] initWithImage:[self batteryImage]];
        [self.view addSubview:_batteryImageView];
    }

    return _batteryImageView;
}

- (UIImageView *)cellSignalImageView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (_cellSignalImageView) {
        _cellSignalImageView = [[UIImageView alloc] initWithImage:[self cellSignalImage]];
        [self.view addSubview:_cellSignalImageView];
    }
    
    return _cellSignalImageView;
}

- (UIImageView *)wifiImageView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (!_wifiImageView) {
        _wifiImageView = [[UIImageView alloc] initWithImage:[self wifiImage]];
        [self.view addSubview:_wifiImageView];
    }
    
    return _wifiImageView;
}

- (UIButton *)arrowButton
{
    if (!_arrowButton) {
        UIImage *image = [UIImage imageNamed:@"icon_chevron_down"];
        _arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  2*image.size.width,
                                                                  2*image.size.height)];
        [_arrowButton addTarget:self
                         action:@selector(arrowButtonPressed)
               forControlEvents:UIControlEventTouchDown];
        [_arrowButton setImage:image forState:UIControlStateNormal];

        [self.view addSubview:_arrowButton];
    }
    
    return _arrowButton;
}

- (UIButton *)crashButton
{
    if (!_crashButton) {
        _crashButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_crashButton addTarget:self
                         action:@selector(crashButtonPressed:)
               forControlEvents:UIControlEventTouchDown];
        [_crashButton setImage:[UIImage imageNamed:@"btn_crashalert_on"]
                      forState:UIControlStateSelected];
        [_crashButton setImage:[UIImage imageNamed:@"btn_crashalert_off"]
                      forState:UIControlStateNormal];
        _crashButton.selected = self.lock.isCrashOn.boolValue;
        
        [self.view addSubview:_crashButton];
    }
    
    return _crashButton;
}

- (UIButton *)securityButton
{
    if (!_securityButton) {
        _securityButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_securityButton addTarget:self
                            action:@selector(securityButtonPressed:)
                  forControlEvents:UIControlEventTouchDown];
        [_securityButton setImage:[UIImage imageNamed:@"btn_theftalert_on"]
                         forState:UIControlStateSelected];
        [_securityButton setImage:[UIImage imageNamed:@"btn_theftalert_off"]
                         forState:UIControlStateNormal];
        _securityButton.selected = self.lock.isSecurityOn.boolValue;
        
        [self.view addSubview:_securityButton];
    }
    
    return _securityButton;
}

- (UIButton *)sharingButton
{
    if (!_sharingButton) {
        _sharingButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_sharingButton addTarget:self
                           action:@selector(sharingButtonPressed:)
                 forControlEvents:UIControlEventTouchDown];
        [_sharingButton setImage:[UIImage imageNamed:@"btn_sharing_on"]
                        forState:UIControlStateSelected];
        [_sharingButton setImage:[UIImage imageNamed:@"btn_sharing_off"]
                        forState:UIControlStateNormal];
        _sharingButton.selected = self.lock.isSharingOn.boolValue;
        
        [self.view addSubview:_sharingButton];
    }
    
    return _sharingButton;
}

- (UILabel *)crashLabel
{
    if (!_crashLabel) {
        NSString *text = NSLocalizedString(@"Crash Alert", nil);
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGSize size = [text sizeWithFont:kSLLockInfoViewControllerButtonLabelFont maxSize:maxSize];
        _crashLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        _crashLabel.text = text;
        _crashLabel.textAlignment = NSTextAlignmentCenter;
        _crashLabel.font = kSLLockInfoViewControllerButtonLabelFont;
        _crashLabel.textColor = kSLLockInfoViewControllerLabelColor;
        
        [self.view addSubview:_crashLabel];
    }
    
    return _crashLabel;
}

- (UILabel *)securityLabel
{
    if (!_securityLabel) {
        NSString *text = NSLocalizedString(@"Theft Alert", nil);
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGSize size = [text sizeWithFont:kSLLockInfoViewControllerButtonLabelFont maxSize:maxSize];
        _securityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        _securityLabel.text = text;
        _securityLabel.textAlignment = NSTextAlignmentCenter;
        _securityLabel.font = kSLLockInfoViewControllerButtonLabelFont;
        _securityLabel.textColor = kSLLockInfoViewControllerLabelColor;
        
        [self.view addSubview:_securityLabel];
    }
    
    return _securityLabel;
}

- (UILabel *)sharingLabel
{
    if (!_sharingLabel) {
        NSString *text = NSLocalizedString(@"Sharing", nil);
        CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CGSize size = [text sizeWithFont:kSLLockInfoViewControllerButtonLabelFont maxSize:maxSize];
        _sharingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
        _sharingLabel.text = text;
        _sharingLabel.textAlignment = NSTextAlignmentCenter;
        _sharingLabel.font = kSLLockInfoViewControllerButtonLabelFont;
        _sharingLabel.textColor = kSLLockInfoViewControllerLabelColor;
        
        [self.view addSubview:_sharingLabel];
    }
    
    return _sharingLabel;
}

- (UIButton *)lockButton
{
    if (!_lockButton) {
        UIImage *normalImage = [UIImage imageNamed:@"btn_lock"];
        UIImage *selectedImage = [UIImage imageNamed:@"btn_unlock"];
        _lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 normalImage.size.width,
                                                                 normalImage.size.height)];
        [_lockButton addTarget:self
                        action:@selector(lockButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        
        [_lockButton setImage:normalImage forState:UIControlStateNormal];
        [_lockButton setImage:selectedImage forState:UIControlStateSelected];
        _lockButton.backgroundColor = SLConstantsLightTeal;
        _lockButton.selected = NO;
        
        [self.view addSubview:_lockButton];
    }
    
    return _lockButton;
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = SLConstantsViewCornerRadius1;
    self.view.clipsToBounds = YES;
    
    self.bottomHeight = -1.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat xCenter = kSLLockInfoViewControllerPadding + .5*self.lockNameLabel.bounds.size.height;
    self.lockNameLabel.frame = CGRectMake(kSLLockInfoViewControllerPadding,
                                          xCenter -.5*self.lockNameLabel.bounds.size.height,
                                          self.lockNameLabel.bounds.size.width,
                                          self.lockNameLabel.bounds.size.height);
    self.batteryImageView.frame = CGRectMake(97.0f,
                                             xCenter -.5*self.batteryImageView.bounds.size.height,
                                             self.batteryImageView.bounds.size.width,
                                             self.batteryImageView.bounds.size.height);
    
    self.wifiImageView.frame = CGRectMake(self.view.bounds.size.width - 118.0f,
                                          xCenter -.5*self.wifiImageView.bounds.size.height,
                                          self.wifiImageView.bounds.size.width,
                                          self.wifiImageView.bounds.size.height);
    
    self.arrowButton.frame = CGRectMake(self.view.bounds.size.width - kSLLockInfoViewControllerPadding - self.arrowButton.bounds.size.width,
                                        xCenter -.5*self.arrowButton.bounds.size.height,
                                        self.arrowButton.bounds.size.width,
                                        self.arrowButton.bounds.size.height);
    
    self.crashButton.frame = CGRectMake(kSLLockInfoViewControllerPadding,
                                        53.0f,
                                        self.crashButton.bounds.size.width,
                                        self.crashButton.bounds.size.height);
    
    self.securityButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.securityButton.bounds.size.width),
                                        53.0f,
                                        self.securityButton.bounds.size.width,
                                        self.securityButton.bounds.size.height);
    
    self.sharingButton.frame = CGRectMake(self.view.bounds.size.width - self.sharingButton.bounds.size.width - kSLLockInfoViewControllerPadding,
                                          53.0f,
                                          self.sharingButton.bounds.size.width,
                                          self.sharingButton.bounds.size.height);
    
    self.crashLabel.frame = CGRectMake(CGRectGetMidX(self.crashButton.frame) - .5*self.crashLabel.bounds.size.width,
                                       CGRectGetMaxY(self.crashButton.frame) + 10.0f,
                                       self.crashLabel.bounds.size.width,
                                       self.crashLabel.bounds.size.height);
    
    self.securityLabel.frame = CGRectMake(CGRectGetMidX(self.securityButton.frame) - .5*self.securityLabel.bounds.size.width,
                                       CGRectGetMaxY(self.securityButton.frame) + 10.0f,
                                       self.securityLabel.bounds.size.width,
                                       self.securityLabel.bounds.size.height);
    
    self.sharingLabel.frame = CGRectMake(CGRectGetMidX(self.sharingButton.frame) - .5*self.sharingLabel.bounds.size.width,
                                          CGRectGetMaxY(self.sharingButton.frame) + 10.0f,
                                          self.sharingLabel.bounds.size.width,
                                          self.sharingLabel.bounds.size.height);
    
    self.lockButton.frame = CGRectMake(kSLLockInfoViewControllerPadding,
                                       self.view.bounds.size.height - self.lockButton.bounds.size.height - kSLLockInfoViewControllerPadding,
                                       self.lockButton.bounds.size.width,
                                       self.lockButton.bounds.size.height);
}

- (void)addSubView:(UIView *)view
{
    BOOL hasView = NO;
    for (UIView *subview in self.view.subviews) {
        if (view == subview) {
            hasView = YES;
            break;
        }
    }
    
    if (!hasView) {
        [self.view addSubview:view];
    }
}

- (void)handleAction:(SLLockInfoViewControllerAction)action
{
    if ([self.delegate respondsToSelector:@selector(lockInfoViewController:action:)]) {
        [self.delegate lockInfoViewController:self action:action];
    }
}

- (void)arrowButtonPressed
{
    
}

- (UIImage *)batteryImage
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *imageName;
    switch (self.lock.batteryState) {
        case SLLockBatteryStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockBatteryState1:
            imageName = @"icon_battery_0";
            break;
        case SLLockBatteryState2:
            imageName = @"icon_battery_25";
            break;
        case SLLockBatteryState3:
            imageName = @"icon_battery_33";
            break;
        case SLLockBatteryState4:
            imageName = @"icon_battery_50";
            break;
        case SLLockBatteryState5:
            imageName = @"icon_battery_66";
            break;
        case SLLockBatteryState6:
            imageName = @"icon_battery_75";
            break;
        case SLLockBatteryState7:
            imageName = @"icon_battery_100";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (UIImage *)cellSignalImage
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *imageName;
    switch (self.lock.wifiState) {
        case SLLockWifiSignalStateNone:
            // should set default image state here when we get assests
            imageName = nil;
            break;
        case SLLockWifiSignalState1:
            imageName = @"icon_wifi_1";
            break;
        case SLLockWifiSignalState2:
            imageName = @"icon_wifi_2";
            break;
        case SLLockWifiSignalState3:
            imageName = @"icon_wifi_3";
            break;
        case SLLockWifiSignalState4:
            imageName = @"icon_wifi_4";
            break;
        case SLLockWifiSignalState5:
            imageName = @"icon_wifi_5";
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (CGRect)initialButtonFrame
{
    UIImage *buttonImage = [UIImage imageNamed:@"btn_crashalert_on"];
    return CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
}

- (CGRect)crashButtonFrame
{
    return self.crashButton.frame;
}

- (CGRect)crashLabelFrame
{
    return self.crashLabel.frame;
}

- (CGRect)securityButtonFrame
{
    return self.securityButton.frame;
}

- (CGRect)securityLabelFrame
{
    return self.securityLabel.frame;
}

- (CGRect)sharingButtonFrame
{
    return self.sharingButton.frame;
}

- (CGRect)sharingLabelFrame
{
    return self.sharingLabel.frame;
}

//#pragma mark - SLLockInfoViewHeaderDelegate Methods
//- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView
//{
//    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    
////    SLSettingsViewController *svc = [SLSettingsViewController new];
////    svc.lock = self.lock;
////    
////    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:svc];
////
////    [self presentViewController:navController animated:YES completion:nil];
//}

#pragma mark - SLLockInfoMiddleView Delegate Methods
- (void)crashButtonPressed:(UIButton *)button
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    button.selected = !button.selected;
    self.lock.isCrashOn = @(button.isSelected);
    [SLLockManager.manager toggleCrashForLock:self.lock];
}

- (void)securityButtonPressed:(UIButton *)button
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    button.selected = !button.selected;
    self.lock.isSecurityOn = @(button.isSelected);
    [SLLockManager.manager toggleSecurityForLock:self.lock];
}

- (void)sharingButtonPressed:(UIButton *)button
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    button.selected = !button.selected;
    self.lock.isSharingOn = @(button.isSelected);
    //[SLLockManager.manager toggleSharignForLock:self.lock];
}

#pragma mark - SLLockInfoBottomView Delegate Methods
- (void)lockButtonPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
@end
