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
#import "SLUserDefaults.h"
#import "SLDropDownLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "SLDatabaseManager.h"
#import "UIColor+RGB.h"
#import "SLPicManager.h"
#import "SLLock.h"
#import "UIImage+Skylock.h"
#import "SLNavigationViewController.h"
#import "SLAccountInfoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SLNotifications.h"
#import "SLNotificationViewController.h"
#import "SLDirectionsViewController.h"
#import "SLRestManager.h"
#import "SLUser.h"
#import "Skylock-Swift.h"


#define kSLMapViewControllerLockInfoViewWidth       295.0f
#define kSLMapViewControllerLockInfoViewLargeHeight 217.0f
#define kSLMapViewControllerLockInfoViewSmallHeight 110.0f
#define kSLMapViewControllerLockInfoViewPadding     12.0f
#define kSLMapViewControllerCalloutScaler           4.0f
#define kSLMapViewControllerCalloutOffsetScaler     0.65f
#define kSLMapViewControllerCalloutYOffset          40.0f

@interface SLMapViewController() <SLMapCalloutViewControllerDelegate, SLAcceptNotificationsViewControllerDelegate>

@property (nonatomic, strong) UIView *touchStopperView;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *settingsButton;

@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSMarker *userMarker;
@property (nonatomic, strong) GMSMarker *selectedLockMarker;

@property (nonatomic, strong) NSMutableDictionary *lockMarkers;
@property (nonatomic, assign) BOOL isInitialLoad;

@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) SLNotificationViewController *notificationViewController;

@property (nonatomic, strong) SLLockInfoViewController *lockInfoViewController;

@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, copy) NSString *directionEndAddress;

@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *directionsButton;

@property (nonatomic, strong) SLDirectionsViewController *directionsViewController;

@property (nonatomic, strong) SLMapCalloutViewController *mapCalloutViewController;
@property (nonatomic, strong) SLDirectionDrawingHelper *directionDrawingHelper;

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

- (GMSMapView *)mapView
{
    if (!_mapView) {
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.userLocation zoom:5];
        _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:cameraPosition];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.delegate = self;
    }
    
    return _mapView;
}

- (GMSMarker *)userMarker
{
    if (!_userMarker) {
        _userMarker = [GMSMarker markerWithPosition:self.userLocation];
        _userMarker.map = self.mapView;
    }
    
    return _userMarker;
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
                              action:@selector(directionsButtonPushed)
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
        _directionsViewController.endAddress = self.directionEndAddress;
        _directionsViewController.delegate = self;
    }
    
    return _directionsViewController;
}

- (SLMapCalloutViewController *)mapCalloutViewController
{
    if (!_mapCalloutViewController) {
        _mapCalloutViewController = [SLMapCalloutViewController new];
        [_mapCalloutViewController setProperties:NSLocalizedString(@"Navigate to", nil) lock:self.selectedLock];
        _mapCalloutViewController.delegate = self;
    }
    
    return _mapCalloutViewController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    [SLDatabaseManager.sharedManager setCurrentUser];
    
    self.lockMarkers = [NSMutableDictionary new];
    self.isInitialLoad = YES;
    [self registerNotifications];
    
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
    
    
//    UIButton *testActionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x,
//                                                                            self.view.center.y,
//                                                                            100,
//                                                                            50)];
//    [testActionButton addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchDown];
//    [testActionButton setTitle:@"Test" forState:UIControlStateNormal];
//    [testActionButton setBackgroundColor:[UIColor purpleColor]];
//    [self.view addSubview:testActionButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:SLUserDefaultsOnBoardingComplete]) {
        NSNumber *complete = [ud objectForKey:SLUserDefaultsOnBoardingComplete];
        if (!complete.boolValue) {
            [self presentNotificationsController];
        }
    } else {
        [self presentNotificationsController];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.lockInfoViewController.isUp && [SLLockManager.sharedManager selectedLock] && self.isInitialLoad) {
        self.lockInfoViewController.lock = [SLLockManager.sharedManager selectedLock];
        [self.lockInfoViewController setUpViewAndChangeSize:NO moveUp:NO];
    }
}

- (void)testAction
{
    NSLog(@"test action button pressed");
    //[SLLockManager.sharedManager tempDeleteLockFromCurrentUserAccount:@"Skylock DF928DD51C00"];
    [SLLockManager.sharedManager tempReadFirmwareDataForLockAddress:@"E12E18E807D6"];
}

- (void)registerNotifications
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockAdded:)
                                                 name:kSLNotificationLockPaired
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockRemoved:)
                                                 name:kSLNotificationLockManagerDisconnectedLock
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
    SLSettingsViewController *svc = [SLSettingsViewController new];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:svc];
    nc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    nc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:nc animated:YES completion:nil];

}

- (void)presentNotificationsController
{
    SLAcceptNotificationsViewController *anvc = [SLAcceptNotificationsViewController new];
    anvc.delegate = self;
    [self presentViewController:anvc animated:NO completion:nil];
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
                                                          .5f*self.view.bounds.size.width,
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

- (void)presentEmergencyText:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSArray *recipients = info[@"recipients"];
    SLUser *currentUser = [SLDatabaseManager.sharedManager currentUser];
    // temporay location for this message. It should be stored in a p-list or the database
    NSString *message = [NSString stringWithFormat:@"%@ is having an emergency. Please Contact %@ immediately. --Skylock",
                         currentUser.fullName,
                         currentUser.fullName];
    MFMessageComposeViewController *cvc = [MFMessageComposeViewController new];
    cvc.messageComposeDelegate = self;
    cvc.recipients = recipients;
    cvc.body = message;
    
    [self presentViewController:cvc animated:YES completion:nil];
}

- (void)lockAdded:(NSNotification *)notification
{
    NSDictionary *info = (NSDictionary *)notification.object;
    if (!info || !info[@"lock"]) {
        return;
    }
    
    self.selectedLock = info[@"lock"];
    //[self setupLockInfoViewControllerView:YES];
    self.lockInfoViewController.lock = self.selectedLock;
    
    //[self.lockInfoViewController setUpView];
}

- (void)lockRemoved:(NSNotification *)notification
{
    
}

- (void)setupLockInfoViewControllerView
{
    self.locationButton.hidden = self.lockInfoViewController.isUp;
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.lockInfoViewController.view.frame = self.lockInfoViewController.isUp ?
            self.lockInfoLargeFrame : self.lockInfoSmallFrame;
        self.locationButton.alpha = self.lockInfoViewController.isUp ? 0.0f : 1.0f;
    } completion:^(BOOL finished) {
        self.locationButton.hidden = !self.lockInfoViewController.isUp;
    }];
}

- (void)locationButtonPressed
{
    [self centerOnUser];
}

- (void)directionsButtonPushed
{
    [self presentDirectionsViewController];
}

- (void)lockSelected
{
    self.settingsButton.enabled = YES;
    
    // TODO - clear lock annotations that are no longer active
    self.selectedLock = [SLLockManager.sharedManager selectedLock];
    if (self.selectedLock) {
       [self addLockToMap:self.selectedLock];
    }
}

- (void)handleDirectionsMode
{
//    if (!self.lockInfoViewController.isUp &&
//        //self.selectedLockAnnotation &&
//        self.directions &&
//        self.directions.count > 0 &&
//        (self.leftCalloutButton.isSelected || self.rightCalloutButton.isSelected)) {
//        self.directionsButton.hidden = NO;
//    } else {
//        self.directionsButton.hidden = YES;
//    }
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
        [self lockSelected];
    } else if (action == SLSlideViewControllerButtonActionLockDeselected){
        self.selectedLock = nil;
    } else if (action == SLSlideViewControllerButtonActionAddLock){

    } else if (action == SLSlideViewControllerButtonActionSharing) {

    } else if (action == SLSlideViewControllerButtonActionViewAccount) {
        SLAccountInfoViewController *aivc = [SLAccountInfoViewController new];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:aivc];
        nc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        nc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:nc animated:YES completion:nil];
    } else if (action == SLSlideViewControllerButtonActionRemoveLock) {
        if (options && options[@"lock"]) {
            SLLock *lock = (SLLock *)options[@"lock"];
            [SLLockManager.sharedManager
             deleteLockFromCurrentUserAccountWithMacAddress:lock.macAddress];
        }
    }
}

- (void)slideViewControllerViewAccountPressed:(SLSlideViewController *)slvc forUser:(SLUser *)user
{
    SLAccountInfoViewController *aivc = [SLAccountInfoViewController new];
    aivc.user = user;
    
    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:aivc];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)slideViewControllerSharingPressed:(SLSlideViewController *)slvc withLock:(SLLock *)lock
{

}

#pragma mark - SLLockInfoViewController Delegate Methods
- (void)lockInfoViewController:(SLLockInfoViewController *)livc shouldIncreaseSize:(BOOL)shouldIncreaseSize
{

}

- (void)lockInfoViewControllerWantsToBeLarge:(SLLockInfoViewController *)livc
{
    [self setupLockInfoViewControllerView];
}

- (void)lockInfoViewControllerWantsToBeSmall:(SLLockInfoViewController *)livc
{
    [self setupLockInfoViewControllerView];
}

#pragma mark - SLDirectionsViewController Delegate Methods
- (void)directionsViewControllerWantsExit:(SLDirectionsViewController *)directionsController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        directionsController.view.frame = CGRectMake(self.view.bounds.size.width,
                                                     self.directionsViewController.view.frame.origin.y,
                                                     self.directionsViewController.view.bounds.size.width,
                                                     self.directionsViewController.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [directionsController.view removeFromSuperview];
        [directionsController removeFromParentViewController];
        [self exitDirecitonMode];
    }];
}

#pragma mark - MGL map view helper methods
- (void)centerOnUser
{
    // zoom should be 16
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.userLocation zoom:14];
    [self.mapView animateToCameraPosition:cameraPosition];
}

- (void)addLockToMap:(SLLock *)lock
{
    // hard coding location for demo
    CLLocationCoordinate2D postion = CLLocationCoordinate2DMake(37.761758, -122.421241);
    //CLLocationCoordinate2D postion = CLLocationCoordinate2DMake(37.767869, -122.453231);
    [self.selectedLock setCurrentLocation:postion];
    GMSMarker *lockMarker = [GMSMarker markerWithPosition:postion];
    lockMarker.title = lock.name;
    lockMarker.icon = [UIImage imageNamed:@"img_lock"];
    lockMarker.map = self.mapView;
    lockMarker.infoWindowAnchor = CGPointMake(0.0f, 0.0f);
    
    self.lockMarkers[lock.macAddress] = lockMarker;
}

- (void)updateUserLocation
{
    self.userMarker.position = self.userLocation;

//    if (self.isInitialLoad) {
//        SLUser *user = [SLDatabaseManager.sharedManager currentUser];
//        
//        UIImage *userPic = [SLPicManager.sharedManager userImageForUserId:user.userId];
//        if (userPic) {
//            UIImage *userPicSmall = [userPic resizedImageWithSize:CGSizeMake(31, 35)];
//            UIImage *maskedImage = [UIImage profilePicFromImage:userPicSmall];
//            self.userMarker.icon = maskedImage;
//        }
//    }
}

- (void)getDirectionsForTransportation:(SLMapCalloutVCPane)pane
{
    if (!self.selectedLock) {
        NSLog(@"Can't present directions");
        return;
    }

    SLDirectionAPIHelper *directionsHelper = [[SLDirectionAPIHelper alloc] initWithStart:self.userLocation
                                                                                     end:self.selectedLock.location
                                                                                isBiking:pane == SLMapCalloutVCPaneRight];
    [directionsHelper getDirections:^(NSArray *directions, NSString *endAddress) {
        if (!directions || !endAddress) {
            NSLog(@"Error: could not retrieve directions");
            return;
        }
        
        self.directionEndAddress = endAddress;
        self.directions = directions;
        [self enterDirectionsMode];
    }];
}

- (void)enterDirectionsMode
{
    if (!self.directions || !self.directionEndAddress) {
        NSLog(@"Error: direcions and/or directionEndAddress not defined");
        return;
    }
    
    self.directionDrawingHelper = [[SLDirectionDrawingHelper alloc] initWithMapView:self.mapView
                                                                         directions:self.directions];
    [self.directionDrawingHelper drawDirections:^{
        self.directionsButton.hidden = NO;
        
        if (self.lockInfoViewController.isUp) {
            [self.lockInfoViewController setUpViewAndChangeSize:YES moveUp:NO];
        }
    }];
}

- (void)exitDirecitonMode
{
    self.directions = nil;
    self.directionsViewController = nil;
    
    if (self.mapCalloutViewController) {
        [self.mapCalloutViewController setCalloutViewUnselected];
//        [self.directionDrawingHelper removeDirections];
//        self.directionDrawingHelper = nil;
    }
}

#pragma mark - GMS map view delegate methods

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if (marker != self.userMarker) {
        self.directionsButton.hidden = NO;
        self.selectedLockMarker = marker;
        [mapView setSelectedMarker:marker];
    }

    return YES;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.mapCalloutViewController.view.frame = CGRectMake(0, 0, 180, 64);
    self.mapCalloutViewController.lock = self.selectedLock;
    
    [self addChildViewController:self.mapCalloutViewController];
    
    [self.view addSubview:self.mapCalloutViewController.view];
    [self.view bringSubviewToFront:self.mapCalloutViewController.view];
    [self.mapCalloutViewController didMoveToParentViewController:self];
    
    CLLocationCoordinate2D anchor = [self.mapView.selectedMarker position];
    CGPoint point = [self.mapView.projection pointForCoordinate:anchor];
    point.x += kSLMapViewControllerCalloutOffsetScaler*self.mapCalloutViewController.view.bounds.size.width;
    point.y -= kSLMapViewControllerCalloutYOffset;
    self.mapCalloutViewController.view.center = point;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, .1f, .1f)];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    return backgroundView;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.mapCalloutViewController) {
        [self.mapCalloutViewController.view removeFromSuperview];
        [self.mapCalloutViewController removeFromParentViewController];
        self.mapCalloutViewController = nil;
        self.directionsButton.hidden = YES;
        if (self.directionDrawingHelper) {
           [self.directionDrawingHelper removeDirections];
            self.directionDrawingHelper = nil;
        }
    }
    
    if (self.selectedLockMarker) {
        self.selectedLockMarker = nil;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    if (self.selectedLockMarker && self.mapCalloutViewController) {
        CLLocationCoordinate2D anchor = [self.mapView.selectedMarker position];
        CGPoint point = [self.mapView.projection pointForCoordinate:anchor];
        point.x += kSLMapViewControllerCalloutOffsetScaler*self.mapCalloutViewController.view.bounds.size.width;
        point.y -= kSLMapViewControllerCalloutYOffset;
        self.mapCalloutViewController.view.center = point;
    }
}

#pragma mark - CLLocaiton manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [manager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        
        NSString *message = NSLocalizedString(@"We use this stuff, man! It's important! Common--", nil);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"We really need this!", nil)
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    self.userLocation = location.coordinate;

    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    user.location = self.userLocation;
    
    [self updateUserLocation];

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

#pragma mark - SLMapCalloutViewController Delegate methods
- (void)leftCalloutViewTapped:(SLMapCalloutViewController *)calloutController
{
    [self getDirectionsForTransportation:SLMapCalloutVCPaneLeft];
}

- (void)rightCalloutViewTapped:(SLMapCalloutViewController *)calloutController
{
    [self getDirectionsForTransportation:SLMapCalloutVCPaneRight];
}

#pragma mark - SLAcceptNotificationsViewController delegate methods
- (void)userAcceptsLocationUse:(SLAcceptNotificationsViewController *)acceptNotificationsVC
{
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)acceptsNotificationsControllerWantsExit:(SLAcceptNotificationsViewController *)acceptNotiticationViewController
                                       animated:(BOOL)animated
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
