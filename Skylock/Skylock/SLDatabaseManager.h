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


+(id _Nonnull)sharedManager;

- (void)setContext:(NSManagedObjectContext * _Nonnull)context;
- (SLUser * _Nullable)getCurrentUser;
- (void)saveLockToDb:(SLLock * _Nonnull)lock withCompletion:(void(^ _Nullable)(BOOL success))completion;
- (NSArray * _Nullable)allLocks;
- (NSArray * _Nullable)locksForCurrentUser;
- (void)deleteLock:(SLLock * _Nonnull)lock withCompletion:(void(^ _Nullable)(BOOL success))completion;
- (void)saveUser:(SLUser * _Nonnull)user withCompletion:(void(^ _Nullable)(BOOL success))completion;
- (void)saveUserWithDictionary:(NSDictionary * _Nonnull)dictionary isFacebookUser:(BOOL)isFacebookUser;
- (void)setCurrentUser;
- (SLLock * _Nullable)getCurrentLockForCurrentUser;
- (NSArray * _Nullable)sharedContactsForLock:(SLLock * _Nonnull)lock;
- (void)setCurrentLock:(SLLock * _Nonnull)lock;
- (void)deselectAllLocks;
- (SLLock * _Nullable)getLockWithMacAddress:(NSString * _Nonnull)macAddress;
- (SLLock * _Nullable)newLockWithName:(NSString * _Nonnull)name andUUID:(NSString * _Nonnull)uuid;
- (BOOL)doesCurrentUserHaveLock:(SLLock * _Nonnull)lock;
- (NSArray * _Nonnull)getAllLogs;
- (void)saveLogEntry:(NSString * _Nonnull)entry;
- (void)saveLockConnectedDate:(SLLock * _Nonnull)lock;
- (void)saveLock:(SLLock * _Nullable)lock;
- (NSArray * _Nullable)emergencyContacts;
- (void)saveEmergencyContact:(SLEmergencyContact * _Nonnull)contact;
- (SLEmergencyContact * _Nullable)getContactWithContactId:(NSString * _Nonnull)contactId;
- (SLEmergencyContact * _Nonnull)newEmergencyContact;
- (void)deleteContactWithId:(NSString * _Nonnull)contactId completion:(void(^ _Nullable)(BOOL success))completion;

@end
