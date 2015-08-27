//
//  SLNotificationManager.m
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationManager.h"
#import "NSString+Skylock.h"
#import "SLNotification.h"
#import "SLNotifications.h"
#import "SLLock.h"
#import "SLAccelerometerValues.h"

@interface SLNotificationManager()

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSDateFormatter *displayFormatter;
@property (nonatomic, strong) NSDateFormatter *fullFormatter;

@end

@implementation SLNotificationManager

- (id)init
{
    self = [super init];
    if (self) {
        _notifications = [NSMutableArray new];
    }
    
    return self;
}

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLNotificationManager *notificationManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationManger = [[self alloc] init];
    });
    
    return notificationManger;
}

- (NSDateFormatter *)displayFormatter
{
    if (!_displayFormatter) {
        _displayFormatter = [NSDateFormatter new];
        [_displayFormatter setDateFormat:@"hh:mm a"];
    }
    
    return _displayFormatter;
}

- (NSDateFormatter *)fullFormatter
{
    if (!_fullFormatter) {
        _fullFormatter = [NSDateFormatter new];
        [_fullFormatter setDateStyle:NSDateFormatterFullStyle];
        [_fullFormatter setTimeStyle:NSDateFormatterFullStyle];
    }
    
    return _fullFormatter;
}

- (NSString *)formattedDisplayTimeForNotificiaton:(SLNotification *)notification
{
    return [self.displayFormatter stringFromDate:notification.date];
}

- (NSString *)formattedFullTimeForNotfication:(SLNotification *)notification
{
    return [self.fullFormatter stringFromDate:notification.date];
}

- (void)setNotificationDateString:(SLNotification *)notification
{
}

- (void)createNotificationOfType:(SLNotificationType)notficationType
{
    SLNotification *notification = [[SLNotification alloc] initWithType:notficationType];
    notification.displayDateString = [self formattedDisplayTimeForNotificiaton:notification];
    notification.fullDateString = [self formattedFullTimeForNotfication:notification];
    notification.delegate = self;
    [self.notifications addObject:notification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationAlertOccured
                                                        object:nil
                                                      userInfo:@{@"notification":notification}];
}

- (NSArray *)getNotifications
{
    return self.notifications;
}

- (void)dismissNotificationWithId:(NSString *)notificationId
{
    NSUInteger index = 0;
    for (SLNotification *notification in self.notifications) {
        if ([notificationId isEqualToString:notification.identifier]) {
            break;
        }
        
        index++;
    }
    
    if (index < self.notifications.count) {
        SLNotification *notification = self.notifications[index];
        [self.notifications removeObjectAtIndex:index];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationAlertDismissed
                                                            object:nil
                                                          userInfo:@{@"notification":notification}];
    }
}

- (void)checkIfLockNeedsNotification:(SLLock *)lock
{
    BOOL sendAlert = YES;
    SLNotificationType alert = SLNotificationTypeNone;
    NSLog(@"Checking accelerometer values: %@", lock.accelerometerVales.asReadableDictionary);
    
//    if ((lock.accelerometerVales.xmav.doubleValue >= SLLockValueThresholdCrashMAV &&
//         lock.accelerometerVales.xvar.doubleValue <= SLLockValueThresholdCrashSD) ||
//        (lock.accelerometerVales.xmav.doubleValue >= SLLockValueThresholdCrashMAV &&
//         lock.accelerometerVales.yvar.doubleValue <= SLLockValueThresholdCrashSD) ||
//        (lock.accelerometerVales.zmav.doubleValue >= SLLockValueThresholdCrashMAV &&
//         lock.accelerometerVales.zvar.doubleValue <= SLLockValueThresholdCrashSD)) {
//        alert = SLNotificationTypeCrashPre;
//    } else if ((lock.accelerometerVales.xmav.doubleValue >= SLLockValueThresholdTheftMediumMAV &&
//                lock.accelerometerVales.xvar.doubleValue <= SLLockValueThresholdTheftMediumSD) ||
//               (lock.accelerometerVales.xmav.doubleValue >= SLLockValueThresholdTheftMediumMAV &&
//                lock.accelerometerVales.yvar.doubleValue <= SLLockValueThresholdTheftMediumSD) ||
//               (lock.accelerometerVales.zmav.doubleValue >= SLLockValueThresholdTheftMediumMAV &&
//                lock.accelerometerVales.zvar.doubleValue <= SLLockValueThresholdTheftMediumSD)) {
//        alert = SLNotificationTypeTheftMedium;
//    } else {
//        sendAlert = NO;
//    }
    if (lock.accelerometerVales.xvar.doubleValue > SLLockValueThresholdCrashSD ||
        lock.accelerometerVales.yvar.doubleValue > SLLockValueThresholdCrashSD ||
        lock.accelerometerVales.zvar.doubleValue > SLLockValueThresholdCrashSD) {
            alert = SLNotificationTypeCrashPre;
        } else if (lock.accelerometerVales.xvar.doubleValue > SLLockValueThresholdTheftMediumSD ||
                   lock.accelerometerVales.yvar.doubleValue > SLLockValueThresholdTheftMediumSD ||
                   lock.accelerometerVales.zvar.doubleValue > SLLockValueThresholdTheftMediumSD) {
                       alert = SLNotificationTypeTheftMedium;
                   } else {
                       sendAlert = NO;
                   }
    if (sendAlert) {
        [self createNotificationOfType:alert];
    }
}

- (void)sendEmergencyText
{
    NSArray *recipients = @[@"4087173377"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationSendEmergecyText
                                                        object:nil
                                                      userInfo:@{@"recipients": recipients}];
}

#pragma mark - SLNotification delegate methods
- (void)notification:(SLNotification *)notfication timerValueUpdated:(NSNumber *)value
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationTimerValueUpdated
                                                        object:nil
                                                      userInfo:@{@"notification":notfication,
                                                                 @"value":value}];
}

- (void)notificationTimerExpired:(SLNotification *)notification
{
    if (notification.type == SLNotificationTypeCrashPre) {
        notification.type = SLNotificationTypeCrashPost;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationTimeExpired
                                                        object:nil
                                                      userInfo:@{@"notification":notification}];
}

@end
