//
//  SLCoachMarkViewController.m
//  Skylock
//
//  Created by Andre Green on 7/12/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLCoachMarkViewController.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"

typedef NS_ENUM(NSUInteger, SLCoachMarkParam) {
    SLCoachMarkParamPaginationImage,
    SLCoachMarkParamButtonImage,
    SLCoachMarkParamTitleLabelText,
    SLCoachMarkParamInfoLabelText,
    SLCoachMarkParamButtonLabelText
};

#define kSLCoachMarkLabelFont       [UIFont fontWithName:@"ShadowsIntoLightTwo-Regular" size:15.0f]
#define kSLCoachMarkLabelXPadding   55.0f
#define kSLCoachMarkLabelTextColor  [UIColor colorWithRed:255 green:255 blue:255]

@interface SLCoachMarkViewController()

@property (nonatomic, strong) UIImageView *paginationView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIImageView *handView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, strong) NSDictionary *paramsForPage;
@property (nonatomic, assign) SLCoachMarkPage currentPage;

@end

@implementation SLCoachMarkViewController

- (UIImageView *)paginationView
{
    if (!_paginationView) {
        UIImage *image = self.paramsForPage[@(SLCoachMarkParamPaginationImage)];
        _paginationView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        image.size.width,
                                                                        image.size.height)];
        _paginationView.image = image;
        [self.view addSubview:_paginationView];
    }
    
    return _paginationView;
}

- (UIButton *)button
{
    if (!_button) {
        UIImage *image = self.paramsForPage[@(SLCoachMarkParamButtonImage)];
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             image.size.width,
                                                             image.size.height)];
        [_button addTarget:self
                    action:@selector(buttonPressed)
          forControlEvents:UIControlEventTouchDown];
        [_button setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_button];
    }

    return _button;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        NSString *text = self.paramsForPage[@(SLCoachMarkParamTitleLabelText)];
        CGSize textSize = [self sizeForText:text];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                textSize.width,
                                                                textSize.height)];
        _titleLabel.text = text;
        _titleLabel.textColor = kSLCoachMarkLabelTextColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = kSLCoachMarkLabelFont;
        [self.view addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel *)infoLabel
{
    if (!_infoLabel) {
        NSString *text = self.paramsForPage[@(SLCoachMarkParamInfoLabelText)];
        CGSize textSize = [self sizeForText:text];
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                textSize.width,
                                                                textSize.height)];
        _infoLabel.text = text;
        _infoLabel.textColor = kSLCoachMarkLabelTextColor;
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = kSLCoachMarkLabelFont;
        _infoLabel.numberOfLines = 0;
        [self.view addSubview:_infoLabel];
    }
    
    return _infoLabel;
}

- (UILabel *)buttonLabel
{
    if (!_buttonLabel) {
        NSString *text = self.paramsForPage[@(SLCoachMarkParamButtonLabelText)];
        CGSize textSize = [self sizeForText:text];
        _buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 textSize.width,
                                                                 textSize.height)];
        _buttonLabel.text = text;
        _buttonLabel.textColor = kSLCoachMarkLabelTextColor;
        _buttonLabel.textAlignment = NSTextAlignmentCenter;
        _buttonLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:10.0f];
        [self.view addSubview:_buttonLabel];
    }
    
    return _buttonLabel;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        UIImage *image = [UIImage imageNamed:@"btn_done"];
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_doneButton addTarget:self
                        action:@selector(doneButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_doneButton setImage:image forState:UIControlStateNormal];
        _doneButton.hidden = YES;
        [self.view addSubview:_doneButton];
    }
    
    return _doneButton;
}

- (UIImageView *)handView
{
    if (!_handView) {
        UIImage *image = [UIImage imageNamed:@"icon_hand"];
        _handView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        _handView.image = image;
        [self.view addSubview:_handView];
    }
    
    return _handView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor colorWithRed:0 green:0 blue:0] colorWithAlphaComponent:.75f];
    self.currentPage = SLCoachMarkPageCrash;

    [self updateParameters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.paginationView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.paginationView.bounds.size.width),
                                           25.0f,
                                           self.paginationView.bounds.size.width,
                                           self.paginationView.bounds.size.height);
    
    self.titleLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.titleLabel.bounds.size.width),
                                       117.0f,
                                       self.titleLabel.bounds.size.width,
                                       self.titleLabel.bounds.size.height);
    
    self.infoLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.infoLabel.bounds.size.width),
                                      157.0f,
                                      self.infoLabel.bounds.size.width,
                                      self.infoLabel.bounds.size.height);
    
    self.doneButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.doneButton.bounds.size.width),
                                       271.0f,
                                       self.doneButton.bounds.size.width,
                                       self.doneButton.bounds.size.height);
    
    [self setLowerViewFrames];
}

- (void)updateParameters
{
    NSString *paginationImageName;
    NSString *buttonImageName;
    NSString *titleLabelText;
    NSString *infoLabelText;
    NSString *buttonLabelText;
    
    switch (self.currentPage) {
        case SLCoachMarkPageCrash:
            paginationImageName = @"pagination_white1";
            buttonImageName = @"btn_crashalert_on";
            titleLabelText = NSLocalizedString(@"CRASH ALERT", nil);
            infoLabelText = NSLocalizedString(@"Skylock can detect serious crashes, and the Skylock app can notify anyone in your trusted network.", nil);
            buttonLabelText = NSLocalizedString(@"Crash Alert", nil);
            break;
        case SLCoachMarkPageTheft:
            paginationImageName = @"pagination_white2";
            buttonImageName = @"btn_theftalert_on";
            titleLabelText = NSLocalizedString(@"THEFT ALERT", nil);
            infoLabelText = NSLocalizedString(@"Skylock uses its accelerometer to notify you that your bike is being tampered with.", nil);
            buttonLabelText = NSLocalizedString(@"Theft Alert", nil);
            break;
        case SLCoachMarkPageSharing:
            paginationImageName = @"pagination_white3";
            buttonImageName = @"btn_sharing_on";
            titleLabelText = NSLocalizedString(@"SHARE ACCESS", nil);
            infoLabelText = NSLocalizedString(@"Share access to your bike with anyone in your trusted network. Create and set up your own bike share system.", nil);
            buttonLabelText = NSLocalizedString(@"Sharing", nil);
            break;
        default:
            break;
    }
    
    UIImage *paginationImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", paginationImageName]];
    UIImage *buttonImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@", buttonImageName]];
    
    self.paramsForPage = @{@(SLCoachMarkParamPaginationImage):paginationImage,
                           @(SLCoachMarkParamButtonImage):buttonImage,
                           @(SLCoachMarkParamTitleLabelText):titleLabelText,
                           @(SLCoachMarkParamInfoLabelText):infoLabelText,
                           @(SLCoachMarkParamButtonLabelText):buttonLabelText
                           };
}

- (CGSize)sizeForText:(NSString *)text
{
    CGSize maxSize = CGSizeMake(self.view.bounds.size.width - 2*kSLCoachMarkLabelXPadding,
                                CGFLOAT_MAX);
    return [text sizeWithFont:kSLCoachMarkLabelFont maxSize:maxSize];
}

- (void)buttonPressed
{
    BOOL shouldUpdate = YES;
    if (self.currentPage == SLCoachMarkPageCrash) {
        self.currentPage = SLCoachMarkPageTheft;
    } else if (self.currentPage == SLCoachMarkPageTheft) {
        self.currentPage = SLCoachMarkPageSharing;
        self.doneButton.hidden = NO;
    } else {
        shouldUpdate = NO;
    }
    
    if (shouldUpdate) {
        [self updateParameters];
        
        self.paginationView.image = self.paramsForPage[@(SLCoachMarkParamPaginationImage)];
        self.titleLabel.text = self.paramsForPage[@(SLCoachMarkParamTitleLabelText)];
        self.infoLabel.text = self.paramsForPage[@(SLCoachMarkParamInfoLabelText)];
        [self.button setImage:self.paramsForPage[@(SLCoachMarkParamButtonImage)]
                     forState:UIControlStateNormal];
        self.buttonLabel.text = self.paramsForPage[@(SLCoachMarkParamButtonLabelText)];
        
        [self setLowerViewFrames];
    }
}

- (void)doneButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(coachMarkViewControllerDoneButtonPressed:)]) {
        [self.delegate coachMarkViewControllerDoneButtonPressed:self];
    }
}

-(void)showCurrentButton
{
    
}

- (void)setLowerViewFrames
{
    NSValue *buttonRect = self.buttonPositions[@(self.currentPage)][@"button"];
    self.button.frame = buttonRect.CGRectValue;
    
    NSValue *buttonLabelRect = self.buttonPositions[@(self.currentPage)][@"label"];
    self.buttonLabel.frame = buttonLabelRect.CGRectValue;

    self.handView.frame = CGRectMake(self.button.center.x - .5*self.handView.bounds.size.width,
                                     CGRectGetMaxY(self.buttonLabel.frame),
                                     self.handView.bounds.size.width,
                                     self.handView.bounds.size.height);
    
}
@end
