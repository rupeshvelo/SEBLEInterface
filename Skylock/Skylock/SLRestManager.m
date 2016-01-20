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

- (NSString *)serverUrl:(SLRestManagerServerKey)serverKey
{
    NSString *url;
    switch (serverKey) {
        case SLRestManagerServerKeyMain:
            url = @"https://skylock-beta.herokuapp.com/api/v1/";
            break;
        default:
            break;
    }
    
    return url;
}

- (NSString *)pathUrl:(SLRestManagerPathKey)pathKey
{
    NSString *url;
    switch (pathKey) {
        case SLRestManagerPathKeyChallengeData:
            url = @"users/11111/challenge_data/";
            break;
        case SLRestManagerPathKeyChallengeKey:
            url = @"users/11111/challenge_key/";
            break;
        case SLRestManagerPathKeyKeys:
            url = @"users/11111/keys/";
            break;
        default:
            break;
    }
    
    return url;
}

- (NSURL *)urlWithServerKey:(SLRestManagerServerKey)serverKey
                    pathKey:(SLRestManagerPathKey)pathKey
                    options:(NSArray *)options
{
    NSUInteger counter = 0;
    NSString *serverUrl = [NSString stringWithFormat:@"%@%@",
                           [self serverUrl:serverKey],
                           [self pathUrl:pathKey]
                           ];
    NSMutableString *url = [NSMutableString stringWithString:serverUrl];
    
    if (options && options.count > 0) {
        for (NSString *option in options) {
            [url appendString:option];
            if (counter < options.count - 1) {
                [url appendString:@"/"];
            }
            
            counter++;
        }
    }
    
    return [NSURL URLWithString:url];
}

- (void)getRequestWithServerKey:(SLRestManagerServerKey)serverKey
                            pathKey:(SLRestManagerPathKey)pathKey
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
                                                [self handleServerReply:data
                                                               response:response
                                                                  error:error
                                                            originalUrl:url
                                                             completion:completion];
                                            }];
    [task resume];
}

- (void)postObject:(NSDictionary *)object
         serverKey:(SLRestManagerServerKey)serverKey
           pathKey:(SLRestManagerPathKey)pathKey
        completion:(void (^)(NSDictionary *responseDict))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURL *url = [self urlWithServerKey:serverKey pathKey:pathKey options:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@(jsonData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:jsonData
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          [self handleServerReply:data
                                                                         response:response
                                                                            error:error
                                                                      originalUrl:url
                                                                       completion:completion];
                                                      }];
    
    [uploadTask resume];
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

- (void)handleServerReply:(NSData *)data
                 response:(NSURLResponse *)response
                    error:(NSError *)error
              originalUrl:(NSURL *)originalUrl
               completion:(void (^)(NSDictionary *responseDict))completion
{
    if (error) {
    // TODO -- add error handling
        NSLog(@"Error could not fetch request from: %@. Failed with error: %@. Complete reponse: %@",
              originalUrl.absoluteString,
              error,
              response
              );
        completion(nil);
        return;
    }
    
    NSDictionary *serverReply = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&error];
    
    if (error) {
        NSLog(@"Error could decode json object for fetch request: %@. Failed with error: %@",
              originalUrl.absoluteString,
              error
              );
        completion(nil);
        return;
    }
    
    NSLog(@"server reply: %@", serverReply.description);
    NSString *status = serverReply[@"status"];
    if (![status isEqualToString:@"success"]) {
        NSLog(@"Error in response from server: %@", serverReply[@"message"]);
        completion(nil);
        return;
    }
    
    completion(serverReply[@"payload"]);
}

@end
