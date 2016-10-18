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

+ (id _Nonnull)sharedManager;
- (void)createNotificationOfType:(SLNotificationType)notficationType;
- (NSArray * _Nullable)getNotifications;
- (SLNotification * _Nullable)lastNotification;
- (void)dismissNotificationWithId:(NSString * _Nonnull)notificationId;
- (void)checkIfLockNeedsNotification:(SLLock * _Nonnull)lock;
- (void)sendEmergencyText;
- (void)removeLastNotification;

@end
