//
//  SLLockInfoViewHeader.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLLockInfoViewBase.h"

@class SLLock;
@class SLLockInfoViewHeader;

@protocol SLLockInfoViewHeaderDelegate <NSObject>

- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView;

- (void)lockInfoViewHeaderArrowButtonPressed:(SLLockInfoViewHeader *)headerView;

@end


@interface SLLockInfoViewHeader : SLLockInfoViewBase

@property (nonatomic, weak) id <SLLockInfoViewHeaderDelegate> delegate;


@end
