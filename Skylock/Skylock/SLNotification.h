//
//  SLNotification.h
//  Skylock
//
//  Created by Andre Green on 8/24/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLNotification;

typedef NS_ENUM(NSUInteger, SLNotificationType) {
    SLNotificationTypeTheftLow,
    SLNotificationTypeTheftMedium,
    SLNotificationTypeTheftHigh,
    SLNotificationTypeCrashPre,
    SLNotificationTypeCrashPost
};

@protocol SLNotficationDelegate <NSObject>

- (void)notification:(SLNotification *)notfication timerValueUpdated:(NSNumber *)value;

@end

@interface SLNotification : NSObject

@property (nonatomic, weak) id <SLNotficationDelegate> delegate;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, assign) SLNotificationType type;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *displayDateString;
@property (nonatomic, copy) NSString *fullDateString;
@property (nonatomic, copy) NSString *identifier;

- (id)initWithType:(SLNotificationType)notificaitonType;

@end
