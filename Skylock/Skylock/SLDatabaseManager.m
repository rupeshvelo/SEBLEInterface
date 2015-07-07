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
#import "FMResultSet.h"


#define kSLDatabaseManagerDatabasePath  @"databases"
#define kSLDatabaseManagerDatabaseName  @"skylock.db"
#define kSLDatabaseManagerQueryColumns  @"kSLDatabaseManagerQueryColumns"
#define kSLDatabaseManagerQueryValues   @"kSLDatabaseManagerQueryValues"
#define kSLDatabaseManagerInsertQuery   @"kSLDatabaseManagerInsertQuery"

@interface SLDatabaseManager()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, strong) NSString *databaseDirPath;

@end


@implementation SLDatabaseManager

- (id)init
{
    self = [super init];
    if (self) {
        _database = [self createDatabase];
        _database.traceExecution = YES;
        _database.logsErrors = YES;
        _queue = [FMDatabaseQueue databaseQueueWithPath:self.databasePath];
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

- (NSString *)databaseDirPath
{
    if (!_databaseDirPath) {
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dirPath = [documentPaths firstObject];
        dirPath = [dirPath stringByAppendingPathComponent:kSLDatabaseManagerDatabasePath];
        _databaseDirPath = dirPath;
    }
    
    return _databaseDirPath;
}

- (NSString *)databasePath
{
    return [self.databaseDirPath stringByAppendingPathComponent:kSLDatabaseManagerDatabaseName];
}

- (FMDatabase *)createDatabase
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.databasePath]) {
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kSLDatabaseManagerDatabaseName];
        NSError *error;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.databaseDirPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.databaseDirPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                [NSException raise:@"FAILED TO CREATE DATABASE DIR" format:@"%@", error.localizedDescription];
            }
        }
        
        [[NSFileManager defaultManager] copyItemAtPath:databasePathFromApp toPath:self.databasePath error:&error];
        
        if (error) {
            [NSException raise:@"FAILED TO COPY DATABASE FILE" format:@"%@", error.localizedDescription];
        }
    }
    
    return [FMDatabase databaseWithPath:self.databasePath];
}

- (BOOL)doesDatabaseExist
{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.databasePath];
}

- (void)saveDictionary:(NSDictionary *)dictionary
              forTable:(NSString *)table
                 isNew:(BOOL)isNew
            completion:(void (^)(BOOL success))completion
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        
        NSString *queryString = [self insertQueryFor:dictionary table:table];
        BOOL ok = [db executeQuery:queryString withParameterDictionary:dictionary];
        
        if (!ok) {
            NSLog(@"database failed to save %@\n with error: %@",
                  dictionary,
                  db.lastError.localizedDescription);
        }
        
        if (completion) {
            completion(ok);
        }
            
        [db close];
    }];
}

- (void)saveColumnValues:(NSArray *)columnValues
                forTable:(NSString *)table
                   isNew:(BOOL)isNew
              completion:(void (^)(BOOL))completion
{
    if (![self.database open]) {
        NSLog(@"Could not open database");
    } else {
        NSLog(@"dir path %@", self.databaseDirPath);
        NSString *query = [self insertArrayQuery:columnValues table:table];
        BOOL ok = [self.database executeQuery:query];
        [self.database close];
    }
    
    
//    [self.queue inDatabase:^(FMDatabase *db) {
//        [db open];
//        
//        NSString *query = [self insertArrayQuery:columnValues table:table];
//        BOOL ok = [db executeQuery:query];
//    
//        NSLog(@"last db error: %@", db.lastError.localizedDescription);
//        
//        if (completion) {
//            completion(ok);
//        }
//        
//        [db close];
//    }];
    
}
- (void)getAllObjectsFromTable:(NSString *)table
                withCompletion:(void (^)(NSDictionary *))completion
{
    [self.queue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", table];
        FMResultSet *results = [db executeQuery:query];
        completion(results.resultDictionary);
        [db close];
    }];
    
}

- (NSDictionary *)parametersFromDictionary:(NSDictionary *)dictionary
{
    NSArray *keys = dictionary.allKeys;
    NSString *columns = [NSString stringWithFormat:@"(%@)", [keys componentsJoinedByString:@","]];
    NSMutableString *values = [[NSMutableString alloc] initWithString:@"("];
    
    for (NSUInteger i=0; i < keys.count; i++) {
        [values appendString:@"?"];
        
        if (i == keys.count - 1) {
            [values appendString:@")"];
        } else {
            [values appendString:@","];
        }
    }
    
    NSDictionary *params = @{kSLDatabaseManagerQueryColumns:columns,
                             kSLDatabaseManagerQueryValues:values,
                             };
    
    return params;
}

- (NSString *)insertQueryFor:(NSDictionary *)dictionary table:(NSString *)table
{
    NSDictionary *parts = [self parametersFromDictionary:dictionary];
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@%@ VALUES%@",
                       table,
                       parts[kSLDatabaseManagerQueryColumns],
                       parts[kSLDatabaseManagerQueryValues]];
    
    return query;
}

- (NSString *)insertArrayQuery:(NSArray *)array table:(NSString *)table
{
//    NSMutableString *params = [[NSMutableString alloc] initWithString:@"("];
//    for (NSInteger i=0; i < array.count; i++) {
//        [params appendString:@"?"];
//        if (i == array.count - 1) {
//            [params appendString:@")"];
//        } else {
//            [params appendString:@","];
//        }
//    }
//
//    return [NSString stringWithFormat:@"INSERT INTO %@ VALUES%@", table, params];
    
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"INSERT INTO %@ VALUES(", table];
    for (NSUInteger i=0; i < array.count; i++) {
        id value = array[i];
        BOOL isString = [value isKindOfClass:[NSString class]] && ![value isEqual:@"null"];
        if (isString) {
            [query appendString:@"\""];
        }
        
        [query appendFormat:@"%@", value];
        
        if (isString) {
            [query appendString:@"\""];
        }
        
        if (i == array.count - 1) {
            [query appendString:@")"];
        } else {
            [query appendString:@","];
        }
    }
    
    return query;
}
@end
