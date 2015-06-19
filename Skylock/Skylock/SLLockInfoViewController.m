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
#import "SLConstants.h"

#define kSLLockInfoViewControllerXPaddingScaler 0.05f
#define kSLLockInfoViewControllerYPaddingScaler 0.1f

@interface SLLockInfoViewController()

@property (nonatomic, strong) SLLockInfoViewHeader *headerView;
@property (nonatomic, strong) SLLockInfoMiddleView *middleView;
@property (nonatomic, strong) SLLock *lock;

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
        _middleView = [[SLLockInfoMiddleView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.bounds.size.width,
                                                                             self.view.bounds.size.height - self.headerView.bounds.size.height)
                                                          andLock:self.lock
                                                   xPaddingScaler:kSLLockInfoViewControllerXPaddingScaler
                                                   yPaddingScaler:kSLLockInfoViewControllerYPaddingScaler];
        _middleView.delegate = self;
    }
    
    return _middleView;
}

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = SLConstantsViewCornerRadius1;
    self.view.clipsToBounds = YES;
    
    // mock lock data for testing
    self.lock = [[SLLock alloc] initWithName:@"One Love"
                            batteryRemaining:@(46.7)
                                wifiStrength:@(56.8)
                                cellStrength:@(87.98)
                                    lastTime:@(354)
                                distanceAway:@(12765)
                                    isLocked:@(YES)
                                      lockId:@"bkdidlldie830387jdod9"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.middleView.frame = CGRectMake(0.0f,
                                       CGRectGetMaxY(self.headerView.frame),
                                       self.middleView.frame.size.width,
                                       self.middleView.frame.size.height);
    
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.middleView];
}

#pragma mark - SLLockInfoViewHeaderDelegate Methods
- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - SLLockInfoMiddleView Delegate Methods
- (void)middleViewCrashButtonPressed:(SLLockInfoMiddleView *)middleView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

}

- (void)middleViewSecurityButtonPressed:(SLLockInfoMiddleView *)middleView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

}

- (void)middleViewSharingButtonPressed:(SLLockInfoMiddleView *)middleView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

}


@end
