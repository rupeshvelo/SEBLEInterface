//
//  SLFacebookManger.m
//  Skylock
//
//  Created by Andre Green on 7/7/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLFacebookManger.h"


@interface SLFacebookManger()

@property (nonatomic, strong) NSArray *permissions;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSData *imageData;

@end


@implementation SLFacebookManger

+(id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLFacebookManger *facebookManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        facebookManager = [[self alloc] init];
    });
    
    return facebookManager;
}

- (id)init
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self = [super init];
    if (self) {
        _permissions = @[@"public_profile", @"email", @"user_friends"];
    }
    return self;
}

- (void)applicationBecameActive
{
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application finishedLauchingWithOptions:(NSDictionary *)options
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:options];

}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)currentToken
{
    return [FBSDKAccessToken currentAccessToken];
}

- (void)loginWithCompletion:(void (^)(void))completion
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:self.permissions
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
            }
        }
    }];
}

- (void)getFBUserInfo
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
}

@end
