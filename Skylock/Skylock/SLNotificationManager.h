//
//  SLNotificationManager.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNotification.h"

@class SLLock;

typedef NS_ENUM(NSUInteger, SLLockValueThreshold) {
    SLLockValueThresholdCrashMAV = 60,
    SLLockValueThresholdCrashSD = 1500,
    SLLockValueThresholdTheftMediumMAV = 60,
    SLLockValueThresholdTheftMediumSD = 1000,
};

@interface SLNotificationManager : NSObject <SLNotficationDelegate>

+ (id)sharedManager;
- (void)createNotificationOfType:(SLNotificationType)notficationType;
- (NSArray *)getNotifications;
- (void)dismissNotificationWithId:(NSString *)notificationId;
- (void)checkIfLockNeedsNotification:(SLLock *)lock;
- (void)sendEmergencyText;

@end
