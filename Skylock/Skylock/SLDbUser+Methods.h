//
//  SLDbUser+Methods.h
//  Skylock
//
//  Created by Andre Green on 7/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDbUser.h"

@interface SLDbUser (Methods)

- (NSDictionary *)asDictionary;
- (void)setPropertiesWithDictionary:(NSDictionary *)dictionary;
- (void)setPropertiesWithFacebookDictionary:(NSDictionary *)dictionary;
- (NSString *)fullName;

@end
