//
//  SLFacebookManger.m
//  Skylock
//
//  Created by Andre Green on 7/7/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLFacebookManger.h"
#import "SLUserDefaults.h"
#import "SLNotifications.h"
#import "SLDatabaseManager.h"
#import "SLRestManager.h"
#import "SLPicManager.h"


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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application finishedLauchingWithOptions:(NSDictionary *)options
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
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
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [FBSDKAccessToken currentAccessToken];
}

- (void)loginWithCompletion:(void (^)(void))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:self.permissions
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {

        } else if (result.isCancelled) {

        } else {
            [self getFBUserInfo];
        }
    }];
}

- (void)getFBUserInfo
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 [self userInfoRecieved:result];
             }
         }];
    }
}

- (void)userInfoRecieved:(NSDictionary *)info
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"fetched user:%@", info);

    [SLDatabaseManager.manager saveFacebookUserWithDictionary:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationUserSignedInFacebook
                                                        object:nil];
}

- (void)getFacebookPicForUserId:(NSString *)userId  email:(NSString *)email withCompletion:(void (^)(UIImage *))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [SLPicManager.manager getPicWithEmail:email withCompletion:^(UIImage *image) {
        if (image) {
            completion(image);
            return;
        }
        
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];
        [SLRestManager.manager getPictureFromUrl:url withCompletion:^(NSData *data) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                completion(image);
                [SLPicManager.manager savePicture:image named:email];
                return;
            }
            
            completion(nil);
        }];
    }];
}
@end
