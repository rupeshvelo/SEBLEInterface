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

@interface SLMapViewController : UIViewController <SLSliceViewControllerDelegate, CLLocationManagerDelegate>

@end