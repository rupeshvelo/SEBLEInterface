//
//  SLLockInfoViewBase.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLLock;

@interface SLLockInfoViewBase : UIView

@property (nonatomic, strong) SLLock *lock;

- (id)initWithFrame:(CGRect)frame
            andLock:(SLLock *)lock;

@end
