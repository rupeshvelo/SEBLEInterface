//
//  SLUser.m
//  Skylock
//
//  Created by Andre Green on 1/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLUser+CoreDataProperties.h"
#import "SLUser.h"
#import "SLLock.h"

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
        self.phoneNumber    = [self valueOrNullForDictionary:dictionary key:@"phoneNumber"];
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

- (NSDictionary *)asRestDictionary
{
    return @{@"first_name": self.firstName,
             @"user_id": self.userId,
             @"last_name": self.lastName,
             @"email": self.email ? self.email : [NSNull null],
             @"user_type": self.userType,
             @"reg_id": self.googlePushId,
             };
}

- (void)setPropertiesWithDictionary:(NSDictionary *)dictionary isFacebookUser:(BOOL)isFacebookUser
{
    if (dictionary[@"first_name"] && dictionary[@"first_name"] != [NSNull null]) {
        self.firstName = dictionary[@"first_name"];
    }
    
    if (dictionary[@"last_name"] && dictionary[@"last_name"] != [NSNull null]) {
        self.lastName = dictionary[@"last_name"];
    }
    
    if (dictionary[@"id"]) {
        self.userId = dictionary[@"id"];
    }
    
    if (dictionary[@"user_id"]) {
        self.userId = dictionary[@"user_id"];
        
        if (!isFacebookUser) {
            self.phoneNumber = dictionary[@"user_id"];
        }
    }
    
    if (dictionary[@"googlePushId"]) {
        self.googlePushId = dictionary[@"googlePushId"];
    }
    
    if (dictionary[@"reg_id"]) {
        self.googlePushId = dictionary[@"reg_id"];
    }
    
    if (dictionary[@"email"]) {
        self.email = dictionary[@"email"];
    }
    
    self.userType = isFacebookUser ? kSLUserTypeFacebook : kSLUserTypeEllipse;
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
