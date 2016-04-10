//
//  SLAccountInfoFieldView.m
//  Skylock
//
//  Created by Andre Green on 7/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAccountInfoFieldView.h"
#import "UIColor+RGB.h"

#define kSLAccountInfoFieldViewLabelFont   [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define kSLAccountInfoFieldViewButtonFont  [UIFont fontWithName:@"HelveticaNeue" size:13.0f]

@interface SLAccountInfoFieldView()

@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) NSString *headerString;
@property (nonatomic, strong) NSString *infoString;
@property (nonatomic, strong) NSString *buttonString;
@property (nonatomic, assign) BOOL showSecure;

@end

@implementation SLAccountInfoFieldView

- (id)initWithFrame:(CGRect)frame
       headerString:(NSString *)headerString
         infoString:(NSString *)infoString
       buttonString:(NSString *)buttonString
         showSecure:(BOOL)showSecure
{
    self = [super initWithFrame:frame];
    if (self) {
        _headerString = headerString;
        _infoString = infoString;
        _buttonString = buttonString;
        _showSecure = showSecure;
    }
    
    return self;
}

- (UILabel *)headerLabel
{
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 .5*self.bounds.size.width,
                                                                 16.0f)];
        _headerLabel.text = self.headerString;
        _headerLabel.font = kSLAccountInfoFieldViewLabelFont;
        _headerLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
        [self addSubview:_headerLabel];
    }
    
    return _headerLabel;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                           0.0f,
                                                           .5*self.bounds.size.width,
                                                           16.0f)];
        _label.text = self.infoString;
        _label.font = kSLAccountInfoFieldViewLabelFont;
        _label.textColor = [UIColor colorWithRed:191 green:191 blue:191];
        [self addSubview:_label];
    }
    
    return _label;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             .5*self.bounds.size.width,
                                                             self.bounds.size.height)];
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_button addTarget:self
                    action:@selector(buttonPushed)
          forControlEvents:UIControlEventTouchDown];
        [_button setTitle:self.buttonString forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor colorWithRed:52 green:152 blue:219]
                      forState:UIControlStateNormal];
        _button.titleLabel.font = kSLAccountInfoFieldViewButtonFont;
        [self addSubview:_button];
    }
    
    return _button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.headerLabel.frame = CGRectMake(0.0f,
                                        0.0f,
                                        self.headerLabel.bounds.size.width,
                                        self.headerLabel.bounds.size.height);
    
    self.label.frame = CGRectMake(0.0f,
                                  self.bounds.size.height - self.label.bounds.size.height,
                                  self.label.bounds.size.width,
                                  self.label.bounds.size.height);
    
    self.button.frame = CGRectMake(self.bounds.size.width - self.button.bounds.size.width,
                                   0.0f,
                                   self.button.bounds.size.width,
                                   self.button.bounds.size.height);
}

- (void)buttonPushed
{
    if (self.buttonPressedBlock) {
        self.buttonPressedBlock();
    }
}

- (void)setButtonEnabled:(BOOL)shouldSetEnabled
{
    self.button.enabled = shouldSetEnabled;
}

- (void)changeLabelText:(NSString *)text
{
    self.label.text = text;
}

@end
