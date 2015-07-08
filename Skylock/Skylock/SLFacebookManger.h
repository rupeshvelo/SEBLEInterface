//
//  SLFacebookManger.h
//  Skylock
//
//  Created by Andre Green on 7/7/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SLFacebookManger : NSObject

+ (id)manager;
- (void)signIn;
- (void)signOut;
- (void)setUp;
- (void)applicationBecameActive;
- (BOOL)application:(UIApplication *)application finishedLauchingWithOptions:(NSDictionary *)options;
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;
- (BOOL)currentToken;
- (void)loginWithCompletion:(void(^)(void))completion;

@end
