//
//  SLMapViewController.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMapViewController.h"
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


#define kSLMapViewControllerCalloutScaler           4.0f
#define kSLMapViewControllerCalloutOffsetScaler     0.65f
#define kSLMapViewControllerCalloutYOffset          40.0f

@interface SLMapViewController() <SLMapCalloutViewControllerDelegate>

@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) GMSMarker *userMarker;
@property (nonatomic, strong) GMSMarker *selectedLockMarker;

@property (nonatomic, strong) NSMutableDictionary *lockMarkers;
@property (nonatomic, assign) BOOL isInitialLoad;

@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) SLNotificationViewController *notificationViewController;

@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, copy) NSString *directionEndAddress;

@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *directionsButton;

@property (nonatomic, strong) SLDirectionsViewController *directionsViewController;

@property (nonatomic, strong) SLMapCalloutViewController *mapCalloutViewController;
@property (nonatomic, strong) SLDirectionDrawingHelper *directionDrawingHelper;

@end

@implementation SLMapViewController

- (GMSMapView *)mapView
{
    if (!_mapView) {
        GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.userLocation zoom:5];
        _mapView = [GMSMapView mapWithFrame:self.view.bounds camera:cameraPosition];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _mapView.myLocationEnabled = YES;
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

- (UIButton *)locationButton
{
    if (!_locationButton) {
        UIImage *image = [UIImage imageNamed:@"show_current location_button"];
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
    
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"lock_screen_hamburger_menu"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(menuButtonPressed)];
    self.navigationItem.leftBarButtonItem = menuButton;
    self.navigationItem.title = NSLocalizedString(@"FIND MY ELLIPSE", nil);
    
    self.locationButton.frame = CGRectMake(self.view.bounds.size.width - self.locationButton.bounds.size.width - 10.0f,
                                           self.view.bounds.size.height - self.locationButton.bounds.size.height - 50.0f,
                                           self.locationButton.bounds.size.height,
                                           self.locationButton.bounds.size.width);
    
    self.directionsButton.frame = CGRectMake(CGRectGetMaxX(self.lockInfoSmallFrame) - self.directionsButton.bounds.size.width,
                                             self.locationButton.frame.origin.y,
                                             self.directionsButton.bounds.size.width,
                                             self.directionsButton.bounds.size.height);
    
//    UIButton *testActionButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.center.x,
//                                                                            self.view.center.y,
//                                                                            100,
//                                                                            50)];
//    [testActionButton addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchDown];
//    [testActionButton setTitle:@"Test" forState:UIControlStateNormal];
//    [testActionButton setBackgroundColor:[UIColor purpleColor]];
//    [self.view addSubview:testActionButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationShowLockBar
                                                        object:nil];
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

- (void)menuButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.userLocation zoom:16];
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
    //self.userMarker.position = self.userLocation;

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

- (void)updateUserPosition:(CLLocationCoordinate2D)userPosition
{
    self.userLocation = userPosition;
    
    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    user.location = self.userLocation;
    
    [self updateUserLocation];
    
    if (self.isInitialLoad) {
        [self centerOnUser];
        self.isInitialLoad = NO;
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

@end
