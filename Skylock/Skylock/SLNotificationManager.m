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

@interface SLNotificationManager()

@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSDateFormatter *displayFormatter;
@property (nonatomic, strong) NSDateFormatter *fullFormatter;

@end

@implementation SLNotificationManager


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
    notification.displayDateString = [self formattedTimeForNotifciaton:notification];
    notification.fullDateString = [self formattedFullTimeForNotfication:notification];
    notification.delegate = self;
    [self.notifications addObject:notification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationAlertOccured
                                                        object:nil];
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
    }
    
    
}

#pragma mark - SLNotification delegate methods
- (void)notification:(SLNotification *)notfication timerValueUpdated:(NSNumber *)value
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationTimerValueUpdated
                                                        object:nil
                                                      userInfo:@{@"notification":notfication,
                                                                 @"value":value}];
}
@end
