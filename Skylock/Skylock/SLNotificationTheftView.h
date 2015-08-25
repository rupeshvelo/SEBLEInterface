//
//  SLNotificationTheftView.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNotification.h"

@interface SLNotificationTheftView : UIView

- (id)initWithFrame:(CGRect)frame notification:(SLNotification *)notification;
- (void)updateTimerValue
@end
