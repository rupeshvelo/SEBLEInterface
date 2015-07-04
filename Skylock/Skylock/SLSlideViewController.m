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
#import "SLSettingsViewController.h"
#import "SLNavigationViewController.h"
#import "SLAddLockViewController.h"


#define kSLSlideViewControllerOptionCellIdentifier  @"SLSlideViewControllerOptionCellIdentifier"
#define KSLSlideViewControllerRowImageKey           @"SLSlideViewControllerRowImageName"
#define KSLSlideViewControllerRowTextKey            @"SLSlideViewControllerRowTextKey"


@interface SLSlideViewController()

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *locks;
@property (nonatomic, strong) NSArray *rowOptions;

@end

@implementation SLSlideViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
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

- (NSArray *)rowOptions
{
    if (!_rowOptions) {
        _rowOptions = @[@{KSLSlideViewControllerRowTextKey: NSLocalizedString(@"Add Lock", nil),
                          KSLSlideViewControllerRowImageKey: @"add-icon"
                          },
                        @{KSLSlideViewControllerRowTextKey: NSLocalizedString(@"Store", nil),
                          KSLSlideViewControllerRowImageKey: @""
                          },
                        @{KSLSlideViewControllerRowTextKey: NSLocalizedString(@"Settings", nil),
                          KSLSlideViewControllerRowImageKey: @"settings-icon"
                          },
                        @{KSLSlideViewControllerRowTextKey: NSLocalizedString(@"Help & Feedback", nil),
                          KSLSlideViewControllerRowImageKey: @"help-icon"
                          }
                        ];
    }
    
    return _rowOptions;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.tableView]) {
        [self.view addSubview:self.tableView];
    }
}

- (NSString *)lockTableViewCellIdentifier
{
    return NSStringFromClass([SLLockTableViewCell class]);
}

#pragma mark UITableView delegate & datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.locks.count : self.rowOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SLLock *lock = self.locks[indexPath.row];
        SLLockTableViewCell *lockCell = (SLLockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.lockTableViewCellIdentifier];
        [lockCell updateCellWithLock:lock];
        return lockCell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSLSlideViewControllerOptionCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:kSLSlideViewControllerOptionCellIdentifier];
        }
       
        NSString *imageName = self.rowOptions[indexPath.row][KSLSlideViewControllerRowImageKey];
        cell.imageView.image = [UIImage imageNamed:imageName];
        cell.textLabel.text = self.rowOptions[indexPath.row][KSLSlideViewControllerRowTextKey];
        return cell;
    }
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
    if (section == 0) {
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    self.tableView.bounds.size.width,
                                                                    [self tableView:tableView heightForHeaderInSection:section])];
        header.backgroundColor = SLConstantsMainTeal;
        header.text = NSLocalizedString(@"SKYLOCK", nil);
        header.textAlignment = NSTextAlignmentCenter;
        header.font = SLConstantsTableHeaderFont;
        header.textColor = [UIColor whiteColor];
        return header;
    } else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.tableView.bounds.size.width,
                                                                      [self tableView:tableView heightForHeaderInSection:section])];
        headerView.backgroundColor = [UIColor grayColor];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return .15*tableView.bounds.size.height;
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return .01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([self.delegate respondsToSelector:@selector(slideViewController:buttonPushed:options:)]) {
            [self.delegate slideViewController:self
                                  buttonPushed:[self buttonActionForIndexPath:indexPath]
                                       options:[self optionsForIndexPath:indexPath]];
        }
    } else {
        switch (indexPath.row) {
            case 0:
                NSLog(@"Add lock");
                [self presentAddLockViewController];
                break;
            case 1:
                NSLog(@"Store");
                break;
            case 2:
                [self presentSettingsViewControllerWithIndexPath:indexPath];
                break;
            case 3:
                NSLog(@"Health and Feedback");
                break;
            default:
                break;
        }
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
    SLSettingsViewController *svc = [SLSettingsViewController new];
    svc.lock = self.locks[indexPath.row];
    
    SLNavigationViewController *navController = [[SLNavigationViewController alloc] initWithRootViewController:svc];
    
    [self presentViewController:navController animated:YES completion:nil];
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
@end
