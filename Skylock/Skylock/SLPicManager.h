//
//  SLPicManager.h
//  Skylock
//
//  Created by Andre Green on 7/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLPicManager : NSObject

+ (id)sharedManager;

- (void)getPicWithUserId:(NSString *)userId withCompletion:(void(^)(UIImage *))completion;
- (void)refreshProfilePicCache;
- (void)facebookPicForFBUserId:(NSString *)fbUserId
                    completion:(void(^)(UIImage *))completion;
- (UIImage *)userImageForUserId:(NSString *)userId;
- (void)savePicture:(UIImage *)image forUserId:(NSString *)userId;
@end
