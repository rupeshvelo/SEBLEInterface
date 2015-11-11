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
#import "SLMainTutorialViewController.h"
#import "NSString+Skylock.h"


#define kSLLoginVCFontName      @"HelveticaNeue"
#define kSLLoginVCFont          [UIFont fontWithName:kSLLoginVCFontName size:17.0f]
#define KSLLoginVCDarkGrey      [UIColor colorWithRed:97 green:100 blue:100]
#define KSLLoginVCLightGrey     [UIColor colorWithRed:146 green:148 blue:151]
#define KSLLoginVCUnderlineGrey [UIColor colorWithRed:191 green:191 blue:191]


@interface SLLoginViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *getStartedButton;
@property (nonatomic, strong) UIImageView *skylockLogoView;
@property (nonatomic, assign) BOOL isGetStarted;
@property (nonatomic, strong) UILabel *letsGetStartedLabel;
@property (nonatomic, strong) UILabel *facebookLabel;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UILabel *alternateLabel;
@property (nonatomic, strong) SLUnderlineTextField *emailField;
@property (nonatomic, strong) SLUnderlineTextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *signUpButton;
@property (nonatomic, strong) UIButton *forgotPasswordButton;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) CGFloat xPadding;

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

- (UIButton *)getStartedButton
{
    if (!_getStartedButton) {
        UIImage *image = [UIImage imageNamed:@"btn_letsgetstarted"];
        _getStartedButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                       0.0f,
                                                                       image.size.width,
                                                                       image.size.height)];
        [_getStartedButton addTarget:self
                              action:@selector(getStartedButtonPressed)
                    forControlEvents:UIControlEventTouchDown];
        [_getStartedButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_getStartedButton];
    }
    
    return _getStartedButton;
}

- (UILabel *)letsGetStartedLabel
{
    if (!_letsGetStartedLabel) {
        
        NSString *text = NSLocalizedString(@"Let's get started!", nil);
        CGSize size = [text sizeWithFont:kSLLoginVCFont
                                 maxSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
        _letsGetStartedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         size.width,
                                                                         size.height)];
        _letsGetStartedLabel.text = text;
        _letsGetStartedLabel.font = kSLLoginVCFont;
        _letsGetStartedLabel.textColor = KSLLoginVCDarkGrey;
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
        _facebookLabel.textColor = KSLLoginVCLightGrey;
        _facebookLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_facebookLabel];
    }
    
    return _facebookLabel;
}

- (UIButton *)facebookButton
{
    if (!_facebookButton) {
        UIImage *image = [UIImage imageNamed:@"btn_facebooklogin"];
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

- (UILabel *)alternateLabel
{
    if (!_alternateLabel) {
        _alternateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.view.bounds.size.width,
                                                                    15.0f)];
        _alternateLabel.text = NSLocalizedString(@"Alternatively", nil);
        _alternateLabel.font = kSLLoginVCFont;
        _alternateLabel.textColor = KSLLoginVCDarkGrey;
        _alternateLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_alternateLabel];
    }
    
    return _alternateLabel;
}

- (SLUnderlineTextField *)emailField
{
    if (!_emailField) {
        _emailField = [[SLUnderlineTextField alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width - 2*self.xPadding,
                                                                             20.0f)
                                                        lineColor:KSLLoginVCUnderlineGrey];
        _emailField.placeholder = NSLocalizedString(@"Email Address", nil);
        _emailField.font = kSLLoginVCFont;
        _emailField.textColor = KSLLoginVCLightGrey;
        [self.view addSubview:_emailField];
    }
    
    return _emailField;
}

- (SLUnderlineTextField *)passwordField
{
    if (!_passwordField) {
        _passwordField = [[SLUnderlineTextField alloc] initWithFrame:CGRectMake(0.0f,
                                                                                0.0f,
                                                                                self.view.bounds.size.width - 2*self.xPadding,
                                                                                20.0f)
                                                           lineColor:KSLLoginVCUnderlineGrey];
        _passwordField.placeholder = NSLocalizedString(@"Password", nil);
        _passwordField.font = kSLLoginVCFont;
        _passwordField.textColor = KSLLoginVCLightGrey;
        [self.view addSubview:_passwordField];
    }
    
    return _passwordField;
}

- (UIButton *)loginButton
{
    if (!_loginButton) {
        UIImage *image = [UIImage imageNamed:@"btn_login"];
        _loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        [_loginButton addTarget:self
                         action:@selector(loginButtonPressed)
               forControlEvents:UIControlEventTouchDown];
        [_loginButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_loginButton];
    }
    
    return _loginButton;
}

- (UIButton *)signUpButton
{
    if (!_signUpButton) {
        UIImage *image = [UIImage imageNamed:@"btn_signup"];
        _signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   image.size.width,
                                                                   image.size.height)];
        [_signUpButton addTarget:self
                          action:@selector(signUpButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [_signUpButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_signUpButton];
    }
    
    return _signUpButton;
}

- (UIButton *)forgotPasswordButton
{
    if (!_forgotPasswordButton) {
        _forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           self.view.bounds.size.width,
                                                                           15.0f)];
        [_forgotPasswordButton addTarget:self
                          action:@selector(forgotPasswordButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [_forgotPasswordButton setTitle:NSLocalizedString(@"Forgot Password", nil)
                               forState:UIControlStateNormal];
        _forgotPasswordButton.titleLabel.font = [UIFont fontWithName:kSLLoginVCFontName size:9.0f];
        [_forgotPasswordButton setTitleColor:KSLLoginVCLightGrey forState:UIControlStateNormal];
        [self.view addSubview:_forgotPasswordButton];
    }
    
    return _forgotPasswordButton;

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
                                             selector:@selector(facebookSignInSuccessful)
                                                 name:kSLNotificationUserSignedInFacebook
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.skylockLogoView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.skylockLogoView.bounds.size.width),
                                            189.0f,
                                            self.skylockLogoView.bounds.size.width,
                                            self.skylockLogoView.bounds.size.height);
    
    self.getStartedButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.getStartedButton.bounds.size.width),
                                             CGRectGetMaxY(self.skylockLogoView.frame) + 20.0f,
                                             self.getStartedButton.bounds.size.width,
                                             self.getStartedButton.bounds.size.height);
    
    self.letsGetStartedLabel.frame = CGRectMake(-self.letsGetStartedLabel.bounds.size.width,
                                                CGRectGetMaxY(self.skylockLogoView.frame) + 40.0f,
                                                self.letsGetStartedLabel.bounds.size.width,
                                                self.letsGetStartedLabel.bounds.size.height);
    
    self.facebookLabel.frame = CGRectMake(self.view.bounds.size.width,
                                          self.view.bounds.size.height - 200.0f,
                                          self.facebookLabel.bounds.size.width,
                                          self.facebookLabel.bounds.size.height);
    
    self.facebookButton.frame = CGRectMake(-self.facebookButton.bounds.size.width,
                                           CGRectGetMaxY(self.facebookLabel.frame) + 6.0f,
                                           self.facebookButton.bounds.size.width,
                                           self.facebookButton.bounds.size.height);
    
//    self.alternateLabel.frame = CGRectMake(self.view.bounds.size.width,
//                                           CGRectGetMaxY(self.facebookButton.frame) + 40.0f,
//                                           self.alternateLabel.bounds.size.width,
//                                           self.alternateLabel.bounds.size.height);
//    
//    self.emailField.frame = CGRectMake(-self.emailField.bounds.size.width,
//                                       CGRectGetMaxY(self.alternateLabel.frame) + 40.0f,
//                                       self.emailField.bounds.size.width,
//                                       self.emailField.bounds.size.height);
//    
//    self.passwordField.frame = CGRectMake(self.view.bounds.size.width,
//                                          CGRectGetMaxY(self.emailField.frame) + 25.0f,
//                                          self.passwordField.bounds.size.width,
//                                          self.passwordField.bounds.size.height);
//    
//    self.loginButton.frame = CGRectMake(-self.loginButton.bounds.size.width,
//                                        CGRectGetMaxY(self.passwordField.frame) + 25.0f,
//                                        self.loginButton.bounds.size.width,
//                                        self.loginButton.bounds.size.height);
//    
//    self.signUpButton.frame = CGRectMake(self.view.bounds.size.width,
//                                         self.loginButton.frame.origin.y,
//                                         self.signUpButton.bounds.size.width,
//                                         self.loginButton.bounds.size.height);
//    
//    self.forgotPasswordButton.frame = CGRectMake(-self.forgotPasswordButton.bounds.size.width,
//                                                 CGRectGetMaxY(self.signUpButton.frame) + 20.0f,
//                                                 self.forgotPasswordButton.bounds.size.width,
//                                                 self.forgotPasswordButton.bounds.size.height);
    
    [self setUpGetStartedViews];
}

- (void)setUpGetStartedViews
{
    }

- (void)transitionToLogin
{
    [UIView animateWithDuration:SLConstantsAnimationDurration2 animations:^{
//        self.skylockLogoView.frame = CGRectOffset(self.skylockLogoView.frame,
//                                                  0.0f,
//                                                  50.0f - self.skylockLogoView.frame.origin.y);
        
        self.getStartedButton.frame = CGRectOffset(self.getStartedButton.frame,
                                                   0.0,
                                                   self.view.bounds.size.height + self.skylockLogoView.bounds.size.height - self.skylockLogoView.frame.origin.y);
    } completion:^(BOOL finished) {
        [self.getStartedButton removeFromSuperview];
        [self animateLoginComponents];
    }];
}

- (void)animateLoginComponents
{
    [UIView animateWithDuration:SLConstantsAnimationDurration2 animations:^{
        self.letsGetStartedLabel.frame = CGRectMake(.5*(self.view.bounds.size.width - self.letsGetStartedLabel.bounds.size.width),
                                                    self.letsGetStartedLabel.frame.origin.y,
                                                    self.letsGetStartedLabel.bounds.size.width,
                                                    self.letsGetStartedLabel.bounds.size.height);
        
        self.facebookLabel.frame = CGRectOffset(self.facebookLabel.frame,
                                                -self.facebookLabel.frame.size.width,
                                                0.0f);
        
        self.facebookButton.frame = CGRectOffset(self.facebookButton.frame,
                                                 self.facebookButton.bounds.size.width + self.xPadding,
                                                 0.0f);
        
//        self.alternateLabel.frame = CGRectOffset(self.alternateLabel.frame,
//                                                 -self.alternateLabel.bounds.size.width,
//                                                 0.0f);
//        
//        self.emailField.frame = CGRectOffset(self.emailField.frame,
//                                             self.emailField.bounds.size.width + self.xPadding,
//                                             0.0f);
        
//        self.passwordField.frame = CGRectMake(self.emailField.frame.origin.x,
//                                              self.passwordField.frame.origin.y,
//                                              self.passwordField.bounds.size.width,
//                                              self.passwordField.bounds.size.height);
//        
//        self.loginButton.frame = CGRectOffset(self.loginButton.frame,
//                                              self.loginButton.bounds.size.width + self.xPadding,
//                                              0.0f);
//        
//        self.signUpButton.frame = CGRectOffset(self.signUpButton.frame,
//                                               -self.xPadding - self.loginButton.bounds.size.width,
//                                               0.0f);
//        
//        self.forgotPasswordButton.frame = CGRectOffset(self.forgotPasswordButton.frame,
//                                                       self.forgotPasswordButton.bounds.size.width,
//                                                       0.0f);
    }];
}

- (void)getStartedButtonPressed
{
    NSLog(@"get started button pressed");
    
    [self transitionToLogin];
}

- (void)facebookButtonPressed
{
    NSLog(@"facebook login button pressed");
    [SLFacebookManger.sharedManager loginFromViewController:self withCompletion:^{
        NSLog(@"user loging completed!!! Yay!!");
    }];
}

- (void)loginButtonPressed
{
    NSLog(@"login button pressed");
}

- (void)signUpButtonPressed
{
    NSLog(@"sign up button pressed");
}

- (void)forgotPasswordButtonPressed
{
    NSLog(@"forgot password button pressed");
}

- (void)facebookSignInSuccessful
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(YES) forKey:SLUserDefaultsSignedIn];
    
    if ([ud objectForKey:SLUserDefaultsTutorialComplete]) {
        NSNumber *isTutorialComplete = [ud objectForKey:SLUserDefaultsTutorialComplete];
        if (isTutorialComplete.boolValue) {
            SLMapViewController *mvc = [SLMapViewController new];
            [self presentViewController:mvc animated:YES completion:nil];
        } else {
            SLMainTutorialViewController *tvc = [SLMainTutorialViewController new];
            [self presentViewController:tvc animated:YES completion:nil];
        }
    } else {
        [ud setObject:@(NO) forKey:SLUserDefaultsTutorialComplete];
        SLMainTutorialViewController *tvc = [SLMainTutorialViewController new];
        [self presentViewController:tvc animated:YES completion:nil];
    }
    
    [ud synchronize];
}
@end
