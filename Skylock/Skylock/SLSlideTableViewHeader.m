//
//  SLSlideTableViewHeader.m
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSlideTableViewHeader.h"
#import "SLCirclePicView.h"
#import "UIColor+RGB.h"


@interface SLSlideTableViewHeader()

@property (nonatomic, strong) UILabel *addAccountLabel;
@property (nonatomic, strong) UIView *seperatorView;
@end

@implementation SLSlideTableViewHeader
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tgr = [UITapGestureRecognizer new];
        [tgr addTarget:self action:@selector(addAccount)];
        tgr.numberOfTapsRequired = 1;
        
        [self addGestureRecognizer:tgr];
    }
    
    return self;
}

- (UIView *)seperatorView
{
    if (!_seperatorView) {
        static CGFloat seperatorHeight = 1.0f;
        _seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  self.bounds.size.width,
                                                                  seperatorHeight)];
        _seperatorView.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
        [self addSubview:_seperatorView];
    }
    
    return _seperatorView;
}

- (UILabel *)addAccountLabel
{
    if (!_addAccountLabel) {
        _addAccountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     self.bounds.size.width,
                                                                     9.0f)];
        _addAccountLabel.text = NSLocalizedString(@"View Account", nil);
        _addAccountLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0f];
        _addAccountLabel.textColor = [UIColor colorWithRed:52 green:152 blue:219];
        _addAccountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_addAccountLabel];
    }
    
    return _addAccountLabel;
}

- (SLCirclePicView *)circleView
{
    if (!_circleView) {
        CGFloat height = self.bounds.size.height - self.seperatorView.bounds.size.height - self.addAccountLabel.bounds.size.height;
        _circleView = [[SLCirclePicView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.bounds.size.width,
                                                                        height)
                                                        name:self.name
                                                   picRadius:22.5f];
        [self addSubview:_circleView];
    }
    
    return _circleView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.circleView.frame = CGRectMake(0.0f,
                                       0.0f,
                                       self.circleView.bounds.size.width,
                                       self.circleView.bounds.size.height);
    
    self.addAccountLabel.frame = CGRectMake(0.0f,
                                            self.bounds.size.height - self.addAccountLabel.bounds.size.height - 10.0f,
                                            self.addAccountLabel.bounds.size.width,
                                            self.addAccountLabel.bounds.size.height);
    
    self.seperatorView.frame = CGRectMake(0.0f,
                                          self.bounds.size.height - self.seperatorView.bounds.size.height,
                                          self.seperatorView.bounds.size.width,
                                          self.seperatorView.bounds.size.height);
}

- (void)addAccount
{
    if ([self.delegate respondsToSelector:@selector(addAccountPressedForSlideTableHeader:)]) {
        [self.delegate addAccountPressedForSlideTableHeader:self];
    }
}

@end
