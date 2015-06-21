//
//  SLSettingsViewController.m
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSettingsViewController.h"
#import "SLSettingTheftView.h"
#import "SLSettingSharingView.h"
#import "SLSettingEmergencyView.h"
#import "SLNavigationViewController.h"
#import "SLLock.h"

#define kSLSettingViewControllerxPaddingScaler  .1f

@interface SLSettingsViewController ()

@property (nonatomic, strong) SLSettingTheftView *theftView;
@property (nonatomic, strong) SLSettingSharingView *sharingView;
@property (nonatomic, strong) SLSettingEmergencyView *emergencyView;

@end

@implementation SLSettingsViewController

- (SLSettingTheftView *)theftView
{
    if (!_theftView) {
        _theftView = [[SLSettingTheftView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          0.0f,
                                                                          self.view.bounds.size.width,
                                                                          .4*self.view.bounds.size.height)
                                                       andLock:self.lock
                                                xPaddingScaler:kSLSettingViewControllerxPaddingScaler
                                                yPaddingScaler:0.0f];
        [self.view addSubview:_theftView];
    }
    
    return _theftView;
}

- (SLSettingSharingView *)sharingView
{
    if (!_sharingView) {
        _sharingView = [[SLSettingSharingView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width,
                                                                             .15*self.view.bounds.size.height)
                                                           andLock:self.lock
                                                    xPaddingScaler:kSLSettingViewControllerxPaddingScaler
                                                    yPaddingScaler:0.0f];
        [self.view addSubview:_sharingView];
    }
    
    return _sharingView;
}

- (SLSettingEmergencyView *)emergencyView
{
    if (!_emergencyView) {
        CGFloat height = self.view.bounds.size.height - self.theftView.bounds.size.height - self.sharingView.bounds.size.height;
        _emergencyView = [[SLSettingEmergencyView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                  0.0f,
                                                                                  self.view.bounds.size.width,
                                                                                  height)
                                                               andLock:self.lock
                                                        xPaddingScaler:kSLSettingViewControllerxPaddingScaler
                                                        yPaddingScaler:0.0f];
        [self.view addSubview:_emergencyView];
    }
    
    return _emergencyView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.lock.name;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.theftView.frame = CGRectMake(0.0f,
                                      0.0f,
                                      self.theftView.frame.size.width,
                                      self.theftView.frame.size.height);
    
    self.sharingView.frame = CGRectMake(0.0f,
                                        CGRectGetMaxY(self.theftView.frame),
                                        self.sharingView.frame.size.width,
                                        self.sharingView.frame.size.height);
    
    
    self.emergencyView.frame = CGRectMake(0.0f,
                                          CGRectGetMaxY(self.sharingView.frame),
                                          self.emergencyView.frame.size.width,
                                          self.emergencyView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
