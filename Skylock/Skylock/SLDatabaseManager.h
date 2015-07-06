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
- (BOOL)saveDictionary:(NSDictionary *)dictionary forTable:(NSString *)table isNew:(BOOL)isNew;

@end
