//
//  SLLoginViewController.m
//  Skylock
//
//  Created by Andre Green on 7/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLoginViewController.h"
#import "SLConstants.h"
#import "SLUnderlineTextField.h"
#import "UIColor+RGB.h"
#import "SLFacebookManger.h"
#import "SLNotifications.h"
#import "SLUserDefaults.h"
#import "SLMapViewController.h"
#import "NSString+Skylock.h"
#import "Skylock-Swift.h"
#import "SLRestManager.h"


#define kSLLoginVCFontName      @"HelveticaNeue"
#define kSLLoginVCFont          [UIFont fontWithName:kSLLoginVCFontName size:17.0f]
#define kSLLoginVCDarkGrey      [UIColor colorWithRed:97 green:100 blue:100]
#define kSLLoginVCLightGrey     [UIColor colorWithRed:146 green:148 blue:151]
#define kSLLoginVCUnderlineGrey [UIColor colorWithRed:191 green:191 blue:191]
#define kSLLoginVCOrGap         15.0f
#define kSLLoginVCFieldGap      10.0f
#define kSLLoginVCFieldXInset   10.0f

typedef NS_ENUM(NSUInteger, SLLoginFieldTag) {
    SLLoginFieldTagFirstName = 100,
    SLLoginFieldTagLastName = 101,
    SLLoginFieldTagPhoneNumber = 102,
    SLLoginFieldTagPassword = 103,
    SLLoginFieldTagConfirmPassword = 104
};

typedef NS_ENUM(NSUInteger, SLLoginStage) {
    SLLoginStageBase,
    SLLoginStageExisting,
    SLLoginStageNew
};

@interface SLLoginViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredBackgroundOverlay;
@property (nonatomic, strong) UIImageView *skylockLogoView;
@property (nonatomic, assign) BOOL isGetStarted;
@property (nonatomic, strong) UILabel *letsGetStartedLabel;
@property (nonatomic, strong) UILabel *facebookLabel;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *phoneNumberButton;
@property (nonatomic, strong) UILabel *orLabel;
@property (nonatomic, strong) SLLoginTextField *phoneNumberField;
@property (nonatomic, strong) SLLoginTextField *passwordField;
@property (nonatomic, strong) SLLoginTextField *confirmPasswordField;
@property (nonatomic, strong) SLLoginTextField *firstNameField;
@property (nonatomic, strong) SLLoginTextField *lastNameField;
@property (nonatomic, strong) NSDictionary *textFields;

@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, assign) CGFloat xPadding;

@property (nonatomic, assign) SLLoginStage currentStage;
@property (nonatomic, assign) SLLoginFieldTag currentFieldTag;

@property (nonatomic, assign) CGRect originalFieldFrame;

@property (nonatomic, strong) UIView *touchStopperView;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *confirmedPassword;

@end

@implementation SLLoginViewController


- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        UIImage *image = self.backgroundImage;
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
        [self.view addSubview:_backgroundImageView];
    }
    return _backgroundImageView;
}

- (UIImageView *)skylockLogoView
{
    if (!_skylockLogoView) {
        UIImage *image = [UIImage imageNamed:@"img_logo2"];
        _skylockLogoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         image.size.width,
                                                                         image.size.height)];
        _skylockLogoView.image = image;
        [self.view addSubview:_skylockLogoView];
    }
    
    return _skylockLogoView;
}

- (UIButton *)signUpButton
{
    if (!_signUpButton) {
        UIColor *titleColor = [UIColor color:53 green:152 blue:219];
        _signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width,
                                                                   25.0f)];
        [_signUpButton addTarget:self
                          action:@selector(signUpButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [_signUpButton setTitle:self.textForSignUpButton
                       forState:UIControlStateNormal];
        [_signUpButton setTitleColor:titleColor forState:UIControlStateNormal];
        _signUpButton.titleLabel.font = [UIFont fontWithName:kSLLoginVCFontName size:12.0f];
        [self.view addSubview:_signUpButton];
    }
    
    return _signUpButton;
}

- (UILabel *)letsGetStartedLabel
{
    if (!_letsGetStartedLabel) {
        _letsGetStartedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         self.view.bounds.size.width - 20.0f,
                                                                         20.0f)];
        _letsGetStartedLabel.text = [self textForGetStartedLabel];
        _letsGetStartedLabel.font = kSLLoginVCFont;
        _letsGetStartedLabel.textColor = kSLLoginVCDarkGrey;
        _letsGetStartedLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_letsGetStartedLabel];
    }
    
    return _letsGetStartedLabel;
}

- (UILabel *)facebookLabel
{
    if (!_facebookLabel) {
        _facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width,
                                                                   self.letsGetStartedLabel.bounds.size.height)];
        _facebookLabel.text = NSLocalizedString(@"Login with your existing Facebook account.", nil);
        _facebookLabel.font = [UIFont fontWithName:kSLLoginVCFontName size:10.0f];
        _facebookLabel.textColor = kSLLoginVCLightGrey;
        _facebookLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_facebookLabel];
    }
    
    return _facebookLabel;
}

- (UIButton *)facebookButton
{
    if (!_facebookButton) {
        UIImage *image = [UIImage imageNamed:@"facebook_loggin_button"];
        _facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     image.size.width,
                                                                     image.size.height)];
        [_facebookButton addTarget:self
                            action:@selector(facebookButtonPressed)
                  forControlEvents:UIControlEventTouchDown];
        [_facebookButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_facebookButton];
    }
    
    return _facebookButton;
}

- (UIButton *)phoneNumberButton
{
    if (!_phoneNumberButton) {
        UIImage *image = [UIImage imageNamed:@"phone_login_button"];
        _phoneNumberButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        image.size.width,
                                                                        image.size.height)];
        [_phoneNumberButton addTarget:self
                               action:@selector(phoneButtonPressed)
                     forControlEvents:UIControlEventTouchDown];
        [_phoneNumberButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_phoneNumberButton];
    }
    
    return _phoneNumberButton;
}

- (UILabel *)orLabel
{
    if (!_orLabel) {
        _orLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             self.view.bounds.size.width,
                                                             20.0f)];
        _orLabel.text = NSLocalizedString(@"OR", nil);
        _orLabel.font = kSLLoginVCFont;
        _orLabel.textColor = kSLLoginVCDarkGrey;
        _orLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_orLabel];
    }
    
    return _orLabel;
}

- (NSDictionary *)textFields
{
    if (!_textFields) {
        _textFields = @{@(SLLoginFieldTagFirstName): self.firstNameField,
                        @(SLLoginFieldTagLastName): self.lastNameField,
                        @(SLLoginFieldTagPhoneNumber): self.phoneNumberField,
                        @(SLLoginFieldTagPassword): self.passwordField,
                        @(SLLoginFieldTagConfirmPassword): self.confirmPasswordField
                        };
    }
    
    return _textFields;
}

- (SLLoginTextField *)phoneNumberField
{
    if (!_phoneNumberField) {
        _phoneNumberField = [[SLLoginTextField alloc] initWithFrame:self.textFieldFrame
                                                             xInset:kSLLoginVCFieldXInset
                                                    placeHolderText:NSLocalizedString(@"Enter Phone Number", nil)];
        _phoneNumberField.delegate = self;
        _phoneNumberField.tag = SLLoginFieldTagPhoneNumber;
        _phoneNumberField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:_phoneNumberField];
    }
    
    return _phoneNumberField;
}

- (SLLoginTextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [[SLLoginTextField alloc] initWithFrame:self.textFieldFrame
                                                          xInset:kSLLoginVCFieldXInset
                                                 placeHolderText:NSLocalizedString(@"Enter Password", nil)];
        _passwordField.delegate = self;
        _passwordField.tag = SLLoginFieldTagPassword;
        _passwordField.secureTextEntry = YES;
        _passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;

        [self.view addSubview:_passwordField];
    }
    
    return _passwordField;
}

- (SLLoginTextField *)firstNameField
{
    if (!_firstNameField) {
        _firstNameField = [[SLLoginTextField alloc] initWithFrame:self.textFieldFrame
                                                           xInset:kSLLoginVCFieldXInset
                                                  placeHolderText:NSLocalizedString(@"Enter First Name", nil)];
        _firstNameField.delegate = self;
        _firstNameField.tag = SLLoginFieldTagFirstName;
        _firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
        [self.view addSubview:_firstNameField];
    }
    
    return _firstNameField;
}

- (SLLoginTextField *)lastNameField
{
    if (!_lastNameField) {
        _lastNameField = [[SLLoginTextField alloc] initWithFrame:self.textFieldFrame
                                                          xInset:kSLLoginVCFieldXInset
                                                 placeHolderText:NSLocalizedString(@"Enter Last Name", nil)];
        _lastNameField.delegate = self;
        _lastNameField.tag = SLLoginFieldTagLastName;
        _lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        
        [self.view addSubview:_lastNameField];
    }
    
    return _lastNameField;
}

- (SLLoginTextField *)confirmPasswordField
{
    if (!_confirmPasswordField) {
        _confirmPasswordField = [[SLLoginTextField alloc] initWithFrame:self.textFieldFrame
                                                                 xInset:kSLLoginVCFieldXInset
                                                        placeHolderText:NSLocalizedString(@"Confirm Password", nil)];
        _confirmPasswordField.delegate = self;
        _confirmPasswordField.tag = SLLoginFieldTagConfirmPassword;
        _confirmPasswordField.secureTextEntry = YES;
        _confirmPasswordField.returnKeyType = UIReturnKeyDone;
        _confirmPasswordField.enablesReturnKeyAutomatically = NO;
        _confirmPasswordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.view addSubview:_confirmPasswordField];
    }
    
    return _confirmPasswordField;
}

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.userInteractionEnabled = YES;
    }
    
    return _touchStopperView;
}
- (UIImage *)backgroundImage
{
    NSUInteger height =  (NSUInteger)[UIScreen mainScreen].bounds.size.height;
    NSString *name;
    switch (height) {
        case 568:
            name = @"bg_splash2";
            break;
        case 667:
            name = @"bg_splash2_6";
            break;
        case 736:
            name = @"bg_splash2_6_plus";
            break;
        default:
            break;
    }
    
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@", name]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isGetStarted = YES;
    
    self.backgroundImageView.frame = CGRectMake(0.0f,
                                                0.0f,
                                                self.backgroundImageView.bounds.size.width,
                                                self.backgroundImageView.bounds.size.height);
    
    self.xPadding = .5*(self.view.bounds.size.width - self.facebookButton.bounds.size.width);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signInSuccessful)
                                                 name:kSLNotificationUserSignedInFacebook
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self placeViewsForHomePhase];
}

- (void)placeViewsForHomePhase
{
    self.skylockLogoView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.skylockLogoView.bounds.size.width),
                                            50.0f,
                                            self.skylockLogoView.bounds.size.width,
                                            self.skylockLogoView.bounds.size.height);
    
    self.letsGetStartedLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.letsGetStartedLabel.bounds.size.width),
                                                CGRectGetMaxY(self.skylockLogoView.frame) + 30.0f,
                                                self.letsGetStartedLabel.bounds.size.width,
                                                self.letsGetStartedLabel.bounds.size.height);
    
    self.facebookButton.frame = [self facebookButtonFrame];
    
    self.orLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.orLabel.bounds.size.width),
                                    CGRectGetMaxY(self.facebookButton.frame) + kSLLoginVCOrGap,
                                    self.orLabel.bounds.size.width,
                                    self.orLabel.bounds.size.height);
    
    self.phoneNumberButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.phoneNumberButton.bounds.size.width),
                                              CGRectGetMaxY(self.orLabel.frame) + kSLLoginVCOrGap,
                                              self.phoneNumberButton.bounds.size.width,
                                              self.phoneNumberButton.bounds.size.height);
    
    self.facebookLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.facebookLabel.bounds.size.width),
                                          CGRectGetMinY(self.facebookButton.frame) - self.facebookLabel.bounds.size.height - 5.0f,
                                          self.facebookLabel.bounds.size.width,
                                          self.facebookLabel.bounds.size.height);
    
    self.signUpButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.signUpButton.bounds.size.width),
                                         self.view.bounds.size.height - self.signUpButton.bounds.size.height - 10.0f,
                                         self.signUpButton.bounds.size.width,
                                         self.signUpButton.bounds.size.height);
}

- (void)placeViewForExistingStage
{
    [UIView animateWithDuration:.4 animations:^{
        self.facebookLabel.alpha = 0.0f;
        self.firstNameField.alpha = 0.0f;
        self.lastNameField.alpha = 0.0f;
        self.confirmPasswordField.alpha = 0.0f;
        self.phoneNumberButton.alpha = 0.0f;
        self.facebookLabel.alpha = 0.0f;
        
        self.letsGetStartedLabel.text = [self textForGetStartedLabel];
        [self.signUpButton setTitle:self.textForSignUpButton forState:UIControlStateNormal];
        
        self.firstNameField.alpha = 0.0f;
        self.lastNameField.alpha = 0.0f;
        self.confirmPasswordField.alpha = 0.0f;
        
        self.passwordField.hidden = NO;
        self.phoneNumberField.hidden = NO;
        
        self.passwordField.alpha = 1.0f;
        self.phoneNumberField.alpha = 1.0f;
        
        self.facebookButton.frame = [self facebookButtonFrame];
        self.orLabel.frame = CGRectMake(self.orLabel.frame.origin.x,
                                        self.facebookButton.frame.origin.y - self.orLabel.bounds.size.height - kSLLoginVCOrGap,
                                        self.orLabel.bounds.size.width,
                                        self.orLabel.bounds.size.height);
        
        self.passwordField.frame = CGRectMake(self.passwordField.frame.origin.x,
                                              self.orLabel.frame.origin.y - self.passwordField.bounds.size.height - kSLLoginVCOrGap,
                                              self.passwordField.bounds.size.width,
                                              self.passwordField.bounds.size.height);
        
        self.phoneNumberField.frame = CGRectMake(self.phoneNumberField.frame.origin.x,
                                                 self.passwordField.frame.origin.y - self.phoneNumberField.bounds.size.height - kSLLoginVCFieldGap,
                                                 self.phoneNumberField.bounds.size.width,
                                                 self.phoneNumberField.bounds.size.height);
    } completion:^(BOOL finished) {
        self.facebookLabel.hidden = YES;
        self.firstNameField.hidden = YES;
        self.lastNameField.hidden = YES;
        self.confirmPasswordField.hidden = YES;
        self.phoneNumberButton.hidden = YES;
        self.facebookLabel.hidden = YES;
    }];
}

- (void)placeViewsForNewStage
{
    [UIView animateWithDuration:.4 animations:^{
        self.facebookLabel.alpha = 0.0f;
        self.phoneNumberButton.alpha = 0.0f;
        
        self.letsGetStartedLabel.text = [self textForGetStartedLabel];
        [self.signUpButton setTitle:self.textForSignUpButton forState:UIControlStateNormal];
        
        self.firstNameField.hidden = NO;
        self.lastNameField.hidden = NO;
        self.passwordField.hidden = NO;
        self.phoneNumberField.hidden = NO;
        self.confirmPasswordField.hidden = NO;
        
        self.firstNameField.alpha = 1.0f;
        self.lastNameField.alpha = 1.0f;
        self.passwordField.alpha = 1.0f;
        self.phoneNumberField.alpha = 1.0f;
        self.confirmPasswordField.alpha = 1.0f;
        
        
        self.facebookButton.frame = [self facebookButtonFrame];
        
        self.orLabel.frame = CGRectMake(self.orLabel.frame.origin.x,
                                        self.facebookButton.frame.origin.y - self.orLabel.bounds.size.height - kSLLoginVCOrGap,
                                        self.orLabel.bounds.size.width,
                                        self.orLabel.bounds.size.height);
        
        self.confirmPasswordField.frame = CGRectMake(self.confirmPasswordField.frame.origin.x,
                                                     self.orLabel.frame.origin.y - self.confirmPasswordField.bounds.size.height - kSLLoginVCOrGap,
                                                     self.confirmPasswordField.bounds.size.width,
                                                     self.confirmPasswordField.bounds.size.height);
        
        self.passwordField.frame = CGRectMake(self.passwordField.frame.origin.x,
                                              self.confirmPasswordField.frame.origin.y - self.passwordField.bounds.size.height - kSLLoginVCFieldGap,
                                              self.passwordField.bounds.size.width,
                                              self.passwordField.bounds.size.height);
        
        self.phoneNumberField.frame = CGRectMake(self.phoneNumberField.frame.origin.x,
                                                 self.passwordField.frame.origin.y - self.phoneNumberField.bounds.size.height - kSLLoginVCFieldGap,
                                                 self.phoneNumberField.bounds.size.width,
                                                 self.phoneNumberField.bounds.size.height);
        
        self.lastNameField.frame = CGRectMake(self.lastNameField.frame.origin.x,
                                              self.phoneNumberField.frame.origin.y - self.lastNameField.bounds.size.height - kSLLoginVCFieldGap,
                                              self.lastNameField.bounds.size.width,
                                              self.lastNameField.bounds.size.height);
        
        self.firstNameField.frame = CGRectMake(self.firstNameField.frame.origin.x,
                                               self.lastNameField.frame.origin.y - self.firstNameField.bounds.size.height - kSLLoginVCFieldGap,
                                               self.firstNameField.bounds.size.width,
                                               self.firstNameField.bounds.size.height);
    } completion:^(BOOL finished) {
        self.phoneNumberButton.hidden = YES;
        self.facebookLabel.hidden = YES;
    }];
}

- (NSString *)textForGetStartedLabel
{
    switch (self.currentStage) {
        case SLLoginStageBase:
            return NSLocalizedString(@"Let's get started!", nil);
            break;
        case SLLoginStageExisting:
            return NSLocalizedString(@"Login with your existing account", nil);
            break;
        case SLLoginStageNew:
            return NSLocalizedString(@"Create a new account", nil);
            break;
        default:
            break;
    }
}

- (NSString *)textForSignUpButton
{
    if (self.currentStage == SLLoginStageNew) {
        return NSLocalizedString(@"Already have an account? Sign In", nil);
    } else {
        return NSLocalizedString(@"Not a user already? Sign Up" , nil);
    }
}

- (CGRect)facebookButtonFrame
{
    CGFloat y;
    switch (self.currentStage) {
        case SLLoginStageBase:
            y = .5*self.view.bounds.size.height + 30.0f;
            break;
        case SLLoginStageExisting:
            y = self.phoneNumberButton.frame.origin.y;
            break;
        case SLLoginStageNew:
            y = self.signUpButton.frame.origin.y - 2*self.facebookButton.bounds.size.height;
            break;
        default:
            break;
    }
    
    return CGRectMake(.5*(self.view.bounds.size.width - self.facebookButton.bounds.size.width),
                      y,
                      self.facebookButton.bounds.size.width,
                      self.facebookButton.bounds.size.height);
}

- (CGRect)textFieldFrame
{
    return CGRectMake(self.xPadding,
                      0.0f,
                      self.view.bounds.size.width - 2*self.xPadding,
                      35.0f);
}

- (void)facebookButtonPressed
{
    NSLog(@"facebook login button pressed");
    [SLFacebookManger.sharedManager loginFromViewController:self withCompletion:^{
        NSLog(@"user loging completed!!! Yay!!");
    }];
}

- (void)phoneButtonPressed
{
    NSLog(@"phone login button pressed");

    self.currentStage = SLLoginStageExisting;
    [self placeViewForExistingStage];
}

- (void)signUpButtonPressed
{
    switch (self.currentStage) {
        case SLLoginStageBase:
            self.currentStage = SLLoginStageNew;
            [self placeViewsForNewStage];
            break;
        case SLLoginStageExisting:
            self.currentStage = SLLoginStageNew;
            [self placeViewsForNewStage];
            break;
        case SLLoginStageNew:
            self.currentStage = SLLoginStageExisting;
            [self placeViewForExistingStage];
            break;
        default:
            break;
    }
}

- (void)signInSuccessful
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(YES) forKey:SLUserDefaultsSignedIn];
    
    if ([ud objectForKey:SLUserDefaultsTutorialComplete]) {
        NSNumber *isTutorialComplete = [ud objectForKey:SLUserDefaultsTutorialComplete];
        if (isTutorialComplete.boolValue) {
            SLMapViewController *mvc = [SLMapViewController new];
            [self presentViewController:mvc animated:YES completion:nil];
        } else {
            SLWalkthroughViewController *wtvc = [SLWalkthroughViewController new];
            [self presentViewController:wtvc animated:YES completion:nil];
        }
    } else {
        [ud setObject:@(NO) forKey:SLUserDefaultsTutorialComplete];
        SLWalkthroughViewController *wtvc = [SLWalkthroughViewController new];
        [self presentViewController:wtvc animated:YES completion:nil];
    }
    
    [ud synchronize];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    NSNumber *animationDurration = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = info[UIKeyboardAnimationCurveUserInfoKey];
    SLLoginTextField *textField = self.textFields[@(self.currentFieldTag)];
    
    [UIView animateWithDuration:animationDurration.floatValue
                          delay:0.0
                        options:animationCurve.unsignedIntegerValue
                     animations:^{
                         textField.frame = CGRectMake(textField.frame.origin.x,
                                                      CGRectGetMaxY(self.letsGetStartedLabel.frame) + 10.0f,
                                                      textField.bounds.size.width,
                                                      textField.bounds.size.height);
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    
    NSNumber *animationDurration = info[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = info[UIKeyboardAnimationCurveUserInfoKey];
    SLLoginTextField *textField = self.textFields[@(self.currentFieldTag)];
    
    [UIView animateWithDuration:animationDurration.floatValue
                          delay:0.0
                        options:animationCurve.unsignedIntegerValue
                     animations:^{
                         textField.frame = self.originalFieldFrame;
                     } completion:^(BOOL finished) {
                         [self.touchStopperView removeFromSuperview];
                     }];
    
}

- (BOOL)areFieldsVerified
{
    if (self.currentStage == SLLoginStageExisting) {
        return self.phoneNumber && self.phoneNumber.length > 0 && self.password && self.password.length > 0;
    } else if (self.currentStage == SLLoginStageNew) {
        NSArray *values = @[self.firstName ? self.firstName : @"",
                            self.lastName ? self.lastName : @"",
                            self.phoneNumber ? self.phoneNumber : @"",
                            self.password ? self.password : @"",
                            self.confirmedPassword ? self.confirmedPassword : @""
                            ];
        
        NSLog(@"current field values: %@", values);
        
        __block BOOL verified = YES;
        [values enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([text isEqualToString:@""]) {
                verified = NO;
                *stop = YES;
            }
        }];
        
        if (verified) {
            verified = [self.password isEqualToString:self.confirmedPassword];
        }
        
        return verified;
    }
    
    return YES;
}

- (void)saveUser
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *pushToken = [ud objectForKey:SLUserDefaultsPushNotificationToken];
    
    if (!pushToken) {
        NSLog(@"Error: Could not create user because app has not receive push token from google");
        return;
    }
    
    NSDictionary *user;
    if (self.currentStage == SLLoginStageNew) {
        user = @{@"first_name": self.firstName,
                 @"last_name": self.lastName,
                 @"user_id": self.phoneNumber,
                 @"password": self.password,
                 @"fb_flag": @(NO),
                 @"reg_id": pushToken
                 };
    } else if (self.currentStage == SLLoginStageExisting) {
        user = @{@"first_name": [NSNull null],
                 @"last_name": [NSNull null],
                 @"user_id": self.phoneNumber,
                 @"password": self.password,
                 @"fb_flag": [NSNull null],
                 @"reg_id": pushToken
                 };
    }
    
    if (!user) {
        NSLog(@"Error: Could not create user");
        return;
    }
    
    // TODO: Saving a user should be moved to its own class
    [SLRestManager.sharedManager
     postObject:user
     serverKey:SLRestManagerServerKeyMain
     pathKey:SLRestManagerPathUsers
     subRoutes:nil
     additionalHeaders:nil
     completion:^(NSDictionary *responseDict) {
         if (!responseDict) {
             NSLog(@"Did not receive user response while saving user: %@", user);
             return;
         }
         
         NSLog(@"response saving user: %@", responseDict);
         NSString *accessToken = responseDict[@"token"];
         
         [ud setObject:accessToken forKey:SLUserDefaultsUserToken];
         [ud synchronize];
         
         [self signInSuccessful];
     }
     ];
    
}

- (NSUInteger)numberOfFieldsFilledIn
{
    NSArray *values = @[self.firstName ? self.firstName : @"",
                        self.lastName ? self.lastName : @"",
                        self.phoneNumber ? self.phoneNumber : @"",
                        self.password ? self.password : @"",
                        self.confirmedPassword ? self.confirmedPassword : @""
                        ];
    
    NSUInteger count = 0;
    for (NSString *value in values) {
        if (![value isEqualToString:@""]) {
            count++;
        }
    }
    
    return count;
}

- (BOOL)doPasswordsMatch
{
    return [self.password isEqualToString:self.confirmedPassword];
}

- (void)updateParamsValues:(NSString *)update
{
    switch (self.currentFieldTag) {
        case SLLoginFieldTagFirstName:
            self.firstName = update;
            break;
        case SLLoginFieldTagLastName:
            self.lastName = update;
            break;
        case SLLoginFieldTagPhoneNumber:
            self.phoneNumber = update;
            break;
        case SLLoginFieldTagPassword:
            self.password = update;
            break;
        case SLLoginFieldTagConfirmPassword:
            self.confirmedPassword = update;
            break;
        default:
            break;
    }
}

#pragma mark - Text Field delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentFieldTag = textField.tag;
    self.originalFieldFrame = textField.frame;
    
    [self.view addSubview:self.touchStopperView];
    [self.view bringSubviewToFront:textField];
    
    if ((self.currentStage == SLLoginStageExisting && (self.phoneNumber.length > 0 || self.password.length > 0)) ||
        (self.currentStage == SLLoginStageNew && self.numberOfFieldsFilledIn >= self.textFields.allKeys.count - 1)) {
        textField.returnKeyType = UIReturnKeyDone;
    } else {
        textField.returnKeyType = UIReturnKeyDefault;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.areFieldsVerified) {
        [self saveUser];
    } else if (self.currentStage == SLLoginStageNew && self.numberOfFieldsFilledIn == self.textFields.count) {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Passwords Do Not Match", nil)
                                                                                 message:NSLocalizedString(@"Please change passwords so that they match.", nil)
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *newValue = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateParamsValues:newValue];
    
    
    [textField becomeFirstResponder];
    
    return YES;
}



@end
