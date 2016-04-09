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
#import "SLUser.h"
#import "SLPicManager.h"
#import "Skylock-Swift.h"


#define kSLAccountInfoFieldVCLabelFont  [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define kSLAccountInfoFieldVCXPadding   25.0f

@interface SLAccountInfoViewController () <SLEmergencyContactPopupViewControllerDelegate>

@property (nonatomic, strong) UILabel *accountHeaderLabel;
@property (nonatomic, strong) UILabel *accountInfoLabel;
@property (nonatomic, strong) UIView *touchStopperView;

@property (nonatomic, strong) SLCirclePicView *picView;

@property (nonatomic, strong) SLAccountInfoFieldView *emailFieldView;
@property (nonatomic, strong) SLAccountInfoFieldView *phoneNumberView;
@property (nonatomic, strong) SLAccountInfoFieldView *passwordView;
@property (nonatomic, strong) SLAccountInfoFieldView *emergencyContactsView;

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

- (UIView *)touchStopperView
{
    if (!_touchStopperView) {
        _touchStopperView = [[UIView alloc] initWithFrame:self.view.bounds];
        _touchStopperView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.75];
    }
    
    return _touchStopperView;
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
                                                             infoString:self.user.userId
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
                                                              infoString:self.user.userId
                                                            buttonString:NSLocalizedString(@"Change phone number", nil) showSecure:NO];
        __weak typeof(self) weakSelf = self;
        _phoneNumberView.buttonPressedBlock = ^{
            [weakSelf phoneNumberViewButtonPressed];
        };
        
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
                                                           infoString:self.user.userId
                                                         buttonString:NSLocalizedString(@"Change password", nil)
                                                           showSecure:YES];
        __weak typeof(self) weakSelf = self;
        _passwordView.buttonPressedBlock = ^{
            [weakSelf passwordViewButtonPressed];
        };
        
        [self.view addSubview:_passwordView];
    }
    
    return _passwordView;
}

- (SLAccountInfoFieldView *)emergencyContactsView
{
    if (!_emergencyContactsView) {
        _emergencyContactsView = [[SLAccountInfoFieldView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                          0.0f,
                                                                                          self.view.bounds.size.width - 2*kSLAccountInfoFieldVCXPadding,
                                                                                          33.0f)
                                                                  headerString:NSLocalizedString(@"Emergency Contacts", nil)
                                                                    infoString:@""
                                                                  buttonString:NSLocalizedString(@"+ Add Contacts", nil)
                                                                    showSecure:NO];
        __weak typeof(self) weakSelf = self;
        _emergencyContactsView.buttonPressedBlock = ^{
            [weakSelf emergencyContactsViewButtonPressed];
        };
        
        [self.view addSubview:_emergencyContactsView];
    }
    
    return _emergencyContactsView;
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.user = [SLDatabaseManager.sharedManager currentUser];
    
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
    
    [SLPicManager.sharedManager facebookPicForFBUserId:self.user.userId completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.picView setPicImage:image];
        });
    }];
    
    self.phoneNumberView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                            CGRectGetMaxY(self.picView.frame) + 47.0f,
                                            self.phoneNumberView.bounds.size.width,
                                            self.phoneNumberView.bounds.size.height);
    
    self.passwordView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                         CGRectGetMaxY(self.phoneNumberView.frame) + 30.0f,
                                         self.passwordView.bounds.size.width,
                                         self.passwordView.bounds.size.height);
    
    self.emergencyContactsView.frame = CGRectMake(kSLAccountInfoFieldVCXPadding,
                                                  CGRectGetMaxY(self.passwordView.frame) + 30.0f,
                                                  self.passwordView.bounds.size.width,
                                                  self.passwordView.bounds.size.height);
    
    self.logoutButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.logoutButton.bounds.size.width),
                                         CGRectGetMaxY(self.emergencyContactsView.frame) + 45.0f,
                                         self.logoutButton.bounds.size.width,
                                         self.logoutButton.bounds.size.height);
}

- (void)phoneNumberViewButtonPressed
{
    NSLog(@"phone number field button pressed");
}

- (void)passwordViewButtonPressed
{
    NSLog(@"password field button pressed");
}

- (void)emergencyContactsViewButtonPressed
{
    [self.view addSubview:self.touchStopperView];
    
    static CGFloat xPadding = 25.0f;
    static CGFloat yPadding = 50.0f;
    
    SLEmergencyContactPopupViewController *ecvc = [SLEmergencyContactPopupViewController new];
    ecvc.delegate = self;
    ecvc.view.frame = CGRectMake(xPadding,
                                 yPadding,
                                 self.view.bounds.size.width - 2*xPadding,
                                 self.view.bounds.size.height - 2*yPadding);
    ecvc.view.layer.cornerRadius = 2.0f;
    [self addChildViewController:ecvc];
    [self.view addSubview:ecvc.view];
    [self.view bringSubviewToFront:ecvc.view];
    [ecvc didMoveToParentViewController:self];
    
//    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
//        self.directionsViewController.view.frame = CGRectMake(self.view.bounds.size.width - self.directionsViewController.view.bounds.size.width,
//                                                              0.0f,
//                                                              self.directionsViewController.view.bounds.size.width,
//                                                              self.directionsViewController.view.bounds.size.height);
//    }];
}

- (void)logoutButtonPressed
{
    NSLog(@"logout button pressed");
}

- (void)navBackButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Circle Pic View delegate methods
- (void)circlePicViewPressed:(SLCirclePicView *)picView
{
    
}

#pragma mark - SLEmergencyContactsViewControllerDelegate Methods
- (void)contactPopUpViewControllerWantsExit:(SLEmergencyContactPopupViewController *)cpvc
{
    [UIView animateWithDuration:.2 animations:^{
        cpvc.view.frame = CGRectMake(cpvc.view.frame.origin.x + 20.0f,
                                     cpvc.view.frame.origin.y,
                                     cpvc.view.bounds.size.width,
                                     cpvc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.3 animations:^{
            cpvc.view.frame = CGRectMake(-cpvc.view.bounds.size.width,
                                         cpvc.view.frame.origin.y,
                                         cpvc.view.bounds.size.width,
                                         cpvc.view.bounds.size.height);
        } completion:^(BOOL finished) {
            [cpvc.view removeFromSuperview];
            [cpvc removeFromParentViewController];
            [self.touchStopperView removeFromSuperview];
        }];
    }];
}

@end
