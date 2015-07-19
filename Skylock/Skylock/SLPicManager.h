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

+ (id)manager;

- (void)getPicWithEmail:(NSString *)email withCompletion:(void(^)(UIImage *))completion;
- (void)savePicture:(UIImage *)image named:(NSString *)name;
- (void)refreshProfilePicCache;

@end
