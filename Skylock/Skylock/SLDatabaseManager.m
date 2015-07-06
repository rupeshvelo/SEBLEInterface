//
//  SLDatabaseManager.m
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDatabaseManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

#define kSLDatabaseManagerDataBaseName  @"SLDatabase.sqlite"
#define kSLDatabaseManagerQueryKeys     @"kSLDatabaseManagerQueryKeys"
#define kSLDatabaseManagerQueryValues   @"kSLDatabaseManagerQueryValues"
#define kSLDatabaseManagerQueryObjects  @"kSLDatabaseManagerQueryObjects"
#define kSLDatabaseManagerInsertQuery   @"kSLDatabaseManagerInsertQuery"

@interface SLDatabaseManager()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (assign) BOOL dbCreated;
@end


@implementation SLDatabaseManager

- (id)init
{
    self = [super init];
    if (self) {
        NSString *databasePath = self.databasePath;
        _database = [FMDatabase databaseWithPath:databasePath];
        _queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        [self createTables];
    }
    
    return self;
}

+ (id)manager
{
    static SLDatabaseManager *dbManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        dbManager = [[self alloc] init];
    });
    
    return dbManager;
}

- (NSString *)databasePath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [documentPaths firstObject];
    return [dirPath stringByAppendingPathComponent:kSLDatabaseManagerDataBaseName];
}

- (BOOL)doesDatabaseExist
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dirPath = [documentPaths firstObject];
    NSString *filePath = [dirPath stringByAppendingPathComponent:kSLDatabaseManagerDataBaseName];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (NSString *)createTableQuery
{
    NSString *owners = @"CREATE TABLE SLDatabase.owner( \
                            ownerIdNumber INTEGER PRIMARY KEY NOT NULL, \
                            firstName TEXT, \
                            lastName TEXT, \
                            username TEXT);";
    
    NSString *lockTable = @"CREATE TABLE SLDatabase.lock( \
                                lockIdNumber INTEGER PRIMARY KEY NOT NULL, \
                                lockId TEXT, \
                                name TEXT, \
                                latitude REAL, \
                                longitued REAL, \
                                FOREIGN KEY(ownerIdNumber) REFERENCES owners(ownerIdNumber));";
    
    return [NSString stringWithFormat:@"%@%@", owners, lockTable];
}

- (void)createTables
{
    [self.database executeUpdate:self.createTableQuery];
}

- (BOOL)saveDictionary:(NSDictionary *)dictionary forTable:(NSString *)table isNew:(BOOL)isNew
{
    [self.queue inDatabase:^(FMDatabase *db) {
       db execute
    }];
}

- (NSDictionary *)parametersFromDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = dictionary.allKeys;
    NSMutableString *names = [[NSMutableString alloc] initWithString:@"("];
    [names appendString:[keys componentsJoinedByString:@","]];
    [names appendString:@")"];
    NSMutableString *values = [[NSMutableString alloc] initWithString:@"("];
    NSMutableArray *objects = [NSMutableArray new];
    NSUInteger counter = 0;
    for (id key in keys) {
        id value = dictionary[key];
        [objects addObject:value];
        
        [values appendString:@"?"];
        
        if (counter == keys.count - 1) {
            [values appendString:@")"];
        } else {
            [values appendString:@","];
        }
        
        counter++;
    }
    
    NSDictionary *params = @{kSLDatabaseManagerQueryKeys:keys,
                             kSLDatabaseManagerQueryValues:values,
                             kSLDatabaseManagerQueryObjects:objects
                             };
    
    return params;
}

- (NSDictionary *)insertQueryFor:(NSDictionary *)dictionary table:(NSString *)table
{
    NSDictionary *parts = [self parametersFromDictionary:dictionary];
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@",
                       table,
                       parts[kSLDatabaseManagerQueryKeys],
                       parts[kSLDatabaseManagerQueryValues]];
    
    return @{kSLDatabaseManagerInsertQuery:query,
             kSLDatabaseManagerQueryObjects:parts[kSLDatabaseManagerQueryObjects]
             };
}
@end
