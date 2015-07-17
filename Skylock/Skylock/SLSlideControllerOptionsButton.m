//
//  SLSlideControllerOptionsButton.m
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSlideControllerOptionsButton.h"
#import "NSString+Skylock.h"

@implementation SLSlideControllerOptionsButton

- (id)initWithFrame:(CGRect)frame
              title:(NSString *)title
          imageName:(NSString *)imageName
               font:(UIFont *)font
         titleColor:(UIColor *)titleColor
{
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        UIImage *image = [UIImage imageNamed:imageName];
        self.frame = frame;
        
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.titleLabel.font = font;
        [self setImage:image forState:UIControlStateNormal];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.lineBreakMode = NSLineBreakByClipping;
        self.titleLabel.frame = CGRectMake(0.0f,
                                           self.titleLabel.frame.origin.y,
                                           self.bounds.size.width,
                                           self.titleLabel.bounds.size.height);
        
        self.imageEdgeInsets = UIEdgeInsetsMake(32.0f,
                                                .5*(self.bounds.size.width - image.size.width),
                                                0.0f,
                                                0.0f);
        
        self.titleEdgeInsets = UIEdgeInsetsMake(15.0f, 0, 0, 0);
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, image.size.width);
    }
    
    return self;
}

@end
