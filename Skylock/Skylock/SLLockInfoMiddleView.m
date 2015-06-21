//
//  SLLockInfoMiddleView.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoMiddleView.h"
#import "SLLock.h"
#import "SLConstants.h"
#import "SLDropDownLabel.h"

@interface SLLockInfoMiddleView()

@property (nonatomic, strong) UIButton *crashButton;
@property (nonatomic, strong) UIButton *securityButton;
@property (nonatomic, strong) UIButton *sharingButton;

@property (nonatomic, strong) UILabel *crashLabel;
@property (nonatomic, strong) SLDropDownLabel *securityLabel;
@property (nonatomic, strong) SLDropDownLabel *sharingLabel;

@property (nonatomic, strong) UIImageView *securityArrowView;
@property (nonatomic, strong) UIImageView *sharingArrowView;

@end

@implementation SLLockInfoMiddleView

- (UIButton *)crashButton
{
    if (!_crashButton) {
        _crashButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_crashButton addTarget:self
                         action:@selector(crashButtonPressed:)
               forControlEvents:UIControlEventTouchDown];
        [_crashButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonCrash active:YES]
                      forState:UIControlStateSelected];
        [_crashButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonCrash active:NO]
                      forState:UIControlStateNormal];
        _crashButton.selected = self.lock.isCrashOn.boolValue;
        
        [self addSubview:_crashButton];
    }
    
    return _crashButton;
}

- (UIButton *)securityButton
{
    if (!_securityButton) {
        _securityButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_securityButton addTarget:self
                            action:@selector(securityButtonPressed:)
                  forControlEvents:UIControlEventTouchDown];
        [_securityButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonSecurity active:YES]
                         forState:UIControlStateSelected];
        [_securityButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonSecurity active:NO]
                         forState:UIControlStateNormal];
        _securityButton.selected = self.lock.isSecurityOn.boolValue;
        
        [self addSubview:_securityButton];
    }
    
    return _securityButton;
}

- (UIButton *)sharingButton
{
    if (!_sharingButton) {
        _sharingButton = [[UIButton alloc] initWithFrame:self.initialButtonFrame];
        [_sharingButton addTarget:self
                            action:@selector(sharingButtonPressed:)
                  forControlEvents:UIControlEventTouchDown];
        [_sharingButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonSharing active:YES]
                         forState:UIControlStateSelected];
        [_sharingButton setImage:[self imageForButton:SLLockInfoMiddleViewButtonSharing active:NO]
                         forState:UIControlStateNormal];
        _sharingButton.selected = self.lock.isSharingOn.boolValue;
        
        [self addSubview:_sharingButton];
    }
    
    return _sharingButton;
}

- (UILabel *)crashLabel
{
    if (!_crashLabel) {
        NSString *text = NSLocalizedString(@"Crash Alert", nil);
        _crashLabel = [[UILabel alloc] initWithFrame:self.labelRect];
        _crashLabel.text = text;
        _crashLabel.textAlignment = NSTextAlignmentCenter;
        _crashLabel.font = SLConstantsDefaultFont;
        
        [self addSubview:_crashLabel];
    }
    
    return _crashLabel;
}

- (SLDropDownLabel *)securityLabel
{
    if (!_securityLabel) {
        NSString *text = NSLocalizedString(@"Security", nil);
        _securityLabel = [[SLDropDownLabel alloc] initWithFrame:self.labelRect
                                                           text:text
                                                           font:SLConstantsDefaultFont];
        [self addSubview:_securityLabel];
    }
    
    return _securityLabel;
}

- (SLDropDownLabel *)sharingLabel
{
    if (!_sharingLabel) {
        NSString *text = NSLocalizedString(@"Sharing", nil);
        _sharingLabel = [[SLDropDownLabel alloc] initWithFrame:self.labelRect
                                                          text:text
                                                          font:SLConstantsDefaultFont];
        [self addSubview:_sharingLabel];
    }
    
    return _sharingLabel;
}

- (UIImageView *)securityArrowView
{
    if (!_securityArrowView) {
        UIImage *image = [UIImage imageNamed:@"arrow-down-more-small"];
        _securityArrowView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:_securityArrowView];
    }
    
    return _securityArrowView;
}

- (UIImageView *)sharingArrowView
{
    if (!_sharingArrowView) {
        UIImage *image = [UIImage imageNamed:@"arrow-down-more-small"];
        _sharingArrowView = [[UIImageView alloc] initWithImage:image];
        
        [self addSubview:_sharingArrowView];
    }
    
    return _sharingArrowView;
}


- (void)layoutSubviews
{
    CGFloat x0 = self.xPaddingScaler*self.bounds.size.width;
    CGFloat y0 = 0.0f;
    
    self.crashButton.frame = CGRectMake(x0,
                                        y0,
                                        self.crashButton.bounds.size.width,
                                        self.crashButton.bounds.size.height);
    
    self.securityButton.frame = CGRectMake(.5*(self.bounds.size.width - self.securityButton.bounds.size.width),
                                           y0,
                                           self.securityButton.bounds.size.width,
                                           self.securityButton.bounds.size.height);
    
    self.sharingButton.frame = CGRectMake(self.bounds.size.width - self.sharingButton.bounds.size.width - x0,
                                          y0,
                                          self.sharingButton.bounds.size.width,
                                          self.sharingButton.bounds.size.height);
    
    
    // set up buttons' labels
    CGFloat labelY0 = 2.0f + CGRectGetMaxY(self.crashButton.frame);
    
    self.crashLabel.frame = CGRectMake(self.crashButton.center.x - .5*self.crashLabel.bounds.size.width,
                                       labelY0,
                                       self.crashLabel.bounds.size.width,
                                       self.crashLabel.bounds.size.height);
    
    self.securityLabel.frame = CGRectMake(self.securityButton.center.x - .5*self.securityLabel.bounds.size.width,
                                         labelY0,
                                         self.securityLabel.bounds.size.width,
                                         self.securityLabel.bounds.size.height);
    
    self.sharingLabel.frame = CGRectMake(self.sharingButton.center.x - .5*self.sharingLabel.bounds.size.width,
                                         labelY0,
                                         self.sharingLabel.bounds.size.width,
                                         self.sharingLabel.bounds.size.height);
}

- (CGRect)initialButtonFrame
{
    UIImage *buttonImage = [UIImage imageNamed:@"crash-alert-active"];
    return CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
}

- (void)crashButtonPressed:(id)sender
{
    self.crashButton.selected = !self.crashButton.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(middleViewCrashButtonPressed:stateOn:)]) {
        [self.delegate middleViewCrashButtonPressed:self stateOn:self.crashButton.isSelected];
    }
}

- (void)securityButtonPressed:(id)sender
{
    self.securityButton.selected = !self.securityButton.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(middleViewSecurityButtonPressed:stateOn:)]) {
        [self.delegate middleViewSecurityButtonPressed:self stateOn:self.securityButton.isSelected];
    }
}


- (void)sharingButtonPressed:(id)sender
{
    self.sharingButton.selected = !self.sharingButton.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(middleViewSharingButtonPressed:stateOn:)]) {
        [self.delegate middleViewSharingButtonPressed:self stateOn:self.sharingButton.isSelected];
    }
}

- (UIImage *)imageForButton:(SLLockInfoMiddleViewButton)button active:(BOOL)active
{
    NSString *imageName;
    switch (button) {
        case SLLockInfoMiddleViewButtonCrash:
            imageName = active ? @"crash-alert-active" : @"crash-alert-inactive";
            break;
            
        case SLLockInfoMiddleViewButtonSecurity:
            imageName = active ? @"security-alert-active" : @"security-alert-inactive";
            break;
            
        case SLLockInfoMiddleViewButtonSharing:
            imageName = active ? @"sharing-active" : @"sharing-inactive";
            break;
        default:
            break;
    }

    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", imageName]];
}

- (CGRect)labelRect
{
    return CGRectMake(0.0f, 0.0f, .3*self.bounds.size.width, 25.0f);
}

- (CGRect)labelFrameForText:(NSString *)text andFont:(UIFont *)font withOption:(NSDictionary *)options
{
    CGSize maxSize = CGSizeMake(.3*self.bounds.size.width, font.lineHeight);
    CGRect frame = [text boundingRectWithSize:maxSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName: font}
                                      context:nil];
    
    return frame;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
