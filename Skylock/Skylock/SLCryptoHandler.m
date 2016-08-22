//
//  SLCryptoHandler.m
//  Ellipse
//
//  Created by Andre Green on 8/21/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

#import "SLCryptoHandler.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Skylock.h"

@implementation SLCryptoHandler

- (NSData *)SHA256WithData:(NSData *)data;
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (unsigned int)data.length, hash);
    
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)MD5StringFromString:(NSString *)input {
    const char *cstr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
