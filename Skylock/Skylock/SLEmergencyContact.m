//
//  SLEmergencyContact.m
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLEmergencyContact.h"

@implementation SLEmergencyContact

- (NSString *)fullName
{
    NSString *name = @"";
    if (self.firstName) {
        name = self.firstName;
    }
    
    if (self.lastName) {
        name = [NSString stringWithFormat:@"%@ %@", name, self.lastName];
    }
    
    return name;
}

@end
