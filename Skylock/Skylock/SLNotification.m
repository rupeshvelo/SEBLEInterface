//
//  SLNotification.m
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotification.h"
#import "NSString+Skylock.h"

#define kSLNotificationTimerValue   30

@interface SLNotification()

@property (nonatomic, assign) NSUInteger timerValue;

@end

@implementation SLNotification

- (id)initWithType:(SLNotificationType)notificaitonType
{
    self = [super init];
    if (self) {
        _type = notificaitonType;
        _date = [NSDate date];
        [self setText];
    }
    
    return self;
}

- (NSString *)identifier
{
    if (!_identifier) {
        _identifier = [NSString stringWithFormat:@"%@_%@_%@",
                       self.mainText,
                       self.detailText,
                       self.fullDateString];
    }
    
    return _identifier;
}

- (void)setText
{
    switch (self.type) {
        case SLNotificationTypeCrashPre:
            self.mainText = NSLocalizedString(@"Skylock Crash Alert", nil);
            self.detailText = NSLocalizedString(@"Ignore this or get some help", nil);
            break;
        case SLNotificationTypeCrashPost:
            self.mainText = NSLocalizedString(@"Skylock Crash Alert", nil);
            self.detailText = NSLocalizedString(@"Emergency contacts notified", nil);
            break;
        case SLNotificationTypeTheftLow:
            self.mainText = NSLocalizedString(@"Skylock Theft Alert", nil);
            self.detailText = NSLocalizedString(@"Low Threat", nil);
            break;
        case SLNotificationTypeTheftMedium:
            self.mainText = NSLocalizedString(@"Skylock Theft Alert", nil);
            self.detailText = NSLocalizedString(@"Medium Threat", nil);
            break;
        case SLNotificationTypeTheftHigh:
            self.mainText = NSLocalizedString(@"Skylock Theft Alert", nil);
            self.detailText = NSLocalizedString(@"High Threat", nil);
            break;
        default:
            break;
    }
}

- (void)startCountdown
{
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(timerFired:)
                                   userInfo:nil
                                    repeats:YES];
    self.timerValue = kSLNotificationTimerValue;
}

- (void)timerFired:(NSTimer *)timer
{
    if (self.timerValue == 0) {
        [timer invalidate];
        
        if ([self.delegate respondsToSelector:@selector(notificationTimerExpired:)]) {
            [self.delegate notificationTimerExpired:self];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(notification:timerValueUpdated:)]) {
        [self.delegate notification:self timerValueUpdated:@(self.timerValue)];
    }
    
    self.timerValue--;
}
@end
