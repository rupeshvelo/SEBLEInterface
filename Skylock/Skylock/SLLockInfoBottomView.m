//
//  SLLockInfoBottomView.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoBottomView.h"
#import "SLConstants.h"

@interface SLLockInfoBottomView()

@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UILabel *lockMessageLabel;

@end

@implementation SLLockInfoBottomView

- (UIButton *)lockButton
{
    if (!_lockButton) {
        UIImage *normalImage = [UIImage imageNamed:@"lock_btn2"];
        UIImage *selectedImage = [UIImage imageNamed:@"unlock_btn2"];
        _lockButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 normalImage.size.width,
                                                                 normalImage.size.height)];
        [_lockButton addTarget:self
                        action:@selector(lockButtonPressed)
              forControlEvents:UIControlEventTouchDown];
 
        [_lockButton setImage:normalImage forState:UIControlStateNormal];
        [_lockButton setImage:selectedImage forState:UIControlStateSelected];
        _lockButton.backgroundColor = SLConstantsLightTeal;
        _lockButton.selected = NO;
        [self addSubview:_lockButton];
    }
    
    return _lockButton;
}

- (UILabel *)lockMessageLabel
{
    if (!_lockMessageLabel) {
        _lockMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      .9*self.bounds.size.width,
                                                                      15.0f)];
        _lockMessageLabel.text = NSLocalizedString(@"Get closer to lock", nil);
        _lockMessageLabel.textAlignment = NSTextAlignmentCenter;
        _lockMessageLabel.font = SLConstantsDefaultFont;
        [self addSubview:_lockMessageLabel];
    }
    
    return _lockMessageLabel;
}

- (void)layoutSubviews
{
    self.lockMessageLabel.frame = CGRectMake(.5*(self.bounds.size.width - self.lockMessageLabel.bounds.size.width),
                                             0.0f,
                                             self.lockMessageLabel.bounds.size.width,
                                             self.lockMessageLabel.bounds.size.height);
    
    self.lockButton.frame = CGRectMake(.5*(self.bounds.size.width - self.lockButton.bounds.size.width),
                                       3.0f + CGRectGetMaxY(self.lockMessageLabel.frame),
                                       self.lockButton.bounds.size.width,
                                       self.lockButton.bounds.size.height);
}

- (void)lockButtonPressed
{
    // this needs a check to see if the button is selected/enabled.
    // the result should depend on if the user is within the radius needed
    // to unlock the lock, and it will depend on if the user has access
    // to unlock the lock. This should not be handled by the view but by an
    // object higher up in the logic chain.
    
    // just putting this here for now for testing.
    self.lockButton.selected = !self.lockButton.isSelected;
    self.lockButton.backgroundColor = self.lockButton.selected ? SLConstantsMainTeal:SLConstantsLightTeal;
    self.lockMessageLabel.hidden = self.lockButton.isSelected;

    if ([self.delegate respondsToSelector:@selector(bottomViewButtonPressed:withLockState:)]) {
        [self.delegate bottomViewButtonPressed:self withLockState:self.lockButton.isSelected];
    }
}

@end
