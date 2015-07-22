//
//  SLSlideTableViewHeader.h
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLCirclePicView.h"

@class SLSlideTableViewHeader;

@protocol SLSlideTableViewHeaderDelegate <NSObject>

- (void)addAccountPressedForSlideTableHeader:(SLSlideTableViewHeader *)header;

@end

@interface SLSlideTableViewHeader : UIView <SLCirclePicViewDelegate>


@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) SLCirclePicView *circleView;
@property (nonatomic, weak) id <SLSlideTableViewHeaderDelegate> delegate;


@end
