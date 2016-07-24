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
@class SLNotification;

typedef NS_ENUM(NSUInteger, SLLockValueThreshold) {
    SLLockValueThresholdCrashMAV = 900,
    SLLockValueThresholdCrashSD = 500,
    SLLockValueThresholdTheftMAV = 500,
    SLLockValueThresholdTheftSD = 350,
};


@interface SLNotificationManager : NSObject

+ (id)sharedManager;
- (void)createNotificationOfType:(SLNotificationType)notficationType;
- (NSArray *)getNotifications;
- (SLNotification *)lastNotification;
- (void)dismissNotificationWithId:(NSString *)notificationId;
- (void)checkIfLockNeedsNotification:(SLLock *)lock;
- (void)sendEmergencyText;
- (void)removeLastNotification;

@end
