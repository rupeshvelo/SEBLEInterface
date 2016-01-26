//
//  SLMapViewController.h
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLSlideViewController.h"
#import "SLLocationManager.h"
#import "SLCoachMarkViewController.h"
#import "SLLockInfoViewController.h"
#import "SLNotificationViewController.h"
#import <MessageUI/MessageUI.h>
#import "SLAnnotationDirectionCalloutView.h"
#import "SLDirectionsViewController.h"

@import GoogleMaps;

@interface SLMapViewController : UIViewController <
SLSlideViewControllerDelegate,
SLCoachMarkViewControllerDelegate,
SLLockInfoViewControllerDelegate,
UIAlertViewDelegate,
CLLocationManagerDelegate,
SLNotificationViewControllerDelegate,
MFMessageComposeViewControllerDelegate,
SLDirectionsViewControllerDelegate,
GMSMapViewDelegate>

@end