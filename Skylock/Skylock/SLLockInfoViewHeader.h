//
//  SLLockInfoViewHeader.h
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLLock;
@class SLLockInfoViewHeader;

@protocol SLLockInfoViewHeaderDelegate <NSObject>

- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView;

@end


@interface SLLockInfoViewHeader : UIView

@property (nonatomic, weak) id <SLLockInfoViewHeaderDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andLock:(SLLock *)lock;
- (void)setBatteryImage;
- (void)setCellSignalImage;

@end
