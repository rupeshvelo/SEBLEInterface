//
//  SLSlideViewController.m
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSlideViewController.h"
#import "SLLockManager.h"
#import "SLLockTableViewCell.h"
#import "SLConstants.h"
//#import "SLSettingsViewController.h"
#import "SLNavigationViewController.h"
#import "SLAddLockViewController.h"
#import "SLCirclePicView.h"
#import "SLDbUser+Methods.h"
#import "SLDatabaseManager.h"
#import "SLSlideControllerOptionsView.h"
#import "UIColor+RGB.h"
#import "SLSlideTableViewHeader.h"
#import "SLPicManager.h"



#define kSLSlideViewControllerOptionCellIdentifier  @"SLSlideViewControllerOptionCellIdentifier"
#define kSLSlideViewControllerRowImageKey           @"SLSlideViewControllerRowImageName"
#define kSLSlideViewControllerRowTextKey            @"SLSlideViewControllerRowTextKey"

@interface SLSlideViewController()

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *locks;
@property (nonatomic, strong) SLSlideControllerOptionsView *optionsView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) SLDbUser *user;

@end

@implementation SLSlideViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - self.optionsView.bounds.size.height - self.dividerView.bounds.size.height)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[SLLockTableViewCell class] forCellReuseIdentifier:self.lockTableViewCellIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        _tableView.scrollEnabled = NO;
    }
    
    return _tableView;
}


- (NSArray *)locks
{
    if (!_locks) {
        _locks = [SLLockManager.manager orderedLocksByName];
    }
    
    return _locks;
}

- (SLSlideControllerOptionsView *)optionsView
{
    if (!_optionsView) {
        _optionsView = [[SLSlideControllerOptionsView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                      0.0f,
                                                                                      127.0f,
                                                                                      125.0f)];
        _optionsView.delegate = self;
    }
    
    return _optionsView;
}

- (UIView *)dividerView
{
    if (!_dividerView) {
        _dividerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                self.view.bounds.size.width,
                                                                1.0f)];
        _dividerView.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
    }
    
    return _dividerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [SLDatabaseManager.manager currentUser];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.tableView]) {
        [self.view addSubview:self.tableView];
    }
    
    if (![self.view.subviews containsObject:self.dividerView]) {
        self.dividerView.frame = CGRectMake(0.0f,
                                            CGRectGetMaxY(self.tableView.frame),
                                            self.dividerView.bounds.size.width,
                                            self.dividerView.bounds.size.height);
        [self.view addSubview:self.dividerView];
    }
    
    if (![self.view.subviews containsObject:self.optionsView]) {
        self.optionsView.frame = CGRectMake(0.0f,
                                            CGRectGetMaxY(self.dividerView.frame),
                                            self.optionsView.bounds.size.width,
                                            self.optionsView.bounds.size.height);
        [self.view addSubview:self.optionsView];
    }
    
    
}

- (NSString *)lockTableViewCellIdentifier
{
    return NSStringFromClass([SLLockTableViewCell class]);
}

#pragma mark UITableView delegate & datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLLock *lock = self.locks[indexPath.row];
    SLLockTableViewCell *lockCell = (SLLockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.lockTableViewCellIdentifier];
    [lockCell updateCellWithLock:lock];
    return lockCell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SLSlideTableViewHeader *header = [[SLSlideTableViewHeader alloc] initWithFrame:CGRectMake(0.0f,
                                                                                              0.0f,
                                                                                              self.view.bounds.size.width,
                                                                                              [self tableView:tableView heightForHeaderInSection:section])];
    header.name = self.user.fullName;
    header.delegate = self;
    
    if (self.user.facebookId) {
        [SLPicManager.manager facebookPicForFBUserId:self.user.facebookId email:self.user.email completion:^(UIImage *image) {
            if (!image) {
                image = [UIImage imageNamed:@"img_userav_small"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [header.circleView setPicImage:image];
            });
            
        }];
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(slideViewController:buttonPushed:options:)]) {
        [self.delegate slideViewController:self
                              buttonPushed:[self buttonActionForIndexPath:indexPath]
                                   options:[self optionsForIndexPath:indexPath]];
    }
}

- (SLSlideViewControllerButtonAction)buttonActionForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return SLSlideViewControllerButtonActionLockSelected;
    } else {
        switch (indexPath.row) {
            case 0:
                return SLSlideViewcontrollerButtonActionAddLock;
                break;
            case 1:
                return SLSlideViewControllerButtonActionStore;
                break;
            case 2:
                return SLSlideViewControllerButtonActionSettings;
                break;
            case 3:
                return SLSlideViewControllerButtonActionHelp;
                break;
            default:
                return SLSlideViewControllerButtonActionNone;
                break;
        }
    }
}

- (void)presentSettingsViewControllerWithIndexPath:(NSIndexPath *)indexPath
{
//    SLSettingsViewController *svc = [SLSettingsViewController new];
//    svc.lock = self.locks[indexPath.row];
//    
//    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:svc];
//    
//    [self presentViewController:navController animated:YES completion:nil];
}

- (NSDictionary *)optionsForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return @{@"lock":self.locks[indexPath.row]};
    }
    
    return nil;
}

- (void)presentAddLockViewController
{
    SLAddLockViewController *alvc = [SLAddLockViewController new];
    alvc.delegate = self;
    alvc.headerHeight = [self tableView:self.tableView heightForHeaderInSection:0];
    alvc.view.frame = CGRectMake(-self.view.bounds.size.width,
                                 0.0f,
                                 self.view.bounds.size.width,
                                 self.view.bounds.size.height);
    [self addChildViewController:alvc];
    [self.view addSubview:alvc.view];
    [self.view bringSubviewToFront:alvc.view];
    [alvc didMoveToParentViewController:self];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        alvc.view.frame = CGRectMake(0.0f,
                                     0.0f,
                                     alvc.view.bounds.size.width,
                                     alvc.view.bounds.size.height);
    } completion:nil];
    
}

#pragma mark - SLAddLockViewController Delegate Methods
- (void)addLockViewController:(SLAddLockViewController *)alvc didAddLock:(SLLock *)lock
{
    self.locks = [SLLockManager.manager orderedLocksByName];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        alvc.view.frame = CGRectMake(-alvc.view.bounds.size.width,
                                     0.0f,
                                     alvc.view.bounds.size.width,
                                     alvc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [alvc.view removeFromSuperview];
        [alvc removeFromParentViewController];
    }];
}

#pragma mark - Slide Tableview Header Delegate Methods
- (void)addAccountPressedForSlideTableHeader:(SLSlideTableViewHeader *)header
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(slideViewControllerViewAccountPressed:forUser:)]) {
        [self.delegate slideViewControllerViewAccountPressed:self forUser:self.user];
    }
}

#pragma mark - Slide Options View Delegate Methods
- (void)slideOptionsView:(SLSlideControllerOptionsView *)optionsView action:(SLSlideOptionsViewAction)action
{
    switch (action) {
        case SLSlideOptionsViewActionAddLock:
        
            break;
        case SLSlideOptionsViewActionStore:
            
            break;
        case SLSlideOptionsViewActionSettings:
            
            break;
        case SLSlideOptionsViewActionHelp:
            
            break;
        default:
            break;
    }
}

@end
