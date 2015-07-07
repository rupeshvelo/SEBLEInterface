//
//  SLMapViewController.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMapViewController.h"
#import "Mapbox.h"
#import "SLSlideViewController.h"
#import "SLLocationManager.h"
#import "SLLockInfoViewController.h"
#import "SLConstants.h"
#import "SLLockManager.h"
#import <QuartzCore/QuartzCore.h>

#define kMapBoxAccessToken  @"pk.eyJ1IjoibWljaGFsdW1uaSIsImEiOiJ0c2Npd05jIn0.XAWOLTQKEupL-bGoCSH4GA#3"
#define kMapBoxMapId        @"michalumni.l2bh1bee"

@interface SLMapViewController ()

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) SLLocationManager *locationManager;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;

@end

@implementation SLMapViewController

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.userInteractionEnabled = YES;
        _touchStopperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.85f];
    }
    
    return _touchStopperView;
}

- (UIButton *)menuButton
{
    if (!_menuButton) {
        UIImage *menuButtonImage = [UIImage imageNamed:@"menu-button"];
        self.menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     menuButtonImage.size.width,
                                                                     menuButtonImage.size.height)];
        [self.menuButton setImage:menuButtonImage forState:UIControlStateNormal];
        [self.menuButton addTarget:self
                            action:@selector(menuButtonPressed)
                  forControlEvents:UIControlEventTouchDown];
        self.menuButton.layer.cornerRadius = .5*self.menuButton.bounds.size.width;
        self.menuButton.clipsToBounds = YES;
    }
    
    return _menuButton;
}

- (void)viewDidLoad {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    [[RMConfiguration sharedInstance] setAccessToken:kMapBoxAccessToken];
    
    RMMapboxSource *source = [[RMMapboxSource alloc] initWithMapID:kMapBoxMapId];
    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:source];
    mapView.zoom = 5;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(37.761927, -122.421165);
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:mapView];
    
    [self.view addSubview:self.menuButton];
    
    [SLLockManager.manager createTestLocks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    
    self.menuButton.frame = CGRectMake(10.0f,
                                       20.0f,
                                       self.menuButton.bounds.size.width,
                                       self.menuButton.bounds.size.height);
}

- (void)menuButtonPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    BOOL showingInfoVC = NO;
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isMemberOfClass:[SLLockInfoViewController class]]) {
            SLLockInfoViewController *livc = (SLLockInfoViewController *)vc;
            __typeof(self) __weak weakSelf = self;
            [self removeLockInfoViewController:livc withCompletion:^{
                [weakSelf presentSlideViewController];
            }];
            
            showingInfoVC = YES;
            break;
        }
    }
    
    if (!showingInfoVC) {
        [self presentSlideViewController];
    }
}

- (void)slideViewController:(SLSlideViewController *)slvc buttonPushed:(SLSlideViewControllerButtonAction)action
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    
}

- (void)presentSlideViewController
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
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        slvc.view.frame = CGRectMake(0.0f,
                                     0.0f,
                                     width,
                                     self.view.bounds.size.height);
    } completion:nil];
}
- (void)removeSlideViewController:(SLSlideViewController *)slvc shouldPresentLockInfoVCWithLock:(SLLock *)lock
{
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        slvc.view.frame = CGRectMake(-slvc.view.bounds.size.width,
                                     0.0f,
                                     slvc.view.bounds.size.width,
                                     slvc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [slvc.view removeFromSuperview];
        [slvc removeFromParentViewController];
        [self.touchStopperView removeFromSuperview];
        if (lock) {
            [self presentLockInfoViewControllerWithLock:lock];
        }
    }];
}

- (void)presentLockInfoViewControllerWithLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
    SLLockInfoViewController *livc = [SLLockInfoViewController new];
    livc.lock = lock;
    
    static CGFloat xPadding = 10.0f;
    livc.view.frame = CGRectMake(xPadding,
                                 self.view.bounds.size.height,
                                 self.view.bounds.size.width - 2*xPadding,
                                 .4*self.view.bounds.size.height);
    [self addChildViewController:livc];
    [self.view addSubview:livc.view];
    [self.view bringSubviewToFront:livc.view];
    [livc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        livc.view.frame = CGRectMake(livc.view.frame.origin.x,
                                     self.view.bounds.size.height - livc.view.bounds.size.height - 5.0f,
                                     livc.view.bounds.size.width,
                                     livc.view.bounds.size.height);
    } completion:nil];
}

- (void)removeLockInfoViewController:(SLLockInfoViewController *)livc withCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        livc.view.frame = CGRectMake(0.0f,
                                     self.view.bounds.size.height,
                                     livc.view.bounds.size.width,
                                     livc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [livc.view removeFromSuperview];
        [livc removeFromParentViewController];
        [self.touchStopperView removeFromSuperview];
        
        if (completion) {
            completion();
        }
    }];
}
#pragma mark - SLSlideViewController Delegate Methods
- (void)slideViewController:(SLSlideViewController *)slvc
               buttonPushed:(SLSlideViewControllerButtonAction)action
                    options:(NSDictionary *)options
{
    if (action == SLSlideViewControllerButtonActionLockSelected && options) {
        [self removeSlideViewController:slvc shouldPresentLockInfoVCWithLock:options[@"lock"]];
    }
}
@end
