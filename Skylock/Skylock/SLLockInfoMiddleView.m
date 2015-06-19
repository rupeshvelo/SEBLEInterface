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

@interface SLLockInfoMiddleView()

@property (nonatomic, strong) SLLock *lock;

@property (nonatomic, strong) UIButton *crashButton;
@property (nonatomic, strong) UIButton *securityButton;
@property (nonatomic, strong) UIButton *sharingButton;

@property (nonatomic, strong) UILabel *crashLabel;
@property (nonatomic, strong) UILabel *securityLabel;
@property (nonatomic, strong) UILabel *sharingLabel;

@property (nonatomic, strong) UIImageView *securityArrowView;
@property (nonatomic, strong) UIImageView *sharingArrowView;

@end

@implementation SLLockInfoMiddleView

- (id)initWithFrame:(CGRect)frame andLock:(SLLock *)lock
{
    self = [super initWithFrame:frame];
    if (self) {
        _lock = lock;
    }
    
    return self;
}

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
        
        [self addSubview:_sharingButton];
    }
    
    return _sharingButton;
}

- (UILabel *)crashLabel
{
    if (!_crashLabel) {
        NSString *text = NSLocalizedString(@"Crash Alert", nil);
        _crashLabel = [[UILabel alloc] initWithFrame:[self labelFrameForText:text
                                                                     andFont:SLConstantsDefaultFont
                                                                  withOption:nil]];
        _crashLabel.text = text;
        _crashLabel.backgroundColor = [UIColor yellowColor];
        
        [self addSubview:_crashLabel];
    }
    
    return _crashLabel;
}

- (UILabel *)securityLabel
{
    if (!_securityLabel) {
        NSString *text = NSLocalizedString(@"Security", nil);
        _securityLabel = [[UILabel alloc] initWithFrame:[self labelFrameForText:text
                                                                        andFont:SLConstantsDefaultFont
                                                                     withOption:nil]];
        _securityLabel.text = text;
        _securityLabel.backgroundColor = [UIColor yellowColor];
        
        [self addSubview:_securityLabel];
    }
    
    return _securityLabel;
}

- (UILabel *)sharingLabel
{
    if (!_sharingLabel) {
        NSString *text = NSLocalizedString(@"Sharing", nil);
        _sharingLabel = [[UILabel alloc] initWithFrame:[self labelFrameForText:text
                                                                       andFont:SLConstantsDefaultFont
                                                                    withOption:nil]];
        _sharingLabel.text = text;
        _sharingLabel.backgroundColor = [UIColor yellowColor];
        
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
    
}

- (CGRect)initialButtonFrame
{
    UIImage *buttonImage = [UIImage imageNamed:@"crash-alert-active"];
    return CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
}

- (void)crashButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(middleViewCrashButtonPressed:)]) {
        [self.delegate middleViewCrashButtonPressed:self];
    }
}

- (void)securityButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(middleViewSecurityButtonPressed:)]) {
        [self.delegate middleViewSecurityButtonPressed:self];
    }
}


- (void)sharingButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(middleViewSharingButtonPressed:)]) {
        [self.delegate middleViewSharingButtonPressed:self];
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
