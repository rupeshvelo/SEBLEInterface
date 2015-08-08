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
#import "SLEditLockTableViewCell.h"


#define kSLSlideViewControllerOptionCellIdentifier  @"SLSlideViewControllerOptionCellIdentifier"
#define kSLSlideViewControllerRowImageKey           @"SLSlideViewControllerRowImageName"
#define kSLSlideViewControllerRowTextKey            @"SLSlideViewControllerRowTextKey"
#define kSLSlideViewControllerCellHeight            56.0f

@interface SLSlideViewController()

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *optionsTableView;
@property (nonatomic, strong) NSArray *locks;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) SLSlideControllerOptionsView *optionsView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) SLDbUser *user;
@property (nonatomic, assign) BOOL isEditMode;

@end

@implementation SLSlideViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - self.optionsTableView.bounds.size.height)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[SLLockTableViewCell class] forCellReuseIdentifier:self.lockTableViewCellIdentifier];
        [_tableView registerClass:[SLEditLockTableViewCell class] forCellReuseIdentifier:self.editLockTableViewCellIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        _tableView.rowHeight = kSLSlideViewControllerCellHeight;
        _tableView.scrollEnabled = NO;
    }
    
    return _tableView;
}

- (UITableView *)optionsTableView
{
    if (!_optionsTableView) {
        CGFloat height = self.options.count*kSLSlideViewControllerCellHeight;
        _optionsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                          self.view.bounds.size.height - height,
                                                                          self.view.bounds.size.width,
                                                                          height)
                                                         style:UITableViewStylePlain];
        _optionsTableView.delegate = self;
        _optionsTableView.dataSource = self;
        _optionsTableView.layoutMargins = UIEdgeInsetsZero;
        _optionsTableView.rowHeight = kSLSlideViewControllerCellHeight;
        _optionsTableView.scrollEnabled = NO;
    }
    
    return _optionsTableView;
}

- (NSArray *)locks
{
    if (!_locks) {
        _locks = [SLLockManager.manager orderedLocksByName];
    }
    
    return _locks;
}

- (NSArray *)options
{
    if (!_options) {
        _options = @[@{@"title":NSLocalizedString(@"Add Lock", nil),
                       @"imageName":@"icon_lock"
                       },
                     @{@"title":NSLocalizedString(@"Store", nil),
                       @"imageName":@"icon_store"
                       },
                     @{@"title":NSLocalizedString(@"Settings", nil),
                       @"imageName":@"icon_settings_small"
                       },
                     @{@"title":NSLocalizedString(@"Help", nil),
                       @"imageName":@"icon_help"
                       }
                     ];
    }
    
    return _options;
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
    self.isEditMode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.optionsTableView]) {
        [self.view addSubview:self.optionsTableView];
    }
    
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
    
//    if (![self.view.subviews containsObject:self.optionsView]) {
//        self.optionsView.frame = CGRectMake(0.0f,
//                                            CGRectGetMaxY(self.dividerView.frame),
//                                            self.optionsView.bounds.size.width,
//                                            self.optionsView.bounds.size.height);
//        [self.view addSubview:self.optionsView];
//    }
    
    
}

- (NSString *)lockTableViewCellIdentifier
{
    return NSStringFromClass([SLLockTableViewCell class]);
}

- (NSString *)editLockTableViewCellIdentifier
{
    return NSStringFromClass([SLEditLockTableViewCell class]);
}

#pragma mark UITableView delegate & datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableView == self.tableView ? self.locks.count : self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (self.isEditMode) {
            SLEditLockTableViewCell *cell = (SLEditLockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.editLockTableViewCellIdentifier];
            cell.delegate = self;
            
            return cell;
        } else {
            SLLock *lock = self.locks[indexPath.row];
            SLLockTableViewCell *cell = (SLLockTableViewCell *)[tableView dequeueReusableCellWithIdentifier:self.lockTableViewCellIdentifier];
            cell.delegate = self;
            [cell updateCellWithLock:lock];
            
            return cell;
        }
    }
    
    static NSString *optionsCellId = @"optionsCellId";
    UITableViewCell *optionsCell = [tableView dequeueReusableCellWithIdentifier:optionsCellId];
    if (!optionsCell) {
        optionsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:optionsCellId];
    }
    
    NSDictionary *option = self.options[indexPath.row];

    UIImage *image = [UIImage imageNamed:option[@"imageName"]];
    optionsCell.accessoryView = [[UIImageView alloc] initWithImage:image];
    
    optionsCell.textLabel.text = option[@"title"];
    optionsCell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    optionsCell.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
    optionsCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return optionsCell;
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
    if (tableView == self.tableView) {
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
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  [self tableView:tableView heightForFooterInSection:section],
                                                                  tableView.bounds.size.width)];
        footer.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
        return footer;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return 100.0f;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if ([self.delegate respondsToSelector:@selector(slideViewController:buttonPushed:options:)]) {
            [self.delegate slideViewController:self
                                  buttonPushed:[self buttonActionForIndexPath:indexPath]
                                       options:[self optionsForIndexPath:indexPath]];
        }
    } else {
        switch (indexPath.row) {
            case 0:
                [self presentAddLockViewController];
                break;
            case 1:
                NSLog(@"Store pressed");
                break;
            case 2:
                NSLog(@"Settings pressed");
                break;
            case 3:
                NSLog(@"Help pressed");
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
    //alvc.headerHeight = [self tableView:self.tableView heightForHeaderInSection:0];
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

- (void)dismissAddLockViewController:(SLAddLockViewController *)alvc withCompletion:(void(^)(void))completion
{
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        alvc.view.frame = CGRectMake(-alvc.view.bounds.size.width,
                                     0.0f,
                                     alvc.view.bounds.size.width,
                                     alvc.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [alvc.view removeFromSuperview];
        [alvc removeFromParentViewController];
        if (completion) {
            completion();
        }
    }];
}

- (NSArray *)indexPathsForSection:(NSUInteger)section
{
    NSMutableArray *paths = [NSMutableArray new];
    NSUInteger rows = [self.tableView numberOfRowsInSection:section];
    for (NSUInteger i = 0; i < rows; i++) {
        [paths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    return paths;
}

#pragma mark - SLAddLockViewController Delegate Methods
- (void)addLockViewController:(SLAddLockViewController *)alvc didAddLock:(SLLock *)lock
{
    [self dismissAddLockViewController:alvc withCompletion:^{
        self.locks = [SLLockManager.manager orderedLocksByName];
        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationLeft];
    }];
}

- (void)addLockViewControllerWantsDismiss:(SLAddLockViewController *)alvc
{
    [self dismissAddLockViewController:alvc withCompletion:nil];
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
            NSLog(@"add lock pressed");
            break;
        case SLSlideOptionsViewActionStore:
            NSLog(@"store pressed");
            break;
        case SLSlideOptionsViewActionSettings:
            NSLog(@"settings pressed");
            break;
        case SLSlideOptionsViewActionHelp:
            NSLog(@"help pressed");
            break;
        default:
            break;
    }
}

#pragma mark - SLLockTableViewCellDelegate methods
- (void)lockTableViewCellLongPressOccured:(SLLockTableViewCell *)cell
{
    self.isEditMode = YES;
    NSArray *paths = [self indexPathsForSection:0];
    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark - SLLockEditTableViewCellDelgate methods
- (void)editLockCellSharePushed:(SLEditLockTableViewCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(slideViewControllerSharingPressed:withLock:)]) {
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        SLLock *lock = self.locks[path.row];
        [self.delegate slideViewControllerSharingPressed:self withLock:lock];
    }
}

- (void)editLockCellRemovePushed:(SLEditLockTableViewCell *)cell
{
    NSLog(@"remove pushed");
}

- (void)editLockCellLongPressActivated:(SLEditLockTableViewCell *)cell
{
    self.isEditMode = NO;
    NSArray *paths = [self indexPathsForSection:0];
    [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationRight];
}

@end
