//
//  SLMapViewController.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMapViewController.h"
#import "SLConstants.h"
#import "SLUserDefaults.h"
#import <QuartzCore/QuartzCore.h>
#import "SLDatabaseManager.h"
#import "UIColor+RGB.h"
#import "SLPicManager.h"
#import "SLLock.h"
#import "UIImage+Skylock.h"
#import "SLNavigationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SLNotifications.h"
#import "SLDirectionsViewController.h"
#import "SLRestManager.h"
#import "SLUser.h"
#import "Ellipse-Swift.h"


#define kSLMapViewControllerCalloutScaler           4.0f
#define kSLMapViewControllerCalloutOffsetScaler     0.65f
#define kSLMapViewControllerCalloutYOffset          40.0f

@interface SLMapViewController() <SLLockInfoViewControllerDelegate>

@property (nonatomic, strong) SEBLEInterfaceMangager *bleManager;
@property (nonatomic, assign) CGRect lockInfoSmallFrame;
@property (nonatomic, assign) CGRect lockInfoLargeFrame;

@property (nonatomic, strong) GMSMapView *mapView;

@property (nonatomic, strong) NSMutableDictionary *lockMarkers;
@property (nonatomic, assign) BOOL isInitialLoad;

@property (nonatomic, strong) SLLock *selectedLock;
@property (nonatomic, strong) NSMutableArray *locks;

@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
@property (nonatomic, strong) SLNotificationViewController *notificationViewController;

@property (nonatomic, strong) NSArray *directions;
@property (nonatomic, copy) NSString *directionEndAddress;

@property (nonatomic, strong) UIButton *locationButton;

@property (nonatomic, strong) SLDirectionsViewController *directionsViewController;

@property (nonatomic, strong) SLDirectionDrawingHelper *directionDrawingHelper;
@property (nonatomic, strong) SLNoEllipseConnectedView *noEllipseConnectedView;
@property (nonatomic, strong) SLLockInfoViewController *lockInfoViewController;

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

- (SLNoEllipseConnectedView *)noEllipseConnectedView
{
    if (!_noEllipseConnectedView) {
        NSString *text = NSLocalizedString(@"You have not yet conneced to an Ellipse. We can only show the location of locks that you have connected to.",
                                           nil);
        _noEllipseConnectedView = [[SLNoEllipseConnectedView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                             0.0f,
                                                                                             self.view.bounds.size.width,
                                                                                             156.0f)
                                                                             text:text];
    }
    
    return _noEllipseConnectedView;
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
    
    NSArray *previouslyConnectedLocks = [[SLLockManager sharedManager] allPreviouslyConnectedLocksForCurrentUser];
    self.locks = [NSMutableArray arrayWithArray: previouslyConnectedLocks];

    
    self.isInitialLoad = YES;
    [self registerNotifications];
    
    [self.view addSubview:self.mapView];
    
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed: @"lock_screen_hamburger_menu"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(menuButtonPressed)];
    
    UIBarButtonItem *showMoreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_show_more_dots"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showMoreButtonPressed)];
    self.navigationItem.leftBarButtonItem = menuButton;
    self.navigationItem.rightBarButtonItem = showMoreButton;
    
    self.navigationItem.title = NSLocalizedString(@"FIND MY ELLIPSE", nil);
    
    self.locationButton.frame = CGRectMake(self.view.bounds.size.width - self.locationButton.bounds.size.width - 15.0f,
                                           self.view.bounds.size.height - self.locationButton.bounds.size.height - 66.0f,
                                           self.locationButton.bounds.size.height,
                                           self.locationButton.bounds.size.width);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.locks.count == 0) {
        self.noEllipseConnectedView.frame = CGRectMake(0.0f,
                                                       -self.noEllipseConnectedView.frame.size.height,
                                                       self.noEllipseConnectedView.frame.size.width,
                                                       self.noEllipseConnectedView.frame.size.height);
        [self.view addSubview:self.noEllipseConnectedView];
        
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            self.noEllipseConnectedView.frame = CGRectMake(0.0f,
                                                           self.navigationController.navigationBar.bounds.size.height +
                                                           [UIApplication sharedApplication].statusBarFrame.size.height,
                                                           self.noEllipseConnectedView.frame.size.width,
                                                           self.noEllipseConnectedView.frame.size.height);
        }];
    } else {
        for (SLLock *lock in self.locks) {
            [self addLockToMap:lock];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationShowLockBar
                                                        object:nil];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCrashAndTheftAlerts:)
                                                 name:kSLNotificationAlertOccured
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockPaired:)
                                                 name:kSLNotificationLockPaired
                                               object:nil];
}

- (void)presentDirectionsViewControllerWithDirections:(NSArray *)directions
{
    SLLockViewController *lvc = (SLLockViewController *)self.presentingViewController;
    CGFloat y0 = self.navigationController.navigationBar.bounds.size.height +
        [UIApplication sharedApplication].statusBarFrame.size.height;
    self.directionsViewController.directions = directions;
    self.directionsViewController.view.frame = CGRectMake(-self.directionsViewController.view.bounds.size.width,
                                                          y0,
                                                          0.9f*self.view.bounds.size.width,
                                                          self.view.bounds.size.height - [lvc lockBarHeight] - y0);
    self.directionsViewController.view.backgroundColor = [UIColor whiteColor];

    [self addChildViewController:self.directionsViewController];
    [self.view addSubview:self.directionsViewController.view];
    [self.view bringSubviewToFront:self.directionsViewController.view];
    [self.directionsViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.directionsViewController.view.frame = CGRectMake(0.0,
                                                              self.directionsViewController.view.frame.origin.y,
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

}

- (void)lockPaired:(NSNotification *)notification
{
    if (self.noEllipseConnectedView) {
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            self.noEllipseConnectedView.frame = CGRectMake(0.0f,
                                                           -self.noEllipseConnectedView.frame.size.height,
                                                           self.noEllipseConnectedView.frame.size.width,
                                                           self.noEllipseConnectedView.frame.size.height);
        } completion:^(BOOL finished) {
            [self.noEllipseConnectedView removeFromSuperview];
            self.noEllipseConnectedView = nil;
        }];
    }
    
    SLLock *currentLock = [SLLockManager.sharedManager getCurrentLock];
    if (currentLock && !self.lockMarkers[currentLock.macAddress]) {
        [self addLockToMap:currentLock];
    }
}

- (void)menuButtonPressed
{
    if ([self.view.subviews containsObject:self.noEllipseConnectedView]) {
        [self.noEllipseConnectedView removeFromSuperview];
    }
    
    self.noEllipseConnectedView = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMoreButtonPressed
{
    if (self.lockInfoViewController) {
        [self removeLockInfoViewController];
    } else {
        [self presentLockInfoViewController];
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

- (void)presentLockInfoViewController
{
    if (!self.selectedLock) {
        return;
    }
    
    CGFloat y0 = self.navigationController.navigationBar.bounds.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat height = 175.0f;
    self.lockInfoViewController = [[SLLockInfoViewController alloc] initWithLock:self.selectedLock];
    self.lockInfoViewController.delegate = self;
    self.lockInfoViewController.view.frame = CGRectMake(0.0, -height, self.view.bounds.size.width, height);
    
    [self addChildViewController:self.lockInfoViewController];
    [self.view addSubview:self.lockInfoViewController.view];
    [self.view bringSubviewToFront:self.lockInfoViewController.view];
    [self.lockInfoViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.lockInfoViewController.view.frame = CGRectMake(0.0,
                                                            y0,
                                                            self.lockInfoViewController.view.bounds.size.width,
                                                            height);
    }];
    
}

- (void)removeLockInfoViewController
{
    CGFloat yFinal = self.navigationController.navigationBar.bounds.size.height +
    [UIApplication sharedApplication].statusBarFrame.size.height;
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        self.lockInfoViewController.view.frame = CGRectMake(0.0,
                                                            yFinal - self.lockInfoViewController.view.bounds.size.height,
                                                            self.lockInfoViewController.view.bounds.size.width,
                                                            self.lockInfoViewController.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.lockInfoViewController.view removeFromSuperview];
        [self.lockInfoViewController removeFromParentViewController];
        [self.lockInfoViewController.view removeFromSuperview];
        self.lockInfoViewController = nil;
    }];
}

- (void)locationButtonPressed
{
    [self centerOnUser];
}

#pragma mark - SLDirectionsViewController Delegate Methods
- (void)directionsViewControllerWantsExit:(SLDirectionsViewController *)directionsController
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        directionsController.view.frame = CGRectMake(-self.directionsViewController.view.bounds.size.width,
                                                     self.directionsViewController.view.frame.origin.y,
                                                     self.directionsViewController.view.bounds.size.width,
                                                     self.directionsViewController.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [directionsController.view removeFromSuperview];
        [directionsController removeFromParentViewController];
        [self exitDirectionMode];
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
    CLLocationCoordinate2D location = lock.location;
    GMSMarker *lockMarker = [GMSMarker markerWithPosition:location];
    lockMarker.title = lock.name;
    lockMarker.icon = [UIImage imageNamed:@"map_shared_to_me_bike_icon_large"];
    lockMarker.map = self.mapView;
    lockMarker.infoWindowAnchor = CGPointMake(0.0f, 0.0f);
    
    self.lockMarkers[lock.macAddress] = lockMarker;
}

- (void)getDirections
{
    if (!self.selectedLock) {
        NSLog(@"Can't present directions");
        return;
    }
    
    if (self.directions) {
        return;
    }

    SLDirectionAPIHelper *directionsHelper = [[SLDirectionAPIHelper alloc] initWithStart:self.userLocation
                                                                                     end:self.selectedLock.location
                                                                                isBiking:NO];
    [directionsHelper getDirections:^(NSArray *directions, NSString *endAddress) {
        if (!directions || !endAddress) {
            NSLog(@"Error: could not retrieve directions");
            return;
        }
        
        self.directionEndAddress = endAddress;
        self.directions = directions;
        
        [self enterDirectionsMode];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentDirectionsViewControllerWithDirections:directions];
        });
    }];
}

- (void)enterDirectionsMode
{
    if (!self.directions || !self.directionEndAddress) {
        NSLog(@"Error: direcions and/or directionEndAddress not defined");
        return;
    }
    
    if (self.directionDrawingHelper) {
        return;
    }
    
    self.directionDrawingHelper = [[SLDirectionDrawingHelper alloc] initWithMapView:self.mapView
                                                                         directions:self.directions];
    [self.directionDrawingHelper drawDirections:^{}];
}

- (void)exitDirectionMode
{
    self.directions = nil;
    self.directionsViewController = nil;
}

- (void)updateUserPosition:(CLLocationCoordinate2D)userPosition
{
    self.userLocation = userPosition;
    
    if (self.isInitialLoad) {
        [self centerOnUser];
        self.isInitialLoad = NO;
    }
}

#pragma mark - GMS map view delegate methods
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    if (!self.lockInfoViewController) {
        SLLock *selectedLock;
        for (NSString *macAddress in self.lockMarkers.allKeys) {
            GMSMarker *lockMarker = self.lockMarkers[macAddress];
            if (marker == lockMarker) {
                for (SLLock *lock in self.locks) {
                    if ([lock.macAddress isEqualToString:macAddress]) {
                        selectedLock = lock;
                        break;
                    }
                }
            }
        }
        
        if (selectedLock) {
            self.selectedLock = selectedLock;
            [mapView animateToLocation:marker.position];
            [self presentLockInfoViewController];
        }
    }

    return YES;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, .1f, .1f)];
    backgroundView.backgroundColor = [UIColor clearColor];
    
    return backgroundView;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.directionDrawingHelper) {
        [self.directionDrawingHelper removeDirections];
        self.directionDrawingHelper = nil;
    }
    
    if (self.lockInfoViewController) {
        [self removeLockInfoViewController];
    }
    
    self.selectedLock = nil;
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

#pragma mark - SLLockInfoViewControllerDelegate methods
- (void)directionsButtonPressed:(SLLockInfoViewController *)livc
{
    if (!self.selectedLock) {
        return;
    }
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithTarget:self.selectedLock.location zoom:16];
    [self.mapView animateToCameraPosition:cameraPosition];
    
    [self getDirections];
}

@end
