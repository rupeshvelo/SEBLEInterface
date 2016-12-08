//
//  SLRestManager.h
//  Skylock
//
//  Created by Andre Green on 6/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLRestManagerResponse) {
    SLRestManagerResponseForbidden = 401,
    SLRestManagerResponseNotFound = 400,
    SLRestManagerResponseOk = 800
};

typedef NS_ENUM(NSUInteger, SLRestManagerServerKey) {
    SLRestManagerServerKeyMain
};

typedef NS_ENUM(NSUInteger, SLRestManagerPathKey) {
    SLRestManagerPathKeyChallengeKey,
    SLRestManagerPathKeyChallengeData,
    SLRestManagerPathKeyKeys,
    SLRestManagerPathKeyUsers,
    SLRestManagerPathKeyFirmwareUpdate,
    SLRestManagerPathKeyFirmwareVersion,
    SLRestManagerPathKeyPhoneVerificaiton,
    SLRestManagerPathKeyPhoneCodeVerification,
    SLRestManagerPathKeyProfile,
    SLRestManagerPathKeyPasswordReset,
    SLRestManagerPathKeyPasswordCode,
    SLRestManagerPathKeyNewPassword
};


@interface SLRestManager : NSObject

+ (id _Nonnull)sharedManager;

- (void)getRequestWithServerKey:(SLRestManagerServerKey)serverKey
                        pathKey:(SLRestManagerPathKey)pathKey
                      subRoutes:(NSArray * _Nullable)subRoutes
              additionalHeaders:(NSDictionary * _Nullable)additionalHeaders
                     completion:(void (^ _Nullable)(NSUInteger status, NSDictionary * _Nullable))completion;

- (void)postObject:(NSDictionary * _Nonnull)object
         serverKey:(SLRestManagerServerKey)serverKey
           pathKey:(SLRestManagerPathKey)pathKey
         subRoutes:(NSArray * _Nullable)subRoutes
 additionalHeaders:(NSDictionary * _Nullable)additionalHeaders
        completion:(void (^ _Nullable)(NSUInteger, NSDictionary * _Nullable))completion;

- (void)getPictureFromUrl:(NSString * _Nonnull)url withCompletion:(void(^ _Nullable)(NSData * _Nullable))completion;

- (NSString * _Nonnull)basicAuthorizationHeaderValueUsername:(NSString * _Nonnull)username password:(NSString * _Nonnull)password;

- (void)getGoogleDirectionsFromUrl:(NSString * _Nonnull)urlString completion:(void(^ _Nonnull)(NSData * _Nullable))completion;

- (NSString * _Nonnull)pathAsString:(SLRestManagerPathKey)pathKey;

@end
