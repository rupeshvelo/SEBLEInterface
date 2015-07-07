//
//  SLDatabaseManager.h
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSLDatabaseManagerTableOwner    @"owner"
#define kSLDatabaseManagerTableLock     @"lock"

@interface SLDatabaseManager : NSObject

+(id)manager;
- (void)saveDictionary:(NSDictionary *)dictionary
              forTable:(NSString *)table
                 isNew:(BOOL)isNew
            completion:(void(^)(BOOL success))completion;

- (void)saveColumnValues:(NSArray *)columnValues
                forTable:(NSString *)table
                   isNew:(BOOL)isNew
              completion:(void(^)(BOOL success))completion;

- (NSArray *)getAllObjectsWithInfo:(NSDictionary *)info forTable:(NSString *)table;

- (NSArray *)allObjectsWithColumnValues:(NSArray *)columnValues forTable:(NSString *)table;

- (void)getAllObjectsFromTable:(NSString *)table withCompletion:(void (^)(NSDictionary *results))completion;
@end
