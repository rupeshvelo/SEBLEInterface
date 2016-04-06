//
//  SLAccountInfoViewController.h
//  Skylock
//
//  Created by Andre Green on 7/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLAccountInfoFieldView.h"
#import "SLCirclePicView.h"

@class SLUser;

@interface SLAccountInfoViewController : UIViewController <SLCirclePicViewDelegate>

@property (nonatomic, strong) SLUser *user;

@end
