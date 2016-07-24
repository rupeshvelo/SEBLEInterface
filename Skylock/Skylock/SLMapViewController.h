//
//  SLMapViewController.h
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SLAnnotationDirectionCalloutView.h"
#import "SLDirectionsViewController.h"

@import GoogleMaps;

@interface SLMapViewController : UIViewController <
UIAlertViewDelegate,
MFMessageComposeViewControllerDelegate,
SLDirectionsViewControllerDelegate,
GMSMapViewDelegate
>

- (void)updateUserPosition:(CLLocationCoordinate2D)userPosition;

@end