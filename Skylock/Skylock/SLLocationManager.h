//
//  SLLocationManager.h
//  Skylock
//
//  Created by Andre Green on 6/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface SLLocationManager : CLLocationManager

typedef NS_ENUM(NSUInteger, SLLocationManagerPermissionState) {
    SLLocationManagerPermissionStateGranted,
    SLLocationManagerPermissionStateDenied
};

//+(id)locationManager;

//@property(nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, assign) SLLocationManagerPermissionState persmissionState;

@end
