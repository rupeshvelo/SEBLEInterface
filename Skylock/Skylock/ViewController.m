//
//  ViewController.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "ViewController.h"
#import "Mapbox.h"
#import "SLSlideViewController.h"
#import "SLLocationManager.h"
#import <QuartzCore/QuartzCore.h>

#define kMapBoxAccessToken @"pk.eyJ1IjoibWljaGFsdW1uaSIsImEiOiJ0c2Npd05jIn0.XAWOLTQKEupL-bGoCSH4GA#3"
#define kMapBoxMapId @"michalumni.l2bh1bee"

@interface ViewController ()

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *showSlideControllerButton;
@property (nonatomic, strong) SLLocationManager *locationManager;

@end

@implementation ViewController

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.userInteractionEnabled = YES;
    }
    
    return _touchStopperView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[RMConfiguration sharedInstance] setAccessToken:kMapBoxAccessToken];
    
    RMMapboxSource *source = [[RMMapboxSource alloc] initWithMapID:kMapBoxMapId];
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:source];
    mapView.zoom = 5;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(37.761927, -122.421165);
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
//    self.locationManager = [SLLocationManager new];
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.persmissionState = SLLocationManagerPermissionStateDenied;
    
    self.showSlideControllerButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.showSlideControllerButton.backgroundColor = [UIColor purpleColor];
    [self.showSlideControllerButton addTarget:self
                                       action:@selector(slideControllerButtonPressed)
                             forControlEvents:UIControlEventTouchDown];
    self.showSlideControllerButton.layer.cornerRadius = .5*self.showSlideControllerButton.bounds.size.width;
    self.showSlideControllerButton.clipsToBounds = YES;
    
    [self.view addSubview:self.showSlideControllerButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    static CGFloat buttonScaler = 1.2f;
    self.showSlideControllerButton.frame = CGRectMake(self.view.bounds.size.width - buttonScaler*self.showSlideControllerButton.bounds.size.width,
                                                      buttonScaler*self.showSlideControllerButton.bounds.size.height,
                                                      self.showSlideControllerButton.bounds.size.width,
                                                      self.showSlideControllerButton.bounds.size.height);
}

- (void)slideControllerButtonPressed
{
    [self.view addSubview:self.touchStopperView];
    
    static CGFloat xSpacer = .8f;
    CGFloat width = xSpacer*self.view.bounds.size.width;
    SLSlideViewController *slvc = [SLSlideViewController new];
    slvc.delegate = self;
    slvc.view.frame = CGRectMake(-width,
                                0.0f,
                                width,
                                self.view.bounds.size.height);
    
    [self addChildViewController:slvc];
    [self.view addSubview:slvc.view];
    [self.view bringSubviewToFront:slvc.view];
    [slvc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.35 animations:^{
        slvc.view.frame = CGRectMake(0.0f,
                                     0.0f,
                                     width,
                                     self.view.bounds.size.height);
    } completion:nil];
}

- (void)slideViewController:(SLSlideViewController *)slvc buttonPushed:(SLSlideViewControllerButtonAction)action
{
    [UIView animateWithDuration:.35 animations:^{
        slvc.view.frame = CGRectMake(-slvc.view.bounds.size.width,
                                     0.0f,
                                     slvc.view.bounds.size.width,
                                     slvc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [slvc.view removeFromSuperview];
        [slvc removeFromParentViewController];
        [self.touchStopperView removeFromSuperview];
    }];

}
@end
