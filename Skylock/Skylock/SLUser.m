//
//  SLUser.m
//  Skylock
//
//  Created by Andre Green on 7/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLUser.h"

@implementation SLUser

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _firstName      = dictionary[@"firstName"];
        _lastName       = dictionary[@"lastName"];
        _facebookId     = dictionary[@"id"];
        _facebookLink   = dictionary[@"link"];
        _gender         = dictionary[@"gender"];
        _email          = dictionary[@"email"];
    }
    
    return self;
}
- (id)initWithFacebookDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _firstName      = dictionary[@"first_name"];
        _lastName       = dictionary[@"last_name"];
        _facebookId     = dictionary[@"id"];
        _facebookLink   = dictionary[@"link"];
        _gender         = dictionary[@"gender"];
        _email          = dictionary[@"email"];
    }
    
    return self;
}

- (NSDictionary *)asDictionary
{
    return @{@"firstName":self.firstName,
             @"lastName":self.lastName,
             @"facebookId":self.facebookId,
             @"facebookLink":self.facebookLink,
             @"gender":self.gender,
             @"email":self.email
             };
}

@end
