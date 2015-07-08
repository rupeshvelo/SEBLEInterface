//
//  SLDbLock+Methods.h
//  Skylock
//
//  Created by Andre Green on 7/6/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDbLock.h"

@interface SLDbLock (Methods)

- (NSDictionary *)asDictionary;
- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary;
@end
