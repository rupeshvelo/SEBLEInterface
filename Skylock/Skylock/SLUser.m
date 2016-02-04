//
//  SLUser.m
//  Skylock
//
//  Created by Andre Green on 1/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLUser.h"
#import "SLLock.h"

#define kSLUserTypeFacebook @"facebook"
#define kSLUserTypePhone    @"phone"

@implementation SLUser

@synthesize location;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.firstName      = [self valueOrNullForDictionary:dictionary key:@"firstName"];
        self.lastName       = [self valueOrNullForDictionary:dictionary key:@"lastName"];
        self.userId         = [self valueOrNullForDictionary:dictionary key:@"userId"];
        self.googlePushId   = [self valueOrNullForDictionary:dictionary key:@"googlePushId"];
        self.userType       = [self valueOrNullForDictionary:dictionary key:@"userType"];
    }
    
    return self;
}
- (id)initWithFacebookDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.firstName      = [self valueOrNullForDictionary:dictionary key:@"first_name"];
        self.lastName       = [self valueOrNullForDictionary:dictionary key:@"last_name"];
        self.userId         = [self valueOrNullForDictionary:dictionary key:@"id"];
        self.googlePushId   = [self valueOrNullForDictionary:dictionary key:@"googlePushId"];
        self.userType       = kSLUserTypeFacebook;
    }
    
    return self;
}

- (NSDictionary *)asDictionary
{
    return @{@"first_name": self.firstName,
             @"user_id": self.userId,
             @"last_name": self.lastName,
             @"email": self.email ? self.email : [NSNull null],
             @"fb_flag": @([self.userType isEqualToString:@"facebook"]),
             @"reg_id": self.googlePushId
             };
}

- (void)setPropertiesWithFBDictionary:(NSDictionary *)dictionary
{
    if (dictionary[@"first_name"]) {
        self.firstName = dictionary[@"first_name"];
    }
    
    if (dictionary[@"last_name"]) {
        self.lastName = dictionary[@"last_name"];
    }
    
    if (dictionary[@"id"]) {
        self.userId = dictionary[@"id"];
    }
    
    if (dictionary[@"googlePushId"]) {
        self.googlePushId = dictionary[@"googlePushId"];
    }
    
    if (dictionary[@"email"]) {
        self.email = dictionary[@"email"];
    }
    
    self.userType = kSLUserTypeFacebook;
}

- (void)setPropertiesWithRegularUserDictionary:(NSDictionary *)dictionary
{
    
}

- (id)valueOrNullForDictionary:(NSDictionary *)dictionary key:(id)value
{
    return dictionary[value] ? dictionary[value] : [NSNull null];
}

- (NSString *)fullName
{
    if (self.firstName && self.lastName) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else if (self.firstName) {
        return self.firstName;
    }
    
    return nil;
}

@end
