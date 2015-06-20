//
//  SLLockInfoViewBase.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewBase.h"
#import "SLLock.h"

@implementation SLLockInfoViewBase

- (id)initWithFrame:(CGRect)frame
            andLock:(SLLock *)lock
     xPaddingScaler:(CGFloat)xPaddingScaler
     yPaddingScaler:(CGFloat)yPaddingScaler
{
    self = [super initWithFrame:frame];
    if (self) {
        _lock           = lock;
        _xPaddingScaler = xPaddingScaler;
        _yPaddingScaler = yPaddingScaler;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end