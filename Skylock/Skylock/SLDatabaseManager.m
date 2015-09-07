//
//  SLDatabaseManager.m
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDatabaseManager.h"
#import "SLDbLock+Methods.h"
#import "SLDbUser+Methods.h"
#import "SLLock.h"
#import "SLUser.h"

#define kSLDatabaseManagerEnityLock @"SLDbLock"
#define kSLDatabaseManagerEnityUser @"SLDbUser"

@interface SLDatabaseManager()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation SLDatabaseManager

+ (id)manager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLDatabaseManager *dbManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        dbManager = [[self alloc] init];
    });
    
    return dbManager;
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
}

- (SLDbLock *)newDbLock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityLock
                                         inManagedObjectContext:self.context];
}

- (NSArray *)locksFromDbLocks:(NSArray *)dbLocks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *locks = [NSMutableArray new];
    for (SLDbLock *dbLock in dbLocks) {
        [locks addObject:[SLLock lockWithDbDictionary:dbLock.asDictionary]];
    }
    
    return locks;
}

- (NSArray *)sharedContactsForLock:(SLLock *)lock
{
    SLDbLock *dbLock = [self dbLockForLock:lock];
    return dbLock.sharedContacts.allObjects;
}

- (NSArray *)getManagedObjectsWithPredicate:(NSPredicate *)predicate forEnityNamed:(NSString *)enityName
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:enityName
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Failed to fetch objects with error: %@", error.localizedDescription);
        return nil;
    }
    
    return fetchedObjects;
}

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    SLDbLock *dbLock = [self getDbLockWithUUID:lock.uuid];
    if (!dbLock) {
        dbLock = [self newDbLock];
    }
    
    dbLock.user = self.currentUser;
    [dbLock updatePropertiesWithDictionary:lock.asDbDictionary];
    
    NSError *error;
    BOOL success = NO;
    if ([self.context save:&error]) {
        success = YES;
    } else {
        NSLog(@"Failed to save lock to database with error: %@", error.localizedDescription);
    }
    
    if (completion) {
        completion(success);
    }
}

- (void)setCurrentLock:(SLLock *)lock
{
    NSArray *locks = self.currentUser.locks.allObjects;
    [locks enumerateObjectsUsingBlock:^(SLDbLock *dbLock, NSUInteger idx, BOOL *stop) {
        BOOL isCurrent = [dbLock.name isEqualToString:lock.name];
        dbLock.isCurrentLock = @(isCurrent);
    }];
    
    [self saveUser:self.currentUser withCompletion:nil];
}

- (void)deselectAllLocks
{
    NSArray *locks = self.currentUser.locks.allObjects;
    [locks enumerateObjectsUsingBlock:^(SLDbLock *dbLock, NSUInteger idx, BOOL *stop) {
        dbLock.isCurrentLock = @(NO);
    }];
    
    [self saveUser:self.currentUser withCompletion:nil];
}

- (NSArray *)getAllLocksFromDb
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSArray *dbLocks = [self getDbLocksWithPredicate:nil];
    NSMutableArray *locks = [NSMutableArray new];
    for (SLDbLock *dbLock in dbLocks) {
        [locks addObject:[SLLock lockWithDbDictionary:dbLock.asDictionary]];
    }
    
    return locks;
}

- (NSArray *)locksForCurrentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableArray *locks = [NSMutableArray new];
    for (SLDbLock *dbLock in self.currentUser.locks.allObjects) {
        SLLock *lock = [SLLock lockWithDbDictionary:dbLock.asDictionary];
        [locks addObject:lock];
    }
    
    return locks;
}

- (SLDbLock *)getDbLockWithUUID:(NSString *)uuid
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    NSArray *locks = [self getDbLocksWithPredicate:predicate];
    return (locks && locks.count > 0) ? locks[0] : nil;
}

- (SLDbLock *)dbLockForLock:(SLLock *)lock
{
    return [self getDbLockWithUUID:lock.uuid];
}

- (NSArray *)getDbLocksWithUUIDs:(NSArray *)uuids
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSMutableString *predicateString = [NSMutableString new];
    for (NSUInteger i=0; i < uuids.count; i++) {
        [predicateString appendString:@"uuid == %@"];
        
        if (i != uuids.count - 1) {
            [predicateString appendString:@" OR "];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString
                                                argumentArray:uuids];
    return [self getDbLocksWithPredicate:predicate];
}

- (NSArray *)getDbLocksWithPredicate:(NSPredicate *)predicate
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self getManagedObjectsWithPredicate:predicate forEnityNamed:kSLDatabaseManagerEnityLock];
}

- (void)deleteLock:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLDbLock *dbLock = [self getDbLockWithUUID:lock.uuid];
    BOOL didSucceed = NO;
    
    if (dbLock) {
        [self.context deleteObject:dbLock];
        didSucceed = YES;
    }
    
    completion(didSucceed);
}

- (void)saveFacebookUserWithDictionary:(NSDictionary *)dictionary
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLDbUser *facebookUser = [self getDbUserWithEmail:dictionary[@"email"]];
    
    if (facebookUser && self.currentUser) {
        // facebook suer and current user exist. Check to see if they are
        // the same user
        if ([facebookUser.email isEqualToString:self.currentUser.email]) {
            // the facebook user the current user. update the current user
            [self.currentUser setPropertiesWithDictionary:dictionary];
        } else {
            // facebook user is not the current user. The facebook user should
            // become the current user
            self.currentUser.isCurrentUser = @(NO);
            facebookUser.isCurrentUser = @(YES);
            [facebookUser setPropertiesWithDictionary:dictionary];
            [self saveUser:self.currentUser withCompletion:nil];
            [self setCurrentUser];
        }
    } else if (self.currentUser) {
        // user exists and facebook user does not. check to see if
        // the current user matches the info in the facebook hash
        if ([self.currentUser.email isEqualToString:dictionary[@"email"]]) {
            [self.currentUser setPropertiesWithDictionary:dictionary];
            [self saveUser:self.currentUser withCompletion:nil];
        } else {
            // the current user does not match the info in the facebook hash
            // create a new user and make it the current user
            self.currentUser.isCurrentUser = @(NO);
            facebookUser = self.newDbUser;
            [facebookUser setPropertiesWithDictionary:dictionary];
            facebookUser.isCurrentUser = @(YES);
            [self saveUser:facebookUser withCompletion:nil];
            [self setCurrentUser];
        }
    } else if (facebookUser) {
        // there is no current user set
        [facebookUser setPropertiesWithDictionary:dictionary];
        facebookUser.isCurrentUser = @(YES);
        [self saveUser:facebookUser withCompletion:nil];
        [self setCurrentUser];
    } else {
        // there is no current user or facebook user
        facebookUser = self.newDbUser;
        [facebookUser setPropertiesWithFacebookDictionary:dictionary];
        facebookUser.isCurrentUser = @(YES);
        [self saveUser:facebookUser withCompletion:nil];
        [self setCurrentUser];
    }
}

- (SLDbUser *)newDbUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityUser
                                         inManagedObjectContext:self.context];
}

- (void)setCurrentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrentUser == 1"];
    NSArray *users = [self getDBUsersWithPredicate:predicate];
    if (users && users.count > 0) {
        self.currentUser = users[0];
    }
}

- (void)saveUser:(SLDbUser *)user withCompletion:(void (^)(BOOL))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSError *error;
    BOOL success = NO;
    if ([self.context save:&error]) {
        success = YES;
    } else {
        NSLog(@"Failed to save user to database with error: %@", error.localizedDescription);
    }
    
    if (completion) {
        completion(success);
    }
}

- (SLDbUser *)getDbUserWithEmail:(NSString *)email
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email == %@", email];
    NSArray *users = [self getDBUsersWithPredicate:predicate];
    return (users && users.count > 0) ? users[0] : nil;
}

- (NSArray *)getDBUsersWithPredicate:(NSPredicate *)predicate
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self getManagedObjectsWithPredicate:predicate forEnityNamed:kSLDatabaseManagerEnityUser];
}
@end
