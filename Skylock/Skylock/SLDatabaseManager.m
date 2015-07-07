//
//  SLDatabaseManager.m
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDatabaseManager.h"
#import "AppDelegate.h"
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

- (NSManagedObjectContext *)context
{
    if (!_context) {
        _context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    
    return _context;
}

- (SLDbLock *)newDBLock
{
    return [NSEntityDescription insertNewObjectForEntityForName:kSLDatabaseManagerEnityLock
                                         inManagedObjectContext:self.context];
}

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void (^)(BOOL))completion
{
    SLDbLock *dbLock = self.newDBLock;
    [dbLock setProperitesWithDictionary:lock.asDbDictionary];
    
    NSError *error;
    if ([self.context save:&error]) {
        completion(YES);
    } else {
        NSLog(@"Failed to save lock to database with error: %@", error.localizedDescription);
    }
}

- (NSArray *)getAllLocksFromDb
{
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSLDatabaseManagerEnityLock
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *fetchedLocks = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Failed to fetch all locks with error: %@", error.localizedDescription);
        return nil;
    }
    
    return fetchedLocks;
}

@end
