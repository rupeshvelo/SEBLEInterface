//
//  SLDbUser+Methods.m
//  Skylock
//
//  Created by Andre Green on 7/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDbUser+Methods.h"

@implementation SLDbUser (Methods)

- (NSDictionary *)asDictionary
{
    return @{@"firstName":self.firstName,
             @"lastName":self.lastName,
             @"email":self.email,
             @"facebookId":self.facebookId,
             @"facebookLink":self.facebookLink,
             @"gender":self.gender,
             @"isCurrentUser":self.isCurrentUser
             };
}


- (void)setPropertiesWithDictionary:(NSDictionary *)dictionary
{
    self.firstName      = dictionary[@"firstName"];
    self.lastName       = dictionary[@"lastName"];
    self.facebookId     = dictionary[@"id"];
    self.facebookLink   = dictionary[@"link"];
    self.gender         = dictionary[@"gender"];
    self.email          = dictionary[@"email"];
    self.isCurrentUser  = dictionary[@"isCurrentUser"];
}

- (void)setPropertiesWithFacebookDictionary:(NSDictionary *)dictionary
{
    self.firstName      = dictionary[@"first_name"];
    self.lastName       = dictionary[@"last_name"];
    self.facebookId     = dictionary[@"id"];
    self.facebookLink   = dictionary[@"link"];
    self.gender         = dictionary[@"gender"];
    self.email          = dictionary[@"email"];
    self.isCurrentUser  = dictionary[@"isCurrentUser"];
}

- (NSString *)fullName
{
    if (!self.lastName) {
        return self.firstName;
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}
@end
