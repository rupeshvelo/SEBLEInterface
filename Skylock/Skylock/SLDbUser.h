//
//  SLDbUser.h
//  Skylock
//
//  Created by Andre Green on 1/19/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLDbLock;

NS_ASSUME_NONNULL_BEGIN

@interface SLDbUser : NSManagedObject

- (id)initWithFacebookDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;
- (void)setPropertiesWithFBDictionary:(NSDictionary *)dictionary;
- (NSString *)fullName;

@end

NS_ASSUME_NONNULL_END

#import "SLDbUser+CoreDataProperties.h"
