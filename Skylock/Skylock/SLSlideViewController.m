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
#import "UIColor+RGB.h"
#import "SLSlideTableViewHeader.h"
#import "SLPicManager.h"
#import "SLEditLockTableViewCell.h"
#import "SLLock.h"
#import "SLNotifications.h"

#define kSLSlideViewControllerOptionCellIdentifier  @"SLSlideViewControllerOptionCellIdentifier"
#define kSLSlideViewControllerRowImageKey           @"SLSlideViewControllerRowImageName"
#define kSLSlideViewControllerRowTextKey            @"SLSlideViewControllerRowTextKey"
#define kSLSlideViewControllerCellHeight            56.0f
#define kSLSlideViewControllerHeaderHeight          100.0

@interface SLSlideViewController()

@property (nonatomic, strong) UIButton *testButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *optionsTableView;
@property (nonatomic, strong) NSArray *locks;
@property (nonatomic, strong) NSArray *options;
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
                                                                   self.tableHeight)
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
                                                                          CGRectGetMaxY(self.tableView.frame),
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
        _options = @[@{@"title":NSLocalizedString(@"Sharing", nil),
                       @"imageName":@"icon_chevron_right"
                       },
                     @{@"title":NSLocalizedString(@"Add Lock", nil),
                       @"imageName":@"icon_lock"
                       },
                     @{@"title":NSLocalizedString(@"Store", nil),
                       @"imageName":@"icon_store"
                       },
                     @{@"title":NSLocalizedString(@"Help", nil),
                       @"imageName":@"icon_help"
                       }
                     ];
    }
    
    return _options;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [SLDatabaseManager.manager currentUser];
    self.view.backgroundColor = [UIColor whiteColor];
    self.isEditMode = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resizeTables)
                                                 name:kSLNotificationLockManagerConnectedLock
                                               object:nil];
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
}

- (NSString *)lockTableViewCellIdentifier
{
    return NSStringFromClass([SLLockTableViewCell class]);
}

- (NSString *)editLockTableViewCellIdentifier
{
    return NSStringFromClass([SLEditLockTableViewCell class]);
}

- (CGFloat)tableHeight
{
    return self.locks.count*kSLSlideViewControllerCellHeight + kSLSlideViewControllerHeaderHeight;
}

- (void)setOptionsTableFrame
{
    
    
}

- (void)resizeTables
{
    self.locks = [SLLockManager.manager orderedLocksByName];
    self.tableView.frame = CGRectMake(0.0f,
                                      0.0f,
                                      self.tableView.frame.size.width,
                                      self.tableHeight);
    [self.tableView reloadData];
    
    self.optionsTableView.frame = CGRectMake(0.0f,
                                             CGRectGetMaxY(self.tableView.frame),
                                             self.optionsTableView.bounds.size.width,
                                             self.optionsTableView.bounds.size.height);
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
        return kSLSlideViewControllerHeaderHeight;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isMemberOfClass:[SLLockTableViewCell class]]) {
            SLLock *selectedLock = self.locks[indexPath.row];
            SLSlideViewControllerButtonAction action;
            if (selectedLock.isCurrentLock.boolValue) {
                [SLLockManager.manager deselectAllLocks];
                action = SLSlideViewControllerButtonActionLockDeselected;
            } else {
                [SLLockManager.manager setCurrentLock:selectedLock];
                action = SLSlideViewControllerButtonActionLockSelected;
            }
            
            if ([self.delegate respondsToSelector:@selector(slideViewController:actionOccured:options:)]) {
                [self.delegate slideViewController:self actionOccured:action options:nil];
            }
            
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        SLSlideViewControllerButtonAction action;;
        switch (indexPath.row) {
            case 0:
                action = SLSlideViewControllerButtonActionSharing;
                break;
            case 1:
                action = SLSlideViewControllerButtonActionAddLock;
                break;
            case 2:
                action = SLSlideViewControllerButtonActionNone;
                break;
            case 3:
                action = SLSlideViewControllerButtonActionNone;
                break;
            default:
                action = SLSlideViewControllerButtonActionNone;
                break;
        }
        
        if (action != SLSlideViewControllerButtonActionNone &&
            [self.delegate respondsToSelector:@selector(slideViewController:actionOccured:options:)]) {
            [self.delegate slideViewController:self actionOccured:action options:nil];
        }
    }
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
        NSUInteger target = NSUIntegerMax;
        for (NSUInteger i=0; i < self.locks.count; i++) {
            SLLock *aLock = self.locks[i];
            if ([aLock.name isEqualToString:lock.name]) {
                target = i;
                break;
            }
        }
        
        if (target != NSUIntegerMax) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:target inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[path]
                                  withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView endUpdates];
        }
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
    if ([self.delegate respondsToSelector:@selector(slideViewController:actionOccured:options:)]) {
        [self.delegate slideViewController:self
                             actionOccured:SLSlideViewControllerButtonActionViewAccount
                                   options:nil];
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
- (void)editLockCellRenamePushed:(SLEditLockTableViewCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(slideViewController:actionOccured:options:)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        SLLock *lock = self.locks[indexPath.row];
        [self.delegate slideViewController:self
                             actionOccured:SLSlideViewControllerButtonActionRename
                                   options:@{@"lock":lock}];
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
