//
//  SLSlideControllerOptionsView.m
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSlideControllerOptionsView.h"
#import "UIColor+RGB.h"
#import "NSString+Skylock.h"
#import "SLSlideControllerOptionsButton.h"

#define kSLSlideControllerOptionsLabelFont      [UIFont fontWithName:@"HelveticaNeue" size:8.0f]
#define kSLSlideControllerOptionsLabelColor     [UIColor colorWithRed:146 green:148 blue:151]
#define kSLSlideControllerOptionsDividerColor   [UIColor colorWithRed:191 green:191 blue:191]

@interface SLSlideControllerOptionsView()


@property (nonatomic, strong) SLSlideControllerOptionsButton *addLockButton;
@property (nonatomic, strong) SLSlideControllerOptionsButton *storeButton;
@property (nonatomic, strong) SLSlideControllerOptionsButton *settingsButton;
@property (nonatomic, strong) SLSlideControllerOptionsButton *helpButton;

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIView *horizontalLineView;

@end

@implementation SLSlideControllerOptionsView

- (SLSlideControllerOptionsButton *)addLockButton
{
    if (!_addLockButton) {
        NSString *title = NSLocalizedString(@"Add Lock", nil);
        NSString *imageName = @"icon_lock";
        
        _addLockButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:self.buttonFrame
                                                                         title:title
                                                                     imageName:imageName
                                                                          font:kSLSlideControllerOptionsLabelFont
                                                                    titleColor:kSLSlideControllerOptionsLabelColor];
        [_addLockButton addTarget:self
                           action:@selector(addLockPressed)
                 forControlEvents:UIControlEventTouchDown];
        [self addSubview:_addLockButton];
    }
    
    return _addLockButton;
}

- (SLSlideControllerOptionsButton *)storeButton
{
    if (!_storeButton) {
        NSString *title = NSLocalizedString(@"Store", nil);
        NSString *imageName = @"icon_store";
        
        _storeButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:self.buttonFrame
                                                                       title:title
                                                                   imageName:imageName
                                                                        font:kSLSlideControllerOptionsLabelFont
                                                                  titleColor:kSLSlideControllerOptionsLabelColor];
        [_storeButton addTarget:self
                         action:@selector(storePressed)
               forControlEvents:UIControlEventTouchDown];
        [self addSubview:_storeButton];
    }
    
    return _storeButton;
}

- (SLSlideControllerOptionsButton *)settingsButton
{
    if (!_settingsButton) {
        NSString *title = NSLocalizedString(@"Settings", nil);
        NSString *imageName = @"icon_settings_small";
        
        _settingsButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:self.buttonFrame
                                                                          title:title
                                                                      imageName:imageName
                                                                           font:kSLSlideControllerOptionsLabelFont
                                                                     titleColor:kSLSlideControllerOptionsLabelColor];
        [_settingsButton addTarget:self
                            action:@selector(settingsPressed)
                  forControlEvents:UIControlEventTouchDown];
        [self addSubview:_settingsButton];
    }
    
    return _settingsButton;
}

- (SLSlideControllerOptionsButton *)helpButton
{
    if (!_helpButton) {
        NSString *title = NSLocalizedString(@"Help", nil);
        NSString *imageName = @"icon_help";
        
        _helpButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:self.buttonFrame
                                                                      title:title
                                                                  imageName:imageName
                                                                       font:kSLSlideControllerOptionsLabelFont
                                                                 titleColor:kSLSlideControllerOptionsLabelColor];
        [_helpButton addTarget:self
                        action:@selector(helpPressed)
              forControlEvents:UIControlEventTouchDown];
        [self addSubview:_helpButton];
    }
    
    return _helpButton;
}

- (UIView *)verticalLineView
{
    if (!_verticalLineView) {
        _verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 1.0f, self.bounds.size.height)];
        _verticalLineView.backgroundColor = kSLSlideControllerOptionsDividerColor;
        [self addSubview:_verticalLineView];
    }
    
    return _verticalLineView;
}

- (UIView *)horizontalLineView
{
    if (!_horizontalLineView) {
        _horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, 1.0f)];
        _horizontalLineView.backgroundColor = kSLSlideControllerOptionsDividerColor;
        [self addSubview:_horizontalLineView];
    }
    
    return _horizontalLineView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.horizontalLineView.frame = CGRectMake(0.0f,
                                               .5*(self.bounds.size.height - self.horizontalLineView.bounds.size.height),
                                               self.horizontalLineView.bounds.size.width,
                                               self.horizontalLineView.bounds.size.height);
    
    self.verticalLineView.frame = CGRectMake(.5*(self.bounds.size.width - self.verticalLineView.bounds.size.width),
                                               0.0f,
                                               self.verticalLineView.bounds.size.width,
                                               self.verticalLineView.bounds.size.height);

    self.addLockButton.frame = CGRectMake(0.0f,
                                          0.0f,
                                          self.addLockButton.bounds.size.width,
                                          self.addLockButton.bounds.size.height);
    
    self.storeButton.frame = CGRectMake(CGRectGetMaxX(self.verticalLineView.frame),
                                        0.0f,
                                        self.storeButton.bounds.size.width,
                                        self.storeButton.bounds.size.height);
    
    self.settingsButton.frame = CGRectMake(0.0f,
                                           CGRectGetMaxY(self.horizontalLineView.frame),
                                           self.settingsButton.bounds.size.width,
                                           self.settingsButton.bounds.size.height);
    
    self.helpButton.frame = CGRectMake(CGRectGetMaxX(self.verticalLineView.frame),
                                       CGRectGetMaxY(self.horizontalLineView.frame),
                                       self.helpButton.bounds.size.width,
                                       self.helpButton.bounds.size.height);
}

- (CGRect)buttonFrame
{
    return CGRectMake(0.0f, 0.0f, 63.0, 61.0);
}

- (void)addLockPressed
{
    
}

- (void)storePressed
{
    
}

- (void)settingsPressed
{
    
}

- (void)helpPressed
{
    
}
@end
