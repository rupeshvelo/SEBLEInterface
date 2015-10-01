//
//  SLAnnotationDirectionCalloutView.m
//  Skylock
//
//  Created by Andre Green on 9/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAnnotationDirectionCalloutView.h"

@interface SLAnnotationDirectionCalloutView()

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation SLAnnotationDirectionCalloutView

- (id)initWithFrame:(CGRect)frame
{
    UIImage *image = [UIImage imageNamed:@"icon_mylock_off"];
    self = [super initWithFrame:CGRectMake(0.0f,
                                           0.0f,
                                           2*image.size.width,
                                           image.size.height)];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (UIButton *)leftButton
{
    if (!_leftButton) {
        UIImage *image = [UIImage imageNamed:@"icon_mylock_off"];
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_leftButton addTarget:self
                        action:@selector(leftButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_leftButton setImage:image forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"icon_mylock_on"]
                     forState:UIControlStateSelected];
        [self addSubview:_leftButton];
    }
    
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton) {
        UIImage *image = [UIImage imageNamed:@"icon_navigate_off"];
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        [_rightButton addTarget:self
                         action:@selector(rightButtonPressed)
               forControlEvents:UIControlEventTouchDown];
        [_rightButton setImage:image forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"icon_navigate_on"]
                      forState:UIControlStateSelected];
        [self addSubview:_rightButton];
    }
    
    return _rightButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.rightButton.frame = CGRectMake(self.leftButton.bounds.size.width,
                                        0.0f,
                                        self.rightButton.bounds.size.width,
                                        self.rightButton.bounds.size.height);
}

- (void)leftButtonPressed
{
    self.leftButton.selected = !self.leftButton.isSelected;
    if ([self.delegate respondsToSelector:@selector(annotationDirection:leftButtonIsSelected:)]) {
        [self.delegate annotationDirection:self leftButtonIsSelected:self.leftButton.isSelected];
    }
}

- (void)rightButtonPressed
{
    self.rightButton.selected = !self.rightButton.isSelected;
    if ([self.delegate respondsToSelector:@selector(annotationDirection:rightButtonIsSelected:)]) {
        [self.delegate annotationDirection:self rightButtonIsSelected:self.rightButton.isSelected];
    }
}

@end
