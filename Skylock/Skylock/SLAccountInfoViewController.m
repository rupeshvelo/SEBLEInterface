//
//  SLAccountInfoViewController.m
//  Skylock
//
//  Created by Andre Green on 7/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAccountInfoViewController.h"
#import "SLCirclePicView.h"
#import "SLAccountInfoFieldView.h"
#import "UIColor+RGB.h"
#import "SLDatabaseManager.h"
#import "SLDbUser+Methods.h"
#import "SLPicManager.h"

#define kSLAccountInfoFieldVCLabelFont  [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define kSLAccountInfoFieldVCXPadding   25.0f

@interface SLAccountInfoViewController ()

@property (nonatomic, strong) UILabel *accountHeaderLabel;
@property (nonatomic, strong) UILabel *accountInfoLabel;

@property (nonatomic, strong) SLCirclePicView *picView;

@property (nonatomic, strong) SLAccountInfoFieldView *emailFieldView;
@property (nonatomic, strong) SLAccountInfoFieldView *phoneNumberView;
@property (nonatomic, strong) SLAccountInfoFieldView *passwordView;

@property (nonatomic, strong) UIButton *logoutButton;


@end

@implementation SLAccountInfoViewController

- (UILabel *)accountHeaderLabel
{
    if (!_accountHeaderLabel) {
        _accountHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                        0.0f,
                                                                        self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                        16.0f)];
        _accountHeaderLabel.text = NSLocalizedString(@"Account", nil);
        _accountHeaderLabel.font = kSLAccountInfoFieldVCLabelFont;
        _accountHeaderLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
        [self.view addSubview:_accountHeaderLabel];
    }
    
    return _accountHeaderLabel;
}

- (UILabel *)accountInfoLabel
{
    if (!_accountInfoLabel) {
        _accountInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                      28.0f)];
        _accountInfoLabel.text = NSLocalizedString(@"Your user account can be used to connect to your lock after losing your phone.", nil);
        _accountInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        _accountInfoLabel.textColor = [UIColor colorWithRed:128 green:128 blue:128];
        _accountInfoLabel.numberOfLines = 0;
        [self.view addSubview:_accountInfoLabel];
    }
    
    return _accountInfoLabel;
}

- (SLCirclePicView *)picView
{
    if (!_picView) {
        _picView = [[SLCirclePicView alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    70.0f,
                                                                    87.0f)
                                                     name:NSLocalizedString(@"Change photo", nil)
                                                picRadius:35.0f
                                               labelColor:[UIColor colorWithRed:52 green:152 blue:219]];
        _picView.delegate = self;
        [self.view addSubview:_picView];
    }
    
    return _picView;
}

- (SLAccountInfoFieldView *)emailFieldView
{
    if (!_emailFieldView) {
        _emailFieldView = [[SLAccountInfoFieldView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                   0.0f,
                                                                                   self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                                   33.0f)
                                                           headerString:NSLocalizedString(@"Email Address", nil)
                                                             infoString:self.user.email
                                                           buttonString:NSLocalizedString(@"Change email address", nil) showSecure:NO];
        [self.view addSubview:_emailFieldView];
    }
    
    return _emailFieldView;
}

- (SLAccountInfoFieldView *)phoneNumberView
{
    if (!_phoneNumberView) {
        _phoneNumberView = [[SLAccountInfoFieldView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                    0.0f,
                                                                                    self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                                    33.0f)
                                                            headerString:NSLocalizedString(@"Phone number", nil)
                                                              infoString:self.user.phoneNumber
                                                            buttonString:NSLocalizedString(@"Change phone number", nil) showSecure:NO];
        [self.view addSubview:_phoneNumberView];
    }
    
    return _phoneNumberView;
}

- (SLAccountInfoFieldView *)passwordView
{
    if (!_passwordView) {
        _passwordView = [[SLAccountInfoFieldView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                                 33.0f)
                                                         headerString:NSLocalizedString(@"Password", nil)
                                                           infoString:self.user.password
                                                         buttonString:NSLocalizedString(@"Change password", nil)
                                                           showSecure:YES];
        [self.view addSubview:_passwordView];
    }
    
    return _passwordView;
}

- (UIButton *)logoutButton
{
    if (!_logoutButton) {
        UIImage *image = [UIImage imageNamed:@"btn_facebooklogout"];
        _logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   image.size.width,
                                                                   image.size.height)];
        [_logoutButton addTarget:self
                          action:@selector(logoutButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [_logoutButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_logoutButton];
    }
    
    return _logoutButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 25.0f, 35.0f)];
    titleView.image = [UIImage imageNamed:@"img_logo2"];
    titleView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_chevron_left"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(navBackButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.accountHeaderLabel.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                               25.0f,
                                               self.accountHeaderLabel.bounds.size.width,
                                               self.accountHeaderLabel.bounds.size.height);
    
    self.accountInfoLabel.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                             CGRectGetMaxY(self.accountHeaderLabel.frame) + 6.0f,
                                             self.accountInfoLabel.bounds.size.width,
                                             self.accountInfoLabel.bounds.size.height);
    
    self.picView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.picView.bounds.size.width),
                                    CGRectGetMaxY(self.accountInfoLabel.frame) + 30.0f,
                                    self.picView.bounds.size.width,
                                    self.picView.bounds.size.height);
    
    [SLPicManager.manager facebookPicForFBUserId:self.user.facebookId email:self.user.email completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.picView setPicImage:image];
        });
    }];
    
    self.emailFieldView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                             CGRectGetMaxY(self.picView.frame) + 47.0f,
                                             self.emailFieldView.bounds.size.width,
                                             self.emailFieldView.bounds.size.height);
    
    self.phoneNumberView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                             CGRectGetMaxY(self.emailFieldView.frame) + 30.0f,
                                             self.phoneNumberView.bounds.size.width,
                                             self.phoneNumberView.bounds.size.height);
    
    self.passwordView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                             CGRectGetMaxY(self.phoneNumberView.frame) + 30.0f,
                                             self.passwordView.bounds.size.width,
                                             self.passwordView.bounds.size.height);
    
    self.logoutButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.logoutButton.bounds.size.width),
                                    CGRectGetMaxY(self.passwordView.frame) + 45.0f,
                                    self.logoutButton.bounds.size.width,
                                    self.logoutButton.bounds.size.height);
}

- (void)logoutButtonPressed
{
    
}

- (void)navBackButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Circle Pic View delegate methods
- (void)circlePicViewPressed:(SLCirclePicView *)picView
{
    
}
@end
