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
#import "Skylock-Swift.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SLUser.h"
#import "SLDatabaseManager.h"


@interface SLFacebookManger()

@property (nonatomic, strong) NSArray *permissions;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSData *imageData;

@end


@implementation SLFacebookManger

+(id)sharedManager
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
        _permissions = @[@"public_profile",
                         @"email",
                         @"user_friends"
                         ];
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

- (void)loginFromViewController:(UIViewController *)fromViewController withCompletion:(void (^)(void))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:self.permissions
                 fromViewController:fromViewController
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                if (error) {
                                    NSLog(@"Error logging into facebook %@", error.description);
                                } else if (result.isCancelled) {
                                    NSLog(@"Canceled login to facebook");
                                } else {
                                    [self getFBUserInfo];
                                }
                            }];
}

- (void)getFBUserInfo
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([FBSDKAccessToken currentAccessToken]) {
        NSString *fields = @"id, name, link, first_name, last_name, picture.type(large), email";
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                           parameters:@{@"fields": fields}]
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
    
    SLKeychainHandler *keychainHandler = [SLKeychainHandler new];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *modifiedInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    NSString *pushToken = nil;
    if ([ud objectForKey:SLUserDefaultsPushNotificationToken]) {
        pushToken = [ud objectForKey:SLUserDefaultsPushNotificationToken];
    } else {
        [SLDatabaseManager.sharedManager saveLogEntry:
         @"No google push token retreived. Creating a false token"];
    }
    
    NSAssert(pushToken != nil, @"Push notification is not defined");
    
    modifiedInfo[@"googlePushId"] = pushToken;
    [SLDatabaseManager.sharedManager saveUserWithDictionary:modifiedInfo isFacebookUser:YES];
    
    NSString *userId = info[@"id"];
    [SLPicManager.sharedManager facebookPicForFBUserId:userId completion:nil];
    
    SLUser *user = [SLDatabaseManager.sharedManager currentUser];
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithDictionary:user.asDictionary];
    userDict[@"password"] = userId;
    
    [keychainHandler setItemForUsername:user.userId
                             inputValue:userId
                   additionalSeviceInfo:nil
                            handlerCase:SLKeychainHandlerCasePassword];
    
    [SLRestManager.sharedManager postObject:userDict
                                  serverKey:SLRestManagerServerKeyMain
                                    pathKey:SLRestManagerPathKeyUsers
                                  subRoutes:nil
                          additionalHeaders:nil
                                 completion:^(NSDictionary *responseDict) {
                                     if (!responseDict || !responseDict[@"token"]) {
                                         NSLog(@"No response or user token when saving facebook user");
                                         [SLDatabaseManager.sharedManager saveLogEntry:
                                          @"No response or user token when saving facebook user"];
                                         return;
                                     }
                                     
                                     NSString *message = [NSString stringWithFormat:
                                                          @"got response saving facebook userId: %@ Response Info: %@",
                                                          userDict,
                                                          responseDict];
                                     NSLog(@"%@", message);
                                     [SLDatabaseManager.sharedManager saveLogEntry:message];
                                     
                                     [keychainHandler setItemForUsername:user.userId
                                                              inputValue:responseDict[@"token"]
                                                    additionalSeviceInfo:nil
                                                             handlerCase:SLKeychainHandlerCaseRestToken];;
                                 }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationUserSignedInFacebook
                                                        object:nil];
}

- (void)getFacebookPicForUserId:(NSString *)userId withCompletion:(void (^)(UIImage *))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];
    [SLRestManager.sharedManager getPictureFromUrl:url withCompletion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (completion) {
                completion(image);
            }
            
            return;
        }
        
        if (completion) {
           completion(nil); 
        }
    }];
}


@end
