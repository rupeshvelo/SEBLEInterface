//
//  SLDbLock+Methods.m
//  Skylock
//
//  Created by Andre Green on 7/6/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDbLock+Methods.h"

@implementation SLDbLock (Methods)

- (NSDictionary *)asDictionary
{
    return @{@"uuid":self.uuid,
             @"name":self.name,
             @"latitude":self.latitude,
             @"longitude":self.longitude
             };
}

- (void)setProperitesWithDictionary:(NSDictionary *)dictionary
{
    self.uuid = dictionary[@"uuid"];
    self.name = dictionary[@"name"];
    self.latitude = dictionary[@"latitude"];
    self.longitude = dictionary[@"longitude"];
}

@end
