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

#define kSLUserTypeFacebook @"facebook"
#define kSLUserTypeEllipse  @"ellipse"

@interface SLUser : NSManagedObject

@property (nonatomic, assign) CLLocationCoordinate2D location;

- (id)initWithFacebookDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)asRestDictionary;
- (NSString *)fullName;
- (void)setPropertiesWithDictionary:(NSDictionary *)dictionary isFacebookUser:(BOOL)isFacebookUser;
- (NSString *)countryCode;

@end

NS_ASSUME_NONNULL_END

#import "SLUser+CoreDataProperties.h"
