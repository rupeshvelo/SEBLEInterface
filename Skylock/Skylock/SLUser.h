//
//  SLUser.h
//  Skylock
//
//  Created by Andre Green on 1/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class SLLock;

NS_ASSUME_NONNULL_BEGIN

@interface SLUser : NSManagedObject

@property (nonatomic, assign) CLLocationCoordinate2D location;

- (id)initWithFacebookDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asDictionary;
- (NSString *)fullName;
- (void)setPropertiesWithFBDictionary:(NSDictionary *)dictionary;
- (void)setPropertiesWithRegularUserDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "SLUser+CoreDataProperties.h"
