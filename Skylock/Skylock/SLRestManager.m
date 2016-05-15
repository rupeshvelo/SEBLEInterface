//
//  SLRestManager.m
//  Skylock
//
//  Created by Andre Green on 6/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLRestManager.h"
#import "SLDatabaseManager.h"

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
            url = @"users/";
            break;
        case SLRestManagerPathKeyChallengeKey:
            url = @"users/";
            break;
        case SLRestManagerPathKeyKeys:
            url = @"users/";
            break;
        case SLRestManagerPathKeyUsers:
            url = @"users/";
            break;
        case SLRestManagerPathKeyFirmwareUpdate:
            url = @"updates/";
            break;
        default:
            break;
    }
    
    return url;
}

- (NSURL *)urlWithServerKey:(SLRestManagerServerKey)serverKey
                    pathKey:(SLRestManagerPathKey)pathKey
                  subRoutes:(NSArray *)subRoutes

{
    NSMutableString *url = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@%@",
                                                                    [self serverUrl:serverKey],
                                                                    [self pathUrl:pathKey]]
                            ];
    if (subRoutes) {
        for (NSString *subRoute in subRoutes) {
            NSString *path = subRoute;
            if (path.length > 0) {
                NSString *firstChar = [path substringWithRange:NSMakeRange(0, 1)];
                if ([firstChar isEqualToString:@"/"]) {
                    path = [path substringFromIndex:1];
                }
                
                if (path.length > 0) {
                    NSString *lastChar = [path substringFromIndex:path.length - 1];
                    if (![lastChar isEqualToString:@"/"]) {
                        path = [path stringByAppendingString:@"/"];
                    }
                }
            }
            
            [url appendString:path];
        }
    }
    
    
    return [NSURL URLWithString:url];
}

- (void)getRequestWithServerKey:(SLRestManagerServerKey)serverKey
                        pathKey:(SLRestManagerPathKey)pathKey
                      subRoutes:(NSArray *)subRoutes
              additionalHeaders:(NSDictionary *)additionalHeaders
                     completion:(void (^)(NSDictionary *responseDict))completion
{
    NSURL *url = [self urlWithServerKey:serverKey pathKey:pathKey subRoutes:subRoutes];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    if (additionalHeaders) {
        for (NSString *key in additionalHeaders.allKeys) {
            [request setValue:additionalHeaders[key] forHTTPHeaderField:key];
        }
    }
    
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
         subRoutes:(NSArray *)subRoutes
 additionalHeaders:(NSDictionary *)additionalHeaders
        completion:(void (^)(NSDictionary *responseDict))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURL *url = [self urlWithServerKey:serverKey pathKey:pathKey subRoutes:subRoutes];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@(jsonData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    if (additionalHeaders) {
        for (NSString *key in additionalHeaders.allKeys) {
            [request setValue:additionalHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    NSLog(@"post object: %@", object.description);
    NSLog(@"post url: %@", request.URL.absoluteString);
    NSLog(@"post request %@", [request allHTTPHeaderFields]);
    
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

- (void)getGoogleDirectionsFromUrl:(NSString *)urlString completion:(void (^)(NSData *))completion
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:kSLRestManagerTimeout];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                if (error) {
                                                    NSLog(@"error getting directions from url: %@, failed with error: %@",
                                                          urlString,
                                                          error.localizedDescription);
                                                    completion(nil);
                                                    return;
                                                }
                                                
                                                completion(data);
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
        [SLDatabaseManager.sharedManager saveLogEntry:[NSString stringWithFormat:
         @"Error could not fetch request from: %@. Failed with error: %@. Complete reponse: %@",
          originalUrl.absoluteString,
          error,
          response]];
        completion(nil);
        return;
    }
    
    NSDictionary *serverReply = [NSJSONSerialization JSONObjectWithData:data
                                                                options:0
                                                                  error:&error];
    
    if (error) {
        NSLog(@"Error could not decode json object for fetch request: %@. Failed with error: %@",
              originalUrl.absoluteString,
              error
              );
        completion(nil);
        return;
    }
    
    NSLog(@"server reply: %@", serverReply.description);
    id status = serverReply[@"status"];
    
    if ([status isKindOfClass:[NSString class]]) {
        if (![status isEqualToString:@"success"]) {
            NSLog(@"Error in response from server: %@", serverReply[@"message"]);
            completion(nil);
            return;
        }
        
        id payload = serverReply[@"payload"];
        if ([payload isKindOfClass:[NSDictionary class]]) {
            completion(payload);
        } else if ([payload isKindOfClass:[NSArray class]]) {
            completion(@{@"payload": payload});
        } else {
            completion(nil);
        }
    } else {
        NSLog(@"failed with error: %@", status);
        completion(nil);
    }
    
}

- (NSString *)basicAuthorizationHeaderValueUsername:(NSString *)username password:(NSString *)password
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth64String = [authData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    return [NSString stringWithFormat:@"Basic %@", auth64String];
}

@end
