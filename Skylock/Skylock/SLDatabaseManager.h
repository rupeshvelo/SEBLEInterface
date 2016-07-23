//
//  SLDatabaseManager.h
//  Skylock
//
//  Created by Andre Green on 7/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SLUser;
@class SLLock;
@class SLEmergencyContact;
@class NSManagedObjectContext;

@interface SLDatabaseManager : NSObject

@property (strong) SLUser *currentUser;


+(id)sharedManager;

- (void)setContext:(NSManagedObjectContext *)context;

- (void)saveLockToDb:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;
- (NSArray *)allLocks;
- (NSArray *)locksForCurrentUser;
- (void)deleteLock:(SLLock *)lock withCompletion:(void(^)(BOOL success))completion;
- (void)saveUser:(SLUser *)user withCompletion:(void(^)(BOOL success))completion;
- (void)saveUserWithDictionary:(NSDictionary *)dictionary isFacebookUser:(BOOL)isFacebookUser;
- (void)setCurrentUser;
- (SLLock *)getCurrentLockForCurrentUser;
- (NSArray *)sharedContactsForLock:(SLLock *)lock;
- (void)setCurrentLock:(SLLock *)lock;
- (void)deselectAllLocks;
- (SLLock *)getLockWithMacAddress:(NSString *)macAddress;
- (SLLock *)newLockWithName:(NSString *)name andUUID:(NSString *)uuid;
- (BOOL)doesCurrentUserHaveLock:(SLLock *)lock;
- (NSArray *)getAllLogs;
- (void)saveLogEntry:(NSString *)entry;
- (void)saveLockConnectedDate:(SLLock *)lock;
- (void)saveLock:(SLLock *)lock;
- (NSArray *)emergencyContacts;
- (void)saveEmergencyContact:(SLEmergencyContact *)contact;
- (SLEmergencyContact *)getContactWithContactId:(NSString *)contactId;
- (SLEmergencyContact *)newEmergencyContact;
- (void)deleteContactWithId:(NSString *)contactId completion:(void(^)(BOOL success))completion;

@end
