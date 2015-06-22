//
//  SLBackButton.m
//  Skylock
//
//  Created by Andre Green on 6/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLBackButton.h"


#define kSLBackButtonSpacer 7.0f


@interface SLBackButton()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UILabel *label;

@end


@implementation SLBackButton

- (id)initWithTitle:(NSString *)title
{
    UIImage *heightImage = [UIImage imageNamed:@"left-back-arrow-button"];
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             heightImage.size.width + kSLBackButtonSpacer + 60.0f,
                             heightImage.size.height);
    self = [super initWithFrame:rect];
    if (self) {
        _title = title;
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchDown];
    }
    
    return self;
}

- (UILabel *)label
{
    if (!_label) {
        UIImage *arrow = self.arrowImage;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(arrow.size.width + kSLBackButtonSpacer,
                                                           0.0f,
                                                           self.bounds.size.width - arrow.size.width - kSLBackButtonSpacer,
                                                           self.bounds.size.height)];
        _label.textColor = [UIColor whiteColor];
        _label.text = self.title;
    }
    
    return _label;
}

- (UIImage *)arrowImage
{
    return [UIImage imageNamed:@"left-back-arrow-button"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self setImage:self.arrowImage forState:UIControlStateNormal];
    [self setTitle:self.title forState:UIControlStateNormal];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -20.0f, 0.0f, 0.0f)];
}

- (void)buttonPressed
{
    if ([self.delegate respondsToSelector:@selector(backButtonPressed:)]) {
        [self.delegate backButtonPressed:self];
    }
}
@end
