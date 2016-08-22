//
//  AppDelegate.m
//  Skylock
//
//  Created by Andre Green on 6/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAppDelegate.h"
#import "SLDatabaseManager.h"
#import "SLFacebookManger.h"
#import "SLMapViewController.h"
#import "SLUserDefaults.h"
#import "UIColor+RGB.h"
#import "SLUserDefaults.h"
#import "SLNotifications.h"
#import "SLNotificationManager.h"
#import "Ellipse-Swift.h"
#import <Google/CloudMessaging.h>

#define kSLAppDelegateNotificationActionIgnore  @"kSLAppDelegateNotificationActionIgnore"
#define kSLAppDelegateNotificationActionHelp    @"kSLAppDelegateNotificationActionHelp"
#define kSLAppDelegateNotificationCategory      @"kSLAppDelegateNotificationCategory"


@interface SLAppDelegate ()

@end

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SLDatabaseManager.sharedManager setContext:self.managedObjectContext];
    [SLDatabaseManager.sharedManager setCurrentUser];
    [[SLLockManager sharedManager] startBluetoothManager];
    
    NSString *googleMapApiKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GoogleMapsApiKey"];
    [GMSServices provideAPIKey:googleMapApiKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.initialViewController;
    [self.window makeKeyAndVisible];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kSLNotificationAlertOccured
                                               object:nil];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:215 green:215 blue:215];;
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:102 green:177 blue:227];
    pageControl.backgroundColor = [UIColor clearColor];
        
    return [SLFacebookManger.sharedManager application:application finishedLauchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[SLLockManager sharedManager] resetAllCurrentUserLocksToUndetected];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    [SLFacebookManger.sharedManager applicationBecameActive];
    [[SLLockManager sharedManager] setCurrentLockToDetected];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [SLFacebookManger.sharedManager application:application
                                         openURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSLNotificationUserAcceptedNotifications
                                                        object:nil];
    
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    
    NSDictionary *options = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                              kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];

    [GGLInstanceID.sharedInstance
     tokenWithAuthorizedEntity:@"750134088591"
     scope:kGGLInstanceIDScopeGCM
     options:options
     handler:^(NSString *token, NSError *error) {
         // TODO: This needs to be fixed in the google dev panel.
         // This is a tempory fix
         if (error) {
             NSLog(@"Error getting google cloud service token %@", error.localizedDescription);
             //return;
         }
         
         if (!token) {
             token = @"00000000000000000000000000000";
         }
         
         NSLog(@"got token: %@", token);
         dispatch_async(dispatch_get_main_queue(), ^{
             NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
             [ud setObject:token forKey:SLUserDefaultsPushNotificationToken];
             [ud synchronize];
         });
     }];
}

- (UIViewController *)initialViewController
{
    UIViewController *initialVC;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:SLUserDefaultsSignedIn]) {
        NSNumber *isSignedIn = [ud objectForKey:SLUserDefaultsSignedIn];
        if (isSignedIn.boolValue) {
            if ([ud objectForKey:SLUserDefaultsOnBoardingComplete]) {
                SLLockViewController *lvc = [SLLockViewController new];
                initialVC = lvc;
            } else {
                SLConnectLockInfoViewController *clvc = [SLConnectLockInfoViewController new];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:clvc];
                nc.navigationBar.barStyle = UIBarStyleBlack;
                nc.navigationBar.tintColor = [UIColor whiteColor];
                nc.navigationBar.barTintColor = [UIColor color:130 green:156 blue:178];
                initialVC = nc;
            }
        } else {
            SLOnboardingPageViewController *opvc = [SLOnboardingPageViewController new];
            initialVC = opvc;
        }
    } else {
        SLOnboardingPageViewController *opvc = [SLOnboardingPageViewController new];
        initialVC = opvc;
    }
    
//    SLLockViewController *lvc = [SLLockViewController new];
//    initialVC = lvc;
//    
//    SLConfirmTextCodeViewController *ctcvc = [SLConfirmTextCodeViewController new];
//    initialVC = ctcvc;
    
    return initialVC;
}

- (void)setUpNotficationSettings
{
    UIApplication *application = [UIApplication sharedApplication];
    
    [[GCMService sharedInstance] startWithConfig:[GCMConfig defaultConfig]];
    
    UIMutableUserNotificationAction *ignoreAction = [UIMutableUserNotificationAction new];
    ignoreAction.identifier = kSLAppDelegateNotificationActionIgnore;
    ignoreAction.title = NSLocalizedString(@"Ignore", nil);
    ignoreAction.activationMode = UIUserNotificationActivationModeBackground | UIUserNotificationActivationModeForeground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationAction *helpAction = [UIMutableUserNotificationAction new];
    helpAction.identifier = kSLAppDelegateNotificationActionHelp;
    helpAction.title = NSLocalizedString(@"Help", nil);
    helpAction.activationMode = UIUserNotificationActivationModeBackground | UIUserNotificationActivationModeForeground;
    helpAction.destructive = NO;
    helpAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *notficationCategory = [UIMutableUserNotificationCategory new];
    notficationCategory.identifier = kSLAppDelegateNotificationCategory;
    [notficationCategory setActions:@[helpAction, ignoreAction]
                         forContext:UIUserNotificationActionContextDefault];
    [notficationCategory setActions:@[helpAction, ignoreAction]
                         forContext:UIUserNotificationActionContextMinimal];
    
    UIUserNotificationType notificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes
                                                                             categories:[NSSet setWithObject:notficationCategory]];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)postNotification:(SLNotification *)notification
{
    NSArray *notifications = [SLNotificationManager.sharedManager getNotifications];
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.category = kSLAppDelegateNotificationCategory;
    localNotification.alertBody = notification.detailText;
    localNotification.alertAction = NSLocalizedString(@"Ignore", nil);
    localNotification.alertTitle = notification.mainText;
    localNotification.applicationIconBadgeNumber = notifications.count;
    localNotification.userInfo = @{@"notificationId": notification.identifier};
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

- (void)handleNotification:(NSNotification *)notification
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    SLNotification *slNotification = notification.object;
    if ((state == UIApplicationStateBackground || state == UIApplicationStateInactive) && slNotification) {
        [self postNotification:slNotification];
    }
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    NSDictionary *info = notification.userInfo;
    NSString *notificationIdentifier = info[@"notificationId"];
    
    if ([notificationIdentifier isEqualToString:kSLAppDelegateNotificationActionIgnore]) {
        [SLNotificationManager.sharedManager dismissNotificationWithId:notificationIdentifier];
    } else {
        [SLNotificationManager.sharedManager sendEmergencyText];
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Greuw.Skylock" in the application's documents directory.
    NSURL *dirUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSLog(@"Application documents directory: %@", dirUrl.absoluteString);
    return dirUrl;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Skylock" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Skylock.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
