//
//  SLRestManager.h
//  Skylock
//
//  Created by Andre Green on 6/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLRestManagerResponse) {
    SLRestManagerResponseForbidden = 401,
    SLRestManagerResponseNotFound = 400,
    SLRestManagerResponseOk = 800
};

@interface SLRestManager : NSObject

+ (instancetype)sharedManager;

- (void)restGetRequestWithURL:(NSString *)urlString
                      options:(NSArray *)options
                   completion:(void(^)(NSDictionary *responseDict))completion;

- (void)getPictureFromUrl:(NSString *)url withCompletion:(void(^)(NSData *))completion;
@end
