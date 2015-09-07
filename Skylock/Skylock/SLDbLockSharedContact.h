//
//  SLDbLockSharedContact.h
//  Skylock
//
//  Created by Andre Green on 9/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SLDbLock;

@interface SLDbLockSharedContact : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSDate * dateShared;
@property (nonatomic, retain) NSDate * dateSharedWith;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) SLDbLock *lock;

@end
