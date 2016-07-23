//
//  SLEmergencyContact.h
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLEmergencyContact : NSManagedObject

- (NSString *)fullName;

@end

NS_ASSUME_NONNULL_END

#import "SLEmergencyContact+CoreDataProperties.h"
