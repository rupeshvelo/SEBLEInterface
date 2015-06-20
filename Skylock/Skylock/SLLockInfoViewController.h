//
//  SLLockInfoViewController.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLLockInfoViewHeader.h"
#import "SLLockInfoMiddleView.h"
#import "SLLockInfoBottomView.h"

@interface SLLockInfoViewController : UIViewController <SLLockInfoViewHeaderDelegate, SLLockMiddleViewDelegate, SLLockInfoBottomViewDelegate>

@property (nonatomic, strong) SLLock *lock;

@end
