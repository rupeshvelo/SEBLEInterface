//
//  SLLockInfoBottomView.h
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewBase.h"

@class SLLockInfoBottomView;


@protocol SLLockInfoBottomViewDelegate <NSObject>

- (void)bottomViewButtonPressed:(SLLockInfoBottomView *)bottomView withLockState:(BOOL)isLocked;

@end


@interface SLLockInfoBottomView : SLLockInfoViewBase

@property (nonatomic, weak) id <SLLockInfoBottomViewDelegate> delegate;

@end
