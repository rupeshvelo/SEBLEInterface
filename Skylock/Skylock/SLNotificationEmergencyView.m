//
//  SLNotificationEmergencyView.m
//  Skylock
//
//  Created by Andre Green on 8/25/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNotificationEmergencyView.h"

@interface SLNotificationEmergencyView()

@property (nonatomic, strong) UIButton *helpButton;
@property (nonatomic, strong) UIButton *ignoreButton;

@end

@implementation SLNotificationEmergencyView

- (UIButton *)helpButton
{
    if (!_helpButton) {
        UIImage *image = [UIImage imageNamed:@"help-btn"];
        _helpButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_helpButton setImage:image forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self addSubview:_helpButton];
    }

    return _helpButton;
}

- (UIButton *)ignoreButton
{
    if (!_ignoreButton) {
        UIImage *image = [UIImage imageNamed:@"ignore-btn"];
        _ignoreButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_ignoreButton setImage:image forState:UIControlStateNormal];
        [_ignoreButton addTarget:self action:@selector(helpButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self addSubview:_ignoreButton];
    }
    
    return _ignoreButton;
}

- (void)helpButtonPressed
{
    if (self.delegate respondsToSelector:<#(SEL)#>) {
        
    }
}

- (void)ignoreButtonPressed
{
    
}

@end
