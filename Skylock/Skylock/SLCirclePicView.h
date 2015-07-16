//
//  SLCirclePicView.h
//  Skylock
//
//  Created by Andre Green on 7/15/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLCirclePicView : UIView

@property (nonatomic, assign) CGFloat picRadius;

- (id)initWithFrame:(CGRect)frame name:(NSString *)name picRadius:(CGFloat)picRadius;

- (void)setPicImage:(UIImage *)image;

@end
