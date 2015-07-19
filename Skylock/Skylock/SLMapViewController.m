//
//  SLMapViewController.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMapViewController.h"
#import "SLSlideViewController.h"
#import "SLLocationManager.h"
#import "SLLockInfoViewController.h"
#import "SLConstants.h"
#import "SLLockManager.h"
#import "SLCoachMarkViewController.h"
#import "SLUserDefaults.h"
#import "SLDropDownLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "SLDatabaseManager.h"
#import "UIColor+RGB.h"
#import <MapboxGL/MapboxGL.h>

#import <CoreLocation/CoreLocation.h>



#define kMapBoxMapId        @"michalumni.l2bh1bee"
#define kSLMapViewControllerLockInfoViewWidth 295.0f
#define kSLMapViewControllerLockInfoViewLargeHeight 217.0f
#define kSLMapViewControllerLockInfoViewSmallHeight 110.0f

@interface SLMapViewController ()

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) SLLocationManager *locationManager;
@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;
@property (nonatomic, strong) MGLMapView *mapView;

@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) MGLPointAnnotation *userPoint;
@property (nonatomic, strong) MGLPointAnnotation *lockPoint;

@end

@implementation SLMapViewController

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        UIColor *color = [UIColor colorWithRed:51 green:51 blue:51];
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.userInteractionEnabled = YES;
        _touchStopperView.backgroundColor = [color colorWithAlphaComponent:.8f];
    }
    
    return _touchStopperView;
}

- (UIButton *)menuButton
{
    if (!_menuButton) {
        UIImage *menuButtonImage = [UIImage imageNamed:@"icon_menu"];
        _menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 2*menuButtonImage.size.width,
                                                                 2*menuButtonImage.size.height)];
        [_menuButton setImage:menuButtonImage forState:UIControlStateNormal];
        [_menuButton addTarget:self
                        action:@selector(menuButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_menuButton];
    }
    
    return _menuButton;
}

- (MGLMapView *)mapView
{
    if (!_mapView) {
       // NSURL *url = [NSURL URLWithString:@"mapbox://michalumni.l2bh1bee"];
        _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(37.761927, -122.421165)];
        _mapView.zoomLevel = 9;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.showsUserLocation = YES;
    }
    
    return _mapView;
}

- (void)viewDidLoad {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    [SLDatabaseManager.manager setCurrentUser];
    
    [self.view addSubview:self.mapView];

    CGFloat padding = .5*(self.view.bounds.size.width - kSLMapViewControllerLockInfoViewWidth);
    self.lockInfoLargeFrame =  CGRectMake(padding,
                                          self.view.bounds.size.height - kSLMapViewControllerLockInfoViewLargeHeight - padding,
                                          kSLMapViewControllerLockInfoViewWidth,
                                          kSLMapViewControllerLockInfoViewLargeHeight);
    
    self.lockInfoSmallFrame = CGRectMake(padding,
                                         self.lockInfoLargeFrame.origin.y + kSLMapViewControllerLockInfoViewLargeHeight - kSLMapViewControllerLockInfoViewSmallHeight ,
                                         kSLMapViewControllerLockInfoViewWidth,
                                         kSLMapViewControllerLockInfoViewSmallHeight);
    
    self.menuButton.frame = CGRectMake(15.0f,
                                       30.0f,
                                       self.menuButton.bounds.size.width,
                                       self.menuButton.bounds.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.mapView]) {
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [SLLockManager.manager fetchLocks];
    [self.view addSubview:self.touchStopperView];
    
    static CGFloat width = 127.0f;
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
                                     slvc.view.bounds.size.height);
    } completion:nil];
}
- (void)removeSlideViewController:(SLSlideViewController *)slvc shouldPresentLockInfoVCWithLock:(SLLock *)lock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    livc.delegate = self;
    
    
    livc.view.frame = CGRectMake(self.lockInfoLargeFrame.origin.x,
                                 self.view.bounds.size.height,
                                 self.lockInfoLargeFrame.size.width,
                                 self.lockInfoLargeFrame.size.height);
    
    [self addChildViewController:livc];
    [self.view addSubview:livc.view];
    [self.view bringSubviewToFront:livc.view];
    [livc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        livc.view.frame = self.lockInfoLargeFrame;
    } completion:^(BOOL finished) {
        if (finished) {
            [self presentCoachMarkViewController];
        }
    }];
}

- (void)removeLockInfoViewController:(SLLockInfoViewController *)livc withCompletion:(void(^)(void))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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

- (void)presentCoachMarkViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLCoachMarkViewController *cmvc = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:SLUserDefaultsCoachMarksComplete]) {
        NSNumber *complete = [ud objectForKey:SLUserDefaultsCoachMarksComplete];
        if (!complete.boolValue) {
            cmvc = [SLCoachMarkViewController new];
        }
    } else {
        cmvc = [SLCoachMarkViewController new];
    }
    
    if (cmvc) {
        cmvc.delegate = self;
        cmvc.buttonPositions = self.coachMarkParameters;

        cmvc.view.frame = self.view.bounds;
        cmvc.view.alpha = 0.0f;
        
        [self addChildViewController:cmvc];
        [self.view addSubview:cmvc.view];
        [self.view bringSubviewToFront:cmvc.view];
        [cmvc didMoveToParentViewController:self];
        
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            cmvc.view.alpha = 1.0f;
        }];
    }
}

- (NSDictionary *)coachMarkParameters
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLLockInfoViewController *livc;
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isMemberOfClass:[SLLockInfoViewController class]]) {
            livc = (SLLockInfoViewController *)vc;
            break;
        }
    }
    
    NSDictionary *params;
    if (livc) {
        static NSString *button = @"button";
        static NSString *label = @"label";
        
        CGRect crashButtonFrame = [self.view convertRect:livc.crashButtonFrame
                                                fromView:livc.view];
        CGRect crashLabelFrame = [self.view convertRect:livc.crashLabelFrame
                                               fromView:livc.view];
        CGRect securityButtonFrame = [self.view convertRect:livc.securityButtonFrame
                                                   fromView:livc.view];
        CGRect securityLabelFrame = [self.view convertRect:livc.securityLabelFrame
                                                  fromView:livc.view];
        CGRect sharingButtonFrame = [self.view convertRect:livc.sharingButtonFrame
                                                  fromView:livc.view];
        CGRect sharingLabelFrame = [self.view convertRect:livc.sharingLabelFrame
                                                 fromView:livc.view];
        
        params = @{@(SLCoachMarkPageCrash):@{button:[NSValue valueWithCGRect:crashButtonFrame],
                                             label:[NSValue valueWithCGRect:crashLabelFrame]
                                             },
                   @(SLCoachMarkPageSharing):@{button:[NSValue valueWithCGRect:sharingButtonFrame],
                                               label:[NSValue valueWithCGRect:sharingLabelFrame]
                                               },
                   @(SLCoachMarkPageTheft):@{button:[NSValue valueWithCGRect:securityButtonFrame],
                                             label:[NSValue valueWithCGRect:securityLabelFrame]
                                             }
                   };
    }
    
    return params;
}

#pragma mark - SLSlideViewController Delegate Methods
- (void)slideViewController:(SLSlideViewController *)slvc
               buttonPushed:(SLSlideViewControllerButtonAction)action
                    options:(NSDictionary *)options
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (action == SLSlideViewControllerButtonActionLockSelected && options) {
        [self removeSlideViewController:slvc shouldPresentLockInfoVCWithLock:options[@"lock"]];
    }
}

#pragma mark - SLCoachMarkViewController Delegate Methods
- (void)coachMarkViewControllerDoneButtonPressed:(SLCoachMarkViewController *)cmvc
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        cmvc.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [cmvc.view removeFromSuperview];
        [cmvc removeFromParentViewController];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:@(YES) forKey:SLUserDefaultsCoachMarksComplete];
        [ud synchronize];
    }];
}

#pragma mark - SLInfoViewController Delegate Methods
- (void)lockInfoViewController:(SLLockInfoViewController *)livc shouldIncreaseSize:(BOOL)shouldIncreaseSize
{
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        livc.view.frame = shouldIncreaseSize ? self.lockInfoLargeFrame : self.lockInfoSmallFrame;
    }];
}

#pragma mark - MGL map view delegate methods

- (void)mapViewWillStartLocatingUser:(MGLMapView * __nonnull)mapView
{
    
}

- (void)mapV
@end
