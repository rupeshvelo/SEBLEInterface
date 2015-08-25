//
//  SLNotificationManager.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNotification.h"

@interface SLNotificationManager : NSObject <SLNotficationDelegate>

+ (id)manager;
- (NSString *)formattedTimeForNotifciaton:(SLNotification *)notification;
- (void)createNotificationOfType:(SLNotificationType)notficationType;
- (NSArray *)getNotifications;
- (void)dismissNotificationWithId:(NSString *)notificationId;

@end
