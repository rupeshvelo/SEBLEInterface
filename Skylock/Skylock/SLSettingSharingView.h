//
//  SLSettingSharingView.h
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewBase.h"
@class SLSettingSharingView;

@protocol SLSettingSharingViewDelegate <NSObject>

- (void)sharingViewTapped:(SLSettingSharingView *)sharingView;

@end

@interface SLSettingSharingView : SLLockInfoViewBase

@property (nonatomic, weak) id <SLSettingSharingViewDelegate> delegate;

@end
