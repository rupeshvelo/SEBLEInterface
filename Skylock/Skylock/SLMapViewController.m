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
#import "SLPicManager.h"
#import "SLDbUser+Methods.h"
#import "SLLock.h"
#import "UIImage+Skylock.h"
#import "SLNavigationViewController.h"
#import "SLAccountInfoViewController.h"
#import <MapboxGL/MapboxGL.h>
#import <CoreLocation/CoreLocation.h>
#import "Skylock-Swift.h"
#import "SLSharingViewController.h"
#import "SLNotifications.h"
#import "SLNotificationViewController.h"
#import "SLMainTutorialViewController.h"
#import "SLDirectionsViewController.h"

#import <MapKit/MapKit.h>

#define kMapBoxMapId        @"michalumni.l2bh1bee"
#define kSLMapViewControllerLockInfoViewWidth 295.0f
#define kSLMapViewControllerLockInfoViewLargeHeight 217.0f
#define kSLMapViewControllerLockInfoViewSmallHeight 110.0f
#define kSLMapViewControllerLockInfoViewPadding     12.0f


@interface SLMapViewController ()

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *settingsButton;

@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;

@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) MGLPointAnnotation *userAnnotation;
@property (nonatomic, strong) MGLPointAnnotation *selectedLockAnnotation;

@property (nonatomic, strong) NSMutableDictionary *lockAnnotations;
@property (nonatomic, assign) BOOL isInitialLoad;

@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) SLNotificationViewController *notificationViewController;

@property (nonatomic, strong) SLLockInfoViewController *lockInfoViewController;

@property (nonatomic, strong) UIButton *leftCalloutButton;
@property (nonatomic, strong) UIButton *rightCalloutButton;
@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *directionsButton;

@property (nonatomic, strong) SLDirectionsViewController *directionsViewController;

@end

@implementation SLMapViewController

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        UITapGestureRecognizer *tgr = [UITapGestureRecognizer new];
        tgr.numberOfTapsRequired = 1;
        [tgr addTarget:self action:@selector(touchStopperViewTapped:)];
        
        UIColor *color = [UIColor colorWithRed:51 green:51 blue:51];
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.userInteractionEnabled = YES;
        _touchStopperView.backgroundColor = [color colorWithAlphaComponent:.8f];
        [_touchStopperView addGestureRecognizer:tgr];
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

- (UIButton *)settingsButton
{
    if (!_settingsButton) {
        UIImage *image = [UIImage imageNamed:@"icon_settings_large"];
        _settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     2*image.size.width,
                                                                     2*image.size.height)];
        [_settingsButton setImage:image forState:UIControlStateNormal];
        [_settingsButton addTarget:self
                            action:@selector(settingsButtonPressed)
                  forControlEvents:UIControlEventTouchDown];
        //_settingsButton.enabled = NO;
        [self.view addSubview:_settingsButton];
    }
    
    return _settingsButton;
}

- (MGLMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
        _mapView.zoomLevel = 12;
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.delegate = self;
        _mapView.rotateEnabled = NO;
    }
    
    return _mapView;
}

- (MGLPointAnnotation *)userAnnotation
{
    if (!_userAnnotation) {
        _userAnnotation = [MGLPointAnnotation new];
    }
    
    return _userAnnotation;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (SLLockInfoViewController *)lockInfoViewController
{
    if (!_lockInfoViewController) {
        _lockInfoViewController = [SLLockInfoViewController new];
        _lockInfoViewController.delegate = self;
    }
    
    return _lockInfoViewController;
}

- (UIButton *)leftCalloutButton
{
    if (!_leftCalloutButton) {
        UIImage *image = [UIImage imageNamed:@"icon_mylock_off"];
        _leftCalloutButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        image.size.width,
                                                                        image.size.height)];
        [_leftCalloutButton addTarget:self
                               action:@selector(leftCalloutViewButtonPressed)
                     forControlEvents:UIControlEventTouchDown];
        [_leftCalloutButton setImage:image forState:UIControlStateNormal];
        [_leftCalloutButton setImage:[UIImage imageNamed:@"icon_mylock_on"]
                            forState:UIControlStateSelected];
    }
    
    return _leftCalloutButton;
}

- (UIButton *)rightCalloutButton
{
    if (!_rightCalloutButton) {
        UIImage *image = [UIImage imageNamed:@"icon_navigate_off"];
        _rightCalloutButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        [_rightCalloutButton addTarget:self
                         action:@selector(rightCalloutViewButtonPressed)
               forControlEvents:UIControlEventTouchDown];
        [_rightCalloutButton setImage:image forState:UIControlStateNormal];
        [_rightCalloutButton setImage:[UIImage imageNamed:@"icon_navigate_on"]
                      forState:UIControlStateSelected];
    }
    
    return _rightCalloutButton;
}

- (UIButton *)locationButton
{
    if (!_locationButton) {
        UIImage *image = [UIImage imageNamed:@"icon_gps"];
        _locationButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     image.size.width,
                                                                     image.size.height)];
        [_locationButton addTarget:self
                            action:@selector(locationButtonPressed)
                  forControlEvents:UIControlEventTouchDown];
        [_locationButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_locationButton];
    }
    
    return _locationButton;
}

- (UIButton *)directionsButton
{
    if (!_directionsButton) {
        UIImage *image = [UIImage imageNamed:@"icon_directions_expand"];
        _directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       image.size.width,
                                                                       image.size.height)];
        [_directionsButton addTarget:self
                              action:@selector(presentDirectionsViewController)
                    forControlEvents:UIControlEventTouchDown];
        [_directionsButton setImage:image forState:UIControlStateNormal];
        _directionsButton.hidden = YES;
        [self.view addSubview:_directionsButton];
    }
    
    return _directionsButton;
}

- (SLDirectionsViewController *)directionsViewController
{
    if (!_directionsViewController) {
        _directionsViewController = [SLDirectionsViewController new];
        _directionsViewController.directions = self.directions;
        _directionsViewController.delegate = self;
        [self.view addSubview:_directionsButton];
    }
    
    return _directionsViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    [SLDatabaseManager.manager setCurrentUser];
    
    [self.locationManager requestWhenInUseAuthorization];
    
    self.lockAnnotations = [NSMutableDictionary new];
    self.isInitialLoad = YES;
    [self registerAlertNotifications];
    
    [self.view addSubview:self.mapView];
    
    CGFloat width = self.view.bounds.size.width - 2*kSLMapViewControllerLockInfoViewPadding;
    self.lockInfoLargeFrame =  CGRectMake(kSLMapViewControllerLockInfoViewPadding,
                                          self.view.bounds.size.height - kSLMapViewControllerLockInfoViewLargeHeight - kSLMapViewControllerLockInfoViewPadding,
                                          width,
                                          kSLMapViewControllerLockInfoViewLargeHeight);
    
    self.lockInfoSmallFrame = CGRectMake(kSLMapViewControllerLockInfoViewPadding,
                                         self.lockInfoLargeFrame.origin.y + kSLMapViewControllerLockInfoViewLargeHeight - kSLMapViewControllerLockInfoViewSmallHeight ,
                                         width,
                                         kSLMapViewControllerLockInfoViewSmallHeight);
    
    self.menuButton.frame = CGRectMake(15.0f,
                                       30.0f,
                                       self.menuButton.bounds.size.width,
                                       self.menuButton.bounds.size.height);
    
    self.settingsButton.frame = CGRectMake(self.view.bounds.size.width - self.settingsButton.bounds.size.width - 15.0f,
                                           CGRectGetMidY(self.menuButton.frame) - .5*self.settingsButton.bounds.size.height,
                                           self.settingsButton.bounds.size.width,
                                           self.settingsButton.bounds.size.height);
    
    self.locationButton.frame = CGRectMake(self.lockInfoSmallFrame.origin.x,
                                           self.lockInfoSmallFrame.origin.y - 1.5*self.locationButton.bounds.size.height,
                                           self.locationButton.bounds.size.width,
                                           self.locationButton.bounds.size.height);
    
    self.directionsButton.frame = CGRectMake(CGRectGetMaxX(self.lockInfoSmallFrame) - self.directionsButton.bounds.size.width,
                                             self.locationButton.frame.origin.y,
                                             self.directionsButton.bounds.size.width,
                                             self.directionsButton.bounds.size.height);
    
    self.lockInfoViewController.view.frame = self.lockInfoSmallFrame;
    [self addChildViewController:self.lockInfoViewController];
    [self.view addSubview:self.lockInfoViewController.view];
    [self.view bringSubviewToFront:self.lockInfoViewController.view];
    [self.lockInfoViewController didMoveToParentViewController:self];
}

- (void)registerAlertNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCrashAndTheftAlerts:)
                                                 name:kSLNotificationAlertOccured
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissAlert:)
                                                 name:kSLNotificationAlertDismissed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(presentEmergencyText:)
                                                 name:kSLNotificationSendEmergecyText
                                               object:nil];
}

- (void)menuButtonPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self presentSlideViewController];
}

- (void)settingsButtonPressed
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self presentSettingsViewController];
}

- (void)presentSlideViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [self.view addSubview:self.touchStopperView];
    
    static CGFloat width = 150.0f;
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

- (void)removeSlideViewController:(SLSlideViewController *)slvc withCompletion:(void(^)(void))completion
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
        
        if (completion) {
            completion();
        }
    }];
}

- (void)presentDirectionsViewController
{
    self.directionsViewController.view.frame = CGRectMake(self.view.bounds.size.width,
                                                          0.0f,
                                                          .4*self.view.bounds.size.width,
                                                          self.view.bounds.size.height);
    self.directionsViewController.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    
    [self addChildViewController:self.directionsViewController];
    [self.view addSubview:self.directionsViewController.view];
    [self.view bringSubviewToFront:self.directionsViewController.view];
    [self.directionsViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.directionsViewController.view.frame = CGRectMake(self.view.bounds.size.width - self.directionsViewController.view.bounds.size.width,
                                                              0.0f,
                                                              self.directionsViewController.view.bounds.size.width,
                                                              self.directionsViewController.view.bounds.size.height);
    }];
}

- (void)presentSettingsViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLSettingsViewController *svc = [SLSettingsViewController new];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)adjustLockInfoViewControllerWithCompletion:(void(^)(void))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.lockInfoViewController.lock = self.selectedLock;
    [self.lockInfoViewController setUpView];
    
    CGRect viewFrame = self.lockInfoViewController.isUp ? self.lockInfoLargeFrame : self.lockInfoSmallFrame;
    
    if ([self.childViewControllers containsObject:self.lockInfoViewController]) {
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            self.lockInfoViewController.view.frame = viewFrame;
        } completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        self.lockInfoViewController.view.frame = viewFrame;
        [self addChildViewController:self.lockInfoViewController];
        [self.view addSubview:self.lockInfoViewController.view];
        [self.view bringSubviewToFront:self.lockInfoViewController.view];
        [self.lockInfoViewController didMoveToParentViewController:self];
    }
}

- (void)dismissNotificationViewControllerWithCompletion:(void(^)(void))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.notificationViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.notificationViewController.view removeFromSuperview];
        [self.notificationViewController removeFromParentViewController];
        self.notificationViewController = nil;
        
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

- (void)presentSharingViewControllerWithLock:(SLLock *)lock
{
    SLSharingViewController *svc = [SLSharingViewController new];
    svc.lock = lock;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:svc];
    [self presentViewController:nc animated:YES completion:nil];
}

- (NSDictionary *)coachMarkParameters
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *params;
    if (self.selectedLock && self.lockInfoViewController.isUp) {
        static NSString *button = @"button";
        static NSString *label = @"label";
        
        CGRect crashButtonFrame = [self.view convertRect:self.lockInfoViewController.crashButtonFrame
                                                fromView:self.lockInfoViewController.view];
        CGRect crashLabelFrame = [self.view convertRect:self.lockInfoViewController.crashLabelFrame
                                               fromView:self.lockInfoViewController.view];
        CGRect theftButtonFrame = [self.view convertRect:self.lockInfoViewController.theftButtonFrame
                                                   fromView:self.lockInfoViewController.view];
        CGRect securityLabelFrame = [self.view convertRect:self.lockInfoViewController.theftLabelFrame
                                                  fromView:self.lockInfoViewController.view];
        CGRect sharingButtonFrame = [self.view convertRect:self.lockInfoViewController.sharingButtonFrame
                                                  fromView:self.lockInfoViewController.view];
        CGRect sharingLabelFrame = [self.view convertRect:self.lockInfoViewController.sharingLabelFrame
                                                 fromView:self.lockInfoViewController.view];
        
        params = @{@(SLCoachMarkPageCrash):@{button:[NSValue valueWithCGRect:crashButtonFrame],
                                             label:[NSValue valueWithCGRect:crashLabelFrame]
                                             },
                   @(SLCoachMarkPageSharing):@{button:[NSValue valueWithCGRect:sharingButtonFrame],
                                               label:[NSValue valueWithCGRect:sharingLabelFrame]
                                               },
                   @(SLCoachMarkPageTheft):@{button:[NSValue valueWithCGRect:theftButtonFrame],
                                             label:[NSValue valueWithCGRect:securityLabelFrame]
                                             }
                   };
    }
    
    return params;
}

- (void)touchStopperViewTapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"touch stopper view tapped");
    SLSlideViewController *svc;
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isMemberOfClass:[SLSlideViewController class]]) {
            svc = (SLSlideViewController *)vc;
            break;
        }
    }
    
    if (svc) {
        [self removeSlideViewController:svc withCompletion:nil];
    }
    
    self.lockInfoViewController.lock = self.selectedLock;
    [self.lockInfoViewController setUpView];
}

- (void)handleCrashAndTheftAlerts:(NSNotification *)notification
{
    if (self.notificationViewController) {
        NSDictionary *info = notification.userInfo;
        if (info && info[@"notification"]) {
            SLNotification *slNotification = info[@"notification"];
            [self.notificationViewController addNewNotficationViewForNotification:slNotification];
        }
    } else {
        self.notificationViewController = [SLNotificationViewController new];
        self.notificationViewController.delegate = self;
        self.notificationViewController.view.frame = self.view.bounds;
        self.notificationViewController.view.alpha = 0.0f;
        
        [self addChildViewController:self.notificationViewController];
        [self.view addSubview:self.notificationViewController.view];
        [self.view bringSubviewToFront:self.notificationViewController.view];
        [self.notificationViewController didMoveToParentViewController:self];
        
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            self.notificationViewController.view.alpha = 1.0f;
        }];
    }
}

- (void)removeCrashAndTheftViewController
{
    if (self.notificationViewController) {
        [self.notificationViewController dismissViewControllerAnimated:YES completion:^{
            self.notificationViewController = nil;
        }];
    }
}

- (void)dismissAlert:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if (self.notificationViewController && info && info[@"notification"]) {
        SLNotification *slNotification = info[@"notification"];
        [self.notificationViewController dismissNotification:slNotification];
    }
}

- (void)addAlertView:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if (self.notificationViewController && info && info[@"notification"]) {
        SLNotification *slNotification = info[@"notification"];
        [self.notificationViewController addNewNotficationViewForNotification:slNotification];
    }
}

- (void)presentEmergencyText:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSArray *recipients = info[@"recipients"];
    SLDbUser *currentUser = [SLDatabaseManager.manager currentUser];
    // temporay location for this message. It should be stored in a p-list or the database
    NSString *message = [NSString stringWithFormat:@"%@ is having an emergency. Please Contact %@ immediately. --Skylock", currentUser.fullName, currentUser.fullName];
    MFMessageComposeViewController *cvc = [MFMessageComposeViewController new];
    cvc.messageComposeDelegate = self;
    cvc.recipients = recipients;
    cvc.body = message;
    
    [self presentViewController:cvc animated:YES completion:nil];
}

- (void)setupLockInfoViewControllerView:(BOOL)shouldBeLarge
{
    self.lockInfoViewController.lock = self.selectedLock;
    
    if (!shouldBeLarge) {
        self.locationButton.hidden = NO;
    }
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.lockInfoViewController.view.frame = shouldBeLarge ? self.lockInfoLargeFrame : self.lockInfoSmallFrame;
        self.locationButton.alpha = shouldBeLarge ? 0.0f : 1.0f;
    } completion:^(BOOL finished) {
        if (shouldBeLarge) {
            self.locationButton.hidden = NO;
        }
    }];
}

- (void)locationButtonPressed
{
    [self centerOnUser];
}

- (void)directionsButtonPushed
{
    
}

- (void)handleDirectionsMode
{
    if (!self.lockInfoViewController.isUp &&
        self.selectedLockAnnotation &&
        self.directions &&
        self.directions.count > 0 &&
        (self.leftCalloutButton.isSelected || self.rightCalloutButton.isSelected)) {
        self.directionsButton.hidden = NO;
    } else {
        self.directionsButton.hidden = YES;
    }
}

#pragma mark - Alert view delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // user has not given access
    } else if (buttonIndex == 1) {
        // user has granted location services
        
    }
}

#pragma mark - SLSlideViewController Delegate Methods
- (void)slideViewController:(SLSlideViewController *)slvc
              actionOccured:(SLSlideViewControllerButtonAction)action
                    options:(NSDictionary *)options
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (action == SLSlideViewControllerButtonActionLockSelected) {
        self.selectedLock = [SLLockManager.manager getCurrentLock];
        self.settingsButton.enabled = YES;
        
        // TODO - clear lock annotations that are no longer active
        [self addLockToMap:self.selectedLock];
    } else if (action == SLSlideViewControllerButtonActionLockDeselected){
        self.selectedLock = nil;
    } else if (action == SLSlideViewControllerButtonActionAddLock){
        SLMainTutorialViewController *tvc = [SLMainTutorialViewController new];
        tvc.shouldDismiss = YES;        
        [self presentViewController:tvc animated:YES completion:nil];
    } else if (action == SLSlideViewControllerButtonActionSharing) {
        SLSharingViewController *svc = [SLSharingViewController new];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:svc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)slideViewControllerViewAccountPressed:(SLSlideViewController *)slvc forUser:(SLDbUser *)user
{
    SLAccountInfoViewController *aivc = [SLAccountInfoViewController new];
    aivc.user = user;
    
    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:aivc];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)slideViewControllerSharingPressed:(SLSlideViewController *)slvc withLock:(SLLock *)lock
{
    [self presentSharingViewControllerWithLock:lock];
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

#pragma mark - SLLockInfoViewController Delegate Methods
- (void)lockInfoViewController:(SLLockInfoViewController *)livc shouldIncreaseSize:(BOOL)shouldIncreaseSize
{
    [self setupLockInfoViewControllerView:shouldIncreaseSize];
}

#pragma mark - MGL map view helper methods
- (void)centerOnUser
{
    [self.mapView setCenterCoordinate:self.userLocation animated:YES];
}

- (MGLPointAnnotation *)annotationForLock:(SLLock *)lock
{
    if (self.lockAnnotations[lock.displayName]) {
        return self.lockAnnotations[lock.displayName][@"annotation"];
    }
    
    CLLocationCoordinate2D testPoint = CLLocationCoordinate2DMake(37.301508, -120.480166);
    
    MGLPointAnnotation *annotation = [MGLPointAnnotation new];
    //annotation.coordinate = CLLocationCoordinate2DMake(lock.latitude.doubleValue, lock.longitude.doubleValue);
    annotation.coordinate = testPoint;
    annotation.title = lock.displayName;

    self.lockAnnotations[lock.displayName] = @{@"annotation":annotation,
                                               @"lock":lock
                                               };
    return annotation;
}

- (void)addLockToMap:(SLLock *)lock
{
    [self.mapView addAnnotation:[self annotationForLock:lock]];
}

- (void)updateUsersLocation
{
    self.userAnnotation.coordinate = self.userLocation;

    if (self.isInitialLoad) {
        [self.mapView addAnnotation:self.userAnnotation];
    }
}

- (void)getDirectionsToLocation:(CLLocationCoordinate2D)location transportType:(MKDirectionsTransportType)transportType
{
    MKPlacemark *userPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.userLocation addressDictionary:nil];
    MKPlacemark *lockPlacemark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];
    
    MKDirectionsRequest *directionRequest = [[MKDirectionsRequest alloc] init];
    directionRequest.source = [[MKMapItem alloc] initWithPlacemark:userPlacemark];
    directionRequest.destination = [[MKMapItem alloc] initWithPlacemark:lockPlacemark];
    directionRequest.transportType = transportType;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error getting directions");
            // TODO -- check and see what should happen when we can't get dirctions...popup?
            return;
        }
        
        if (!response.routes || response.routes.count == 0) {
            NSLog(@"no routes in directions");
            // TODO -- check and see what should happen when there aren't any routes
            return;
        }
        
        MKRoute *route = response.routes[0];
        NSMutableArray *routeDirections = [NSMutableArray new];
        for (MKRouteStep *routeStep in route.steps) {
            SLDirection *direction = [[SLDirection alloc] initWithCoordinate:routeStep.polyline.coordinate
                                                                  directions:routeStep.instructions
                                                                    distance:routeStep.distance];
            [routeDirections addObject:direction];
        }
        
        [self enterDirectionModeWithDirections:routeDirections];
    }];
}

- (void)leftCalloutViewButtonPressed
{
    self.leftCalloutButton.selected = !self.leftCalloutButton.isSelected;
    if (self.selectedLockAnnotation) {
        [self getDirectionsToLocation:self.selectedLockAnnotation.coordinate
                        transportType:MKDirectionsTransportTypeWalking];
    }
}

- (void)rightCalloutViewButtonPressed
{
    self.rightCalloutButton.selected = !self.rightCalloutButton.isSelected;
    if (self.selectedLockAnnotation) {
        [self getDirectionsToLocation:self.selectedLockAnnotation.coordinate
                        transportType:MKDirectionsTransportTypeWalking];
    }
    
}

- (void)enterDirectionModeWithDirections:(NSArray *)directions
{
    self.directions = directions;
    SLDirectionDrawingHelper *drawingHelper = [[SLDirectionDrawingHelper alloc] initWithMapView:self.mapView
                                                                                     directions:self.directions];
    [drawingHelper drawDirections:^{
        self.directionsButton.hidden = NO;
        [self.lockInfoViewController setUpView];
    }];
}

#pragma mark - MGL map view delegate methods
- (MGLAnnotationImage *)mapView:(MGLMapView * __nonnull)mapView imageForAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    MGLAnnotationImage *image;
    if (annotation == self.userAnnotation) {
        SLDbUser *user = [SLDatabaseManager.manager currentUser];
        UIImage *userPic = [SLPicManager.manager userImageForEmail:user.email];
        if (userPic) {
            UIImage *userPicSmall = [userPic resizedImageWithSize:CGSizeMake(31, 35)];
            UIImage *maskedImage = [UIImage profilePicFromImage:userPicSmall];
            image = [MGLAnnotationImage annotationImageWithImage:maskedImage
                                                 reuseIdentifier:user.email];
        }
    } else {
        image = [MGLAnnotationImage annotationImageWithImage:[UIImage imageNamed:@"img_lock"]
                                             reuseIdentifier:@"img_lock"];
    }
    
    return image;
}

- (void)mapView:(MGLMapView * __nonnull)mapView didUpdateUserLocation:(nullable MGLUserLocation *)userLocation
{

}

- (void)mapViewWillStartLocatingUser:(MGLMapView * __nonnull)mapView
{
    NSLog(@"user location: %@", mapView.userLocation);
    [self centerOnUser];
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation
{
    return YES;
}

- (void)mapView:(MGLMapView * __nonnull)mapView didSelectAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    self.directionsButton.hidden = NO;
    self.selectedLockAnnotation = annotation;
}

- (void)mapView:(MGLMapView * __nonnull)mapView didDeselectAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    self.selectedLockAnnotation = nil;
}

- (UIView *)mapView:(MGLMapView * __nonnull)mapView leftCalloutAccessoryViewForAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    return self.leftCalloutButton;
}

- (UIView *)mapView:(MGLMapView * __nonnull)mapView rightCalloutAccessoryViewForAnnotation:(id<MGLAnnotation> __nonnull)annotation
{
    return self.rightCalloutButton;
}

- (CGFloat)mapView:(MGLMapView * __nonnull)mapView lineWidthForPolylineAnnotation:(MGLPolyline * __nonnull)annotation
{
    return 6.0f;
}

- (UIColor *)mapView:(MGLMapView * __nonnull)mapView strokeColorForShapeAnnotation:(MGLShape * __nonnull)annotation
{
    return [annotation isKindOfClass:[MGLPolyline class]] ? [UIColor colorWithRed:110 green:223 blue:158] : nil;
}

#pragma mark - CLLocaiton manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [manager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied) {
        NSString *message = NSLocalizedString(@"We use this stuff, man! It's important! Common--", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"We really need this!", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    self.userLocation = location.coordinate;
    [self updateUsersLocation];

    if (self.isInitialLoad) {
        [self centerOnUser];
        self.isInitialLoad = NO;
    }
}

#pragma mark - SLNotificationViewController delegate methods
- (void)notificationVCWantsDismiss:(SLNotificationViewController *)notificationVC
{
    [self dismissNotificationViewControllerWithCompletion:nil];
}

#pragma mark - MFMailComposeViewController delegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
