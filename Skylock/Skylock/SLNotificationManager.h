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
    SLLockValueThresholdTheftMediumSD = 1100,
};

@interface SLNotificationManager : NSObject <SLNotficationDelegate>

+ (id)manager;
- (NSString *)formattedDisplayTimeForNotifciaton:(SLNotification *)notification;
- (void)createNotificationOfType:(SLNotificationType)notficationType;
- (NSArray *)getNotifications;
- (void)dismissNotificationWithId:(NSString *)notificationId;
- (void)checkIfLockNeedsNotification:(SLLock *)lock;

@end
