//
//  SLSettingsViewController.h
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLBackButton.h"

@class SLLock;

@interface SLSettingsViewController : UIViewController <SLBackButtonDelegate>

@property (nonatomic, strong) SLLock *lock;

@end
