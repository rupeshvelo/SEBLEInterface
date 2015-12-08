//
//  SLRestManager.m
//  Skylock
//
//  Created by Andre Green on 6/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLRestManager.h"

#define kSLRestManagerTimeout   30


@interface SLRestManager()

@property (nonatomic, strong) NSDictionary *serverUrls;
@property (nonatomic, strong) NSDictionary *pathUrls;

@end


@implementation SLRestManager

+ (instancetype)sharedManager
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    static SLRestManager *restManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        restManager = [[self alloc] init];
    });
    
    return restManager;
}

- (NSDictionary *)serverUrls
{
    if (!_serverUrls) {
        _serverUrls = @{@"server0":@"http://skylock-beta.herokuapp.com/"};
    }
    
    return _serverUrls;
}

- (NSDictionary *)pathUrls
{
    if (!_pathUrls) {
        _pathUrls = @{
                      @"challengeKey": @"users/11111/challenge_key/",
                      @"challengeData": @"users/11111/challenge_data/"
                      };
    }
    
    return _pathUrls;
}

- (NSURL *)urlWithServerKey:(NSString *)serverKey
                    pathKey:(NSString *)pathKey
                    options:(NSArray *)options
{
    NSUInteger counter = 0;
    NSString *serverUrl = [NSString stringWithFormat:@"%@%@",
                           self.serverUrls[serverKey],
                           self.pathUrls[pathKey]
                           ];
    NSMutableString *url = [NSMutableString stringWithString:serverUrl];
    
    if (options && options.count > 0) {
        for (NSString *option in options) {
            [url appendString:self.pathUrls[option]];
            if (counter < self.pathUrls.count - 1) {
                [url appendString:@"/"];
            }
            
            counter++;
        }
    }
    
    return [NSURL URLWithString:url];
}

- (void)restGetRequestWithServerKey:(NSString *)serverKey
                            pathKey:(NSString *)pathKey
                            options:(NSArray *)options
                         completion:(void (^)(NSDictionary *responseDict))completion
{
    NSURL *url = [self urlWithServerKey:serverKey pathKey:pathKey options:options];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                if (error) {
                                                    // TODO -- add error handling
                                                    NSLog(@"Error could not fetch request from: %@. Failed with error: %@",
                                                          url.absoluteString,
                                                          error
                                                          );
                                                    completion(nil);
                                                    return;
                                                }
                                                
                                                NSDictionary *serverReply = [NSJSONSerialization JSONObjectWithData:data
                                                                                                            options:0
                                                                                                              error:&error];
                                                if (error) {
                                                    NSLog(@"Error could decode json object for fetch request: %@. Failed with error: %@",
                                                          url.absoluteString,
                                                          error
                                                          );
                                                    completion(nil);
                                                    return;
                                                }
                                                
                                                NSString *status = serverReply[@"status"];
                                                if ([status isEqualToString:@"error"]) {
                                                    completion(nil);
                                                    return;
                                                }
                                                
                                                completion(serverReply);
                                            }];
    [task resume];
}

- (void)getPictureFromUrl:(NSString *)url withCompletion:(void (^)(NSData *))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                                NSLog(@"response: %@", response);
                                                                
                                                                if (error) {
                                                                    NSLog(@"Error downloading pic: %@", error.localizedDescription);
                                                                    completion(nil);
                                                                    return;
                                                                }
                                                                
                                                                NSData *responseData = [NSData dataWithContentsOfURL:location];
                                                                completion(responseData);
                                                            }];
    [downloadTask resume];
}
// add Post and Put

@end