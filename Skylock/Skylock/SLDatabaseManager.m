//
//  SLDatabaseManager.m
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDatabaseManager.h"
#import "NSString+Skylock.h"
#import "SLLock.h"
#import "SLUser.h"

#define kSLDatabaseManagerEnityLock @"SLLock"
#define kSLDatabaseManagerEnityUser @"SLUser"

@interface SLDatabaseManager()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation SLDatabaseManager

+ (id)sharedManager
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

- (SLLock *)newLock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityLock
                                         inManagedObjectContext:self.context];
}

- (SLLock *)newLockWithName:(NSString *)name andUUID:(NSString *)uuid
{
    SLLock *lock;
    NSArray *dbLocks = self.allLocks;
    
    for (SLLock *dbLock in dbLocks) {
        if ([dbLock.macAddress isEqualToString:name.macAddress]) {
            lock = dbLock;
            break;
        }
    }
    
    if (!lock) {
        lock = self.newLock;
        lock.name = name;
        lock.uuid = uuid;
        lock.macAddress = name.macAddress;
    }
    
    return lock;
}

- (NSArray *)sharedContactsForLock:(SLLock *)lock
{
    return lock.sharedContacts.allObjects;
}

- (NSArray *)getManagedObjectsWithPredicate:(NSPredicate *)predicate
                              forEnityNamed:(NSString *)enityName
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
    
    NSError *error;
    BOOL success = [self.context save:&error];
    if (!success) {
        NSLog(@"Failed to save lock to database with error: %@", error.localizedDescription);
    }
    
    if (completion) {
        completion(success);
    }
}

- (void)setCurrentLock:(SLLock *)lock
{
    NSArray *locks = self.currentUser.locks.allObjects;
    [locks enumerateObjectsUsingBlock:^(SLLock *dbLock, NSUInteger idx, BOOL *stop) {
        dbLock.isCurrentLock = @(NO);
    }];
    
    lock.isCurrentLock = @(YES);
    
    [self saveUser:self.currentUser withCompletion:nil];
}

- (void)deselectAllLocks
{
    NSArray *locks = self.currentUser.locks.allObjects;
    [locks enumerateObjectsUsingBlock:^(SLLock *dbLock, NSUInteger idx, BOOL *stop) {
        dbLock.isCurrentLock = @(NO);
    }];
    
    [self saveUser:self.currentUser withCompletion:nil];
}

- (NSArray *)allLocks
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self getLocksWithPredicate:nil];
}

- (NSArray *)locksForCurrentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return self.currentUser.locks.allObjects;
}

- (SLLock *)getLockWithUUID:(NSString *)uuid
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    NSArray *locks = [self getLocksWithPredicate:predicate];
    return (locks && locks.count > 0) ? locks[0] : nil;
}

- (SLLock *)getLockWithMacAddress:(NSString *)macAddress
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"macAddress == %@", macAddress];
    NSArray *locks = [self getLocksWithPredicate:predicate];
    if (locks && locks.count > 0) {
        return [locks firstObject];
    }
    
    return nil;
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
    return [self getLocksWithPredicate:predicate];
}

- (NSArray *)getLocksWithPredicate:(NSPredicate *)predicate
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self getManagedObjectsWithPredicate:predicate forEnityNamed:kSLDatabaseManagerEnityLock];
}

- (void)deleteLock:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    BOOL didSucceed = NO;
    
    if (lock) {
        [self.context deleteObject:lock];
        didSucceed = YES;
    }
    
    completion(didSucceed);
}

- (void)saveUserWithDictionary:(NSDictionary *)dictionary isFacebookUser:(BOOL)isFacebookUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    SLUser *user = [self getUserWithUserId:dictionary[@"id"]];
    
    if (user && self.currentUser) {
        // user and current user exist. Check to see if they are
        // the same user
        if ([user.userId isEqualToString:self.currentUser.userId]) {
            // the facebook user the current user. update the current user
            [self.currentUser setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
        } else {
            // facebook user is not the current user. The facebook user should
            // become the current user
            self.currentUser.isCurrentUser = @(NO);
            user.isCurrentUser = @(YES);
            [user setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
            [self saveUser:self.currentUser withCompletion:nil];
            [self setCurrentUser];
        }
    } else if (self.currentUser) {
        // user exists and facebook user does not. check to see if
        // the current user matches the info in the facebook hash
        if ([self.currentUser.userId isEqualToString:dictionary[@"id"]]) {
            [self.currentUser setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
            [self saveUser:self.currentUser withCompletion:nil];
        } else {
            // the current user does not match the info in the facebook hash
            // create a new user and make it the current user
            self.currentUser.isCurrentUser = @(NO);
            user = self.newDbUser;
            [user setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
            user.isCurrentUser = @(YES);
            [self saveUser:user withCompletion:nil];
            [self setCurrentUser];
        }
    } else if (user) {
        // there is no current user set
        [user setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
        user.isCurrentUser = @(YES);
        [self saveUser:user withCompletion:nil];
        [self setCurrentUser];
    } else {
        // there is no current user or facebook user
        user = self.newDbUser;
        [user setPropertiesWithDictionary:dictionary isFacebookUser:isFacebookUser];
        user.isCurrentUser = @(YES);
        [self saveUser:user withCompletion:nil];
        [self setCurrentUser];
    }
}

- (SLUser *)newDbUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityUser
                                         inManagedObjectContext:self.context];
}

- (void)setCurrentUser
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isCurrentUser == 1"];
    NSArray *users = [self getUsersWithPredicate:predicate];
    if (users && users.count > 0) {
        self.currentUser = users[0];
    }
}

- (void)saveUser:(SLUser *)user withCompletion:(void (^)(BOOL))completion
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

- (SLUser *)getUserWithUserId:(NSString *)userId
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    NSArray *users = [self getUsersWithPredicate:predicate];
    
    return (users && users.count > 0) ? users[0] : nil;
}

- (NSArray *)getUsersWithPredicate:(NSPredicate *)predicate
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return [self getManagedObjectsWithPredicate:predicate forEnityNamed:kSLDatabaseManagerEnityUser];
}
@end
