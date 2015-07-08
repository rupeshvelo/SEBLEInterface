//
//  SLDatabaseManager.m
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDatabaseManager.h"
#import "SLDbLock+Methods.m"
#import "SLLock.h"


#define kSLDatabaseManagerEnityLock @"SLDbLock"

@interface SLDatabaseManager()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end


@implementation SLDatabaseManager

+ (id)manager
{
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
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityLock
                                         inManagedObjectContext:self.context];
}

- (NSArray *)locksFromDbLocks:(NSArray *)dbLocks
{
    NSMutableArray *locks = [NSMutableArray new];
    for (SLDbLock *dbLock in dbLocks) {
        [locks addObject:[SLLock lockWithDataBaseDictionary:dbLock.asDictionary]];
    }
    
    return locks;
}

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    SLDbLock *dbLock = [self getDbLockWithUUID:lock.uuid];
    if (!dbLock) {
        dbLock = [self newDbLock];
    }
    
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

- (NSArray *)getAllLocksFromDb
{
    NSArray *dbLocks = [self getDbLocksWithPredicate:nil];
    NSMutableArray *locks = [NSMutableArray new];
    for (SLDbLock *dbLock in dbLocks) {
        [locks addObject:[SLLock lockWithDbDictionary:dbLock.asDictionary]];
    }
    
    return locks;
}

- (SLDbLock *)getDbLockWithUUID:(NSString *)uuid
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
    NSArray *locks = [self getDbLocksWithPredicate:predicate];
    return locks.count == 0 ? nil : locks[0];
}

- (NSArray *)getDbLocksWithUUIDs:(NSArray *)uuids
{
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
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSLDatabaseManagerEnityLock
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *fetchedLocks = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Failed to fetch locks with error: %@", error.localizedDescription);
        return nil;
    }
    
    return fetchedLocks;
}

- (void)deleteLock:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    SLDbLock *dbLock = [self getDbLockWithUUID:lock.uuid];
    BOOL didSucceed = NO;
    
    if (dbLock) {
        [self.context deleteObject:dbLock];
        didSucceed = YES;
    }
    
    completion(didSucceed);
}
@end
