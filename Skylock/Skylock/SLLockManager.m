//
//  SLLockManager.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockManager.h"
#import "SLLock.h"
#include <stdlib.h>

@interface SLLockManager()

@property (nonatomic, strong) NSMutableDictionary *locks;
@property (nonatomic, strong) NSMutableArray *lockOrder;

@end

@implementation SLLockManager

- (id)init
{
    self = [super init];
    if (self) {
        _locks      = [NSMutableDictionary new];
        _lockOrder  = [NSMutableArray new];
    }
    
    return self;
}

+ (id)manager
{
    static SLLockManager *lockManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lockManger = [[self alloc] init];
    });
    
    return lockManger;
}

- (BOOL)containsLock:(SLLock *)lock
{
    return [self.locks objectForKey:lock.lockId];
}

- (void)addLock:(SLLock *)lock
{
    if (![self containsLock:lock]) {
        self.locks[lock.lockId] = lock;
        [self.lockOrder addObject:lock.lockId];
    }
}

- (void)removeLock:(SLLock *)lock
{
    if ([self containsLock:lock]) {
        [self.locks removeObjectForKey:lock.lockId];
        [self.lockOrder removeObject:lock.lockId];
    }
}

- (NSArray *)orderedLocks
{
    NSMutableArray *locks = [NSMutableArray new];
    for (NSString *lockId in self.lockOrder) {
        [locks addObject:self.locks[lockId]];
    }
    
    return locks;
}

- (SLLock *)getTestLock
{
    // mock lock data for testing
    SLLock *lock1 = [[SLLock alloc] initWithName:@"One Love"
                                batteryRemaining:@(46.7)
                                    wifiStrength:@(56.8)
                                    cellStrength:@(87.98)
                                        lastTime:@(354)
                                    distanceAway:@(12765)
                                        isLocked:@(YES)
                                          lockId:@"bkdidlldie830387jdod9"];
    
    SLLock *lock2 = [[SLLock alloc] initWithName:@"Three Little Birds"
                                batteryRemaining:@(99)
                                    wifiStrength:@(56)
                                    cellStrength:@(45.21)
                                        lastTime:@(65)
                                    distanceAway:@(100)
                                        isLocked:@(NO)
                                          lockId:@"opdkdopwp08djwwkddidh"];
    
    SLLock *lock3 = [[SLLock alloc] initWithName:@"Buffalo Soldier"
                                batteryRemaining:@(2.98)
                                    wifiStrength:@(45)
                                    cellStrength:@(464)
                                        lastTime:@(45)
                                    distanceAway:@(1256)
                                        isLocked:@(YES)
                                          lockId:@"pdidmhjdghsjsyy27d6th"];
    
    int target = arc4random_uniform(3);
    NSArray *locks = @[lock1, lock2, lock3];

    return locks[target];
}
@end
