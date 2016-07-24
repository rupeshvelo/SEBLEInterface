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
#import "SLDatabaseManager.h"
#import "SLUser.h"

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

+ (id)sharedManager
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
    // do this since only one notification can be displayed at a time
    if (self.notifications.count == 0) {
        SLNotification *notification = [[SLNotification alloc] initWithType:notficationType];
        notification.displayDateString = [self formattedDisplayTimeForNotificiaton:notification];
        notification.fullDateString = [self formattedFullTimeForNotfication:notification];
        [self.notifications addObject:notification];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationAlertOccured
                                                            object:notification
                                                          userInfo:nil];
    }
}

- (NSArray *)getNotifications
{
    return self.notifications;
}

- (SLNotification *)lastNotification
{
    if (self.notifications.count == 0) {
        return nil;
    }
    
    return [self.notifications lastObject];
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

- (void)removeLastNotification
{
    if (self.notifications.count == 0) {
        return;
    }
    
    [self.notifications removeLastObject];
}
- (void)checkIfLockNeedsNotification:(SLLock *)lock
{
    BOOL sendAlert = YES;
    SLNotificationType alert = SLNotificationTypeNone;
    SLDatabaseManager *dbManager = [SLDatabaseManager sharedManager];
    SLUser *user = dbManager.currentUser;
    if (!user) {
        return;
    }
    
    double mav = (lock.accelerometerVales.xmav.doubleValue + lock.accelerometerVales.ymav.doubleValue +
                  lock.accelerometerVales.zmav.doubleValue)/3.0;
    double stdDev = (lock.accelerometerVales.xvar.doubleValue + lock.accelerometerVales.yvar.doubleValue +
                     lock.accelerometerVales.zvar.doubleValue)/3.0;
    NSLog(@"mav: %f, stddev: %f", mav, stdDev);
    
    if (user.areCrashAlertsOn.boolValue && mav >= SLLockValueThresholdCrashMAV
        && stdDev >= SLLockValueThresholdCrashSD)
    {
        alert = SLNotificationTypeCrashPre;
    } else if (user.areTheftAlertsOn.boolValue && mav >= SLLockValueThresholdTheftMAV
               && stdDev > SLLockValueThresholdTheftSD)
    {
        alert = SLNotificationTypeTheft;
    } else {
        sendAlert = NO;
    }
    
    if (sendAlert) {
        [self createNotificationOfType:alert];
    }
}

- (void)sendEmergencyText
{
    NSLog(@"Will send emergency text...soon");
}

@end
