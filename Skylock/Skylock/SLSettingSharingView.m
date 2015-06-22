//
//  SLSettingSharingView.m
//  Skylock
//
//  Created by Andre Green on 6/20/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSettingSharingView.h"
#import "SLConstants.h"

#define kSLSettingSharingViewSeperatorHeight    2.0f
#define kSLSettingSharingViewSeperatorColor     [UIColor grayColor]
@interface SLSettingSharingView()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UITapGestureRecognizer *tgr;
@property (nonatomic, strong) UIView *topSeperatorView;
@property (nonatomic, strong) UIView *bottomSeperatorView;

@end

@implementation SLSettingSharingView

- (UIImageView *)arrowView
{
    if (!_arrowView) {
        UIImage *arrowImage = [UIImage imageNamed:@"right-arrow-button"];
        _arrowView = [[UIImageView alloc] initWithImage:arrowImage];
        _arrowView.userInteractionEnabled = YES;
        [self addSubview:_arrowView];
    }
    
    return _arrowView;
}

- (UILabel *)label
{
    if (!_label) {
        CGFloat x0 = self.xPaddingScaler*self.bounds.size.width;
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                           0.0f,
                                                           self.bounds.size.width - self.arrowView.bounds.size.width - 2*x0,
                                                           self.bounds.size.height)];
        _label.text = NSLocalizedString(@"Sharing", nil);
        _label.font = SLConstantsDefaultFont;
        _label.userInteractionEnabled = YES;
    }
    
    return _label;
}

- (UITapGestureRecognizer *)tgr
{
    if (!_tgr) {
        _tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
        _tgr.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_tgr];
    }
    
    return _tgr;
}

- (UIView *)topSeperatorView
{
    if (!_topSeperatorView) {
        _topSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.bounds.size.width,
                                                                     kSLSettingSharingViewSeperatorHeight)];
        _topSeperatorView.backgroundColor = kSLSettingSharingViewSeperatorColor;
        [self addSubview:_topSeperatorView];
    }
    
    return _topSeperatorView;
}

- (UIView *)bottomSeperatorView
{
    if (!_bottomSeperatorView) {
        _bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.bounds.size.width,
                                                                        kSLSettingSharingViewSeperatorHeight)];
        _bottomSeperatorView.backgroundColor = kSLSettingSharingViewSeperatorColor;
        [self addSubview:_bottomSeperatorView];
    }
    
    return _bottomSeperatorView;
}

- (void)layoutSubviews
{
    self.topSeperatorView.frame = CGRectMake(0.0f,
                                             0.0f,
                                             self.topSeperatorView.bounds.size.width,
                                             self.topSeperatorView.bounds.size.height);
    
    self.bottomSeperatorView.frame = CGRectMake(0.0f,
                                                self.bounds.size.height - self.bottomSeperatorView.bounds.size.height,
                                                self.bottomSeperatorView.bounds.size.width,
                                                self.bottomSeperatorView.bounds.size.height);
    
    CGFloat xPadding = self.xPaddingScaler*self.bounds.size.width;
    self.label.frame = CGRectMake(xPadding,
                                  self.topSeperatorView.bounds.size.height,
                                  self.label.frame.size.width,
                                  self.label.frame.size.height - 2*kSLSettingSharingViewSeperatorHeight);
    
    self.arrowView.frame = CGRectMake(self.bounds.size.width - xPadding - self.arrowView.bounds.size.width,
                                      .5*(self.bounds.size.height - self.arrowView.bounds.size.height),
                                      self.arrowView.frame.size.width,
                                      self.arrowView.frame.size.height);
    
    
}

- (void)viewTapped
{
    // TODO push sharing view controller on the navigation stack
}
@end
