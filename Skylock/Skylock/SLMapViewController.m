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


@class MBDirectionsRequest;


#define kMapBoxMapId        @"michalumni.l2bh1bee"
#define kSLMapViewControllerLockInfoViewWidth 295.0f
#define kSLMapViewControllerLockInfoViewLargeHeight 217.0f
#define kSLMapViewControllerLockInfoViewSmallHeight 110.0f

@interface SLMapViewController ()

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *settingsButton;

@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;

@property (nonatomic, strong) MGLMapView *mapView;
@property (nonatomic, strong) MGLPointAnnotation *userAnnotation;

@property (nonatomic, strong) NSMutableDictionary *lockAnnotations;
@property (nonatomic, assign) BOOL isInitialLoad;

@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) SLNotificationViewController *notificationViewController;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    [SLDatabaseManager.manager setCurrentUser];
    
    [self.locationManager requestWhenInUseAuthorization];
    
    self.lockAnnotations = [NSMutableDictionary new];
    self.isInitialLoad = YES;
    [self registerAlertNotifications];
    
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
    
    self.settingsButton.frame = CGRectMake(self.view.bounds.size.width - self.settingsButton.bounds.size.width - 15.0f,
                                           CGRectGetMidY(self.menuButton.frame) - .5*self.settingsButton.bounds.size.height,
                                           self.settingsButton.bounds.size.width,
                                           self.settingsButton.bounds.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if ([CLLocationManager locationServicesEnabled]) {
//        self.mapView.showsUserLocation = YES;
//    }
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

- (void)settingsButtonPressed
{
    [self presentSettingsViewController];
}

- (void)presentSlideViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [SLLockManager.manager fetchLocks];
    [self.view addSubview:self.touchStopperView];
    
    static CGFloat width = 220.0f;
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

- (void)presentSettingsViewController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    [self.view addSubview:self.touchStopperView];
//    
//    static CGFloat width = 233.0f;
//    SLSettingsViewController *svc = [SLSettingsViewController new];
//    //slvc.delegate = self;
//    svc.view.frame = CGRectMake(self.view.bounds.size.width,
//                                0.0f,
//                                width,
//                                self.view.bounds.size.height);
//    
//    [self addChildViewController:svc];
//    [self.view addSubview:svc.view];
//    [self.view bringSubviewToFront:svc.view];
//    [svc didMoveToParentViewController:self];
//    
//    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
//        svc.view.frame = CGRectMake(self.view.bounds.size.width - svc.view.bounds.size.width,
//                                     0.0f,
//                                     width,
//                                     svc.view.bounds.size.height);
//    } completion:nil];
    
    SLSettingsViewController *svc = [SLSettingsViewController new];
    [self presentViewController:svc animated:YES completion:nil];
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
               buttonPushed:(SLSlideViewControllerButtonAction)action
                    options:(NSDictionary *)options
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (action == SLSlideViewControllerButtonActionLockSelected && options) {
        SLLock *lock = options[@"lock"];
        
        // this should be moved to the point where the lock's annotation is placed on the screen
        self.selectedLock = lock;
        self.settingsButton.enabled = YES;
        // end move
        
        [self removeSlideViewController:slvc withCompletion:^{
            [self presentLockInfoViewControllerWithLock:lock];
        }];
        
        [self addLockToMap:lock];
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

#pragma mark - SLInfoViewController Delegate Methods
- (void)lockInfoViewController:(SLLockInfoViewController *)livc shouldIncreaseSize:(BOOL)shouldIncreaseSize
{
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        livc.view.frame = shouldIncreaseSize ? self.lockInfoLargeFrame : self.lockInfoSmallFrame;
    }];
}

#pragma mark - MGL map view helper methods
- (void)centerOnUser
{
    [self.mapView setCenterCoordinate:self.userLocation animated:YES];
}

- (MGLPointAnnotation *)annotationForLock:(SLLock *)lock
{
    if (self.lockAnnotations[lock.name]) {
        return self.lockAnnotations[lock.name][@"annotation"];
    }
    
    MGLPointAnnotation *annotation = [MGLPointAnnotation new];
    annotation.coordinate = CLLocationCoordinate2DMake(lock.latitude.doubleValue, lock.longitude.doubleValue);
    annotation.title = lock.name;
    
    self.lockAnnotations[lock.name] = @{@"annotation":annotation,
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
    NSLog(@"%@", mapView.userLocation);
    [self centerOnUser];
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

@end
