//
//  SLLockInfoViewController.m
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewController.h"
#import "SLLockInfoViewHeader.h"
#import "SLLock.h"
#import "SLLockInfoMiddleView.h"
#import "SLLockInfoBottomView.h"
#import "SLConstants.h"
#import "SLLockManager.h"
#import "SLSettingsViewController.h"
#import "SLNavigationViewController.h"

#define kSLLockInfoViewControllerXPaddingScaler 0.05f
#define kSLLockInfoViewControllerYPaddingScaler 0.1f

@interface SLLockInfoViewController()

@property (nonatomic, strong) SLLockInfoViewHeader *headerView;
@property (nonatomic, strong) SLLockInfoBottomView *bottomView;
@property (nonatomic, assign) CGFloat bottomHeight;
@end


@implementation SLLockInfoViewController

- (SLLockInfoViewHeader *)headerView
{
    if (!_headerView) {
        _headerView = [[SLLockInfoViewHeader alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width,
                                                                             50.0f)
                                                          andLock:self.lock
                                                   xPaddingScaler:kSLLockInfoViewControllerXPaddingScaler
                                                   yPaddingScaler:kSLLockInfoViewControllerYPaddingScaler];
        _headerView.delegate = self;
    }
    
    return _headerView;
}

- (SLLockInfoMiddleView *)middleView
{
    if (!_middleView) {
        CGFloat height = self.view.bounds.size.height - self.headerView.bounds.size.height - self.bottomHeight;
        _middleView = [[SLLockInfoMiddleView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width,
                                                                             height)
                                                          andLock:self.lock
                                                   xPaddingScaler:kSLLockInfoViewControllerXPaddingScaler
                                                   yPaddingScaler:kSLLockInfoViewControllerYPaddingScaler];
        _middleView.delegate = self;
    }
    
    return _middleView;
}

- (SLLockInfoBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[SLLockInfoBottomView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width,
                                                                             self.bottomHeight)
                                                          andLock:self.lock
                                                   xPaddingScaler:kSLLockInfoViewControllerXPaddingScaler
                                                   yPaddingScaler:kSLLockInfoViewControllerYPaddingScaler];
        _bottomView.delegate = self;
    }
    
    return _bottomView;
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = SLConstantsViewCornerRadius1;
    self.view.clipsToBounds = YES;
    
    self.bottomHeight = -1.0;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.bottomHeight < 0.0) {
        self.bottomHeight = .3*self.view.bounds.size.height;
    }
    
    self.middleView.frame = CGRectMake(0.0f,
                                       CGRectGetMaxY(self.headerView.frame),
                                       self.middleView.frame.size.width,
                                       self.middleView.frame.size.height);
    
    self.bottomView.frame = CGRectMake(0.0f,
                                       CGRectGetMaxY(self.middleView.frame),
                                       self.bottomView.frame.size.width,
                                       self.bottomView.frame.size.height);
    
    [self addSubView:self.headerView];
    [self addSubView:self.middleView];
    [self addSubView:self.bottomView];
}

- (void)addSubView:(UIView *)view
{
    BOOL hasView = NO;
    for (UIView *subview in self.view.subviews) {
        if (view == subview) {
            hasView = YES;
            break;
        }
    }
    
    if (!hasView) {
        [self.view addSubview:view];
    }
}

- (void)handleAction:(SLLockInfoViewControllerAction)action
{
    if ([self.delegate respondsToSelector:@selector(lockInfoViewController:action:)]) {
        [self.delegate lockInfoViewController:self action:action];
    }
}

#pragma mark - SLLockInfoViewHeaderDelegate Methods
- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    SLSettingsViewController *svc = [SLSettingsViewController new];
    svc.lock = self.lock;
    
    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:svc];

    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - SLLockInfoMiddleView Delegate Methods
- (void)middleViewCrashButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.lock.isCrashOn = @(stateOn);
    [SLLockManager.manager toggleCrashForLock:self.lock];
}

- (void)middleViewSecurityButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.lock.isSecurityOn = @(stateOn);
    [SLLockManager.manager toggleSecurityForLock:self.lock];
}

- (void)middleViewSharingButtonPressed:(SLLockInfoMiddleView *)middleView stateOn:(BOOL)stateOn
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    self.lock.isSharingOn = @(stateOn);
    //[SLLockManager.manager toggleSharignForLock:self.lock];
}

#pragma mark - SLLockInfoBottomView Delegate Methods
- (void)bottomViewButtonPressed:(SLLockInfoBottomView *)bottomView withLockState:(BOOL)isLocked
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
@end
