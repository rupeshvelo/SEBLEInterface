//
//  SLAddLockViewController.m
//  Skylock
//
//  Created by Andre Green on 7/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAddLockViewController.h"
#import "SLLockManager.h"
#import "SLLock.h"
#import "SLConstants.h"
#import "SLNotifications.h"
#import "UIColor+RGB.h"
#import "NSString+Skylock.h"

@interface SLAddLockViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *locks;

@end

@implementation SLAddLockViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 56.0f;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SLLockManager.manager startScan];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockDiscovered)
                                                 name:kSLNotificationLockManagerDiscoverdLock
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.tableView]) {
        [self.view addSubview:self.tableView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SLLockManager.manager stopScan];
}

- (void)lockDiscovered
{
    self.locks = [SLLockManager.manager unaddedLocks];
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationTop];
}

- (void)backButtonPressed
{
    NSLog(@"back button pressed");
    if ([self.delegate respondsToSelector:@selector(addLockViewControllerWantsDismiss:)]) {
        [self.delegate addLockViewControllerWantsDismiss:self];
    }
}

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
    static NSString *cellId = @"SLAddLockViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    SLLock *lock = self.locks[indexPath.row];
    cell.textLabel.text = lock.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    cell.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 70.0f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                tableView.bounds.size.width,
                                                                [self tableView:tableView heightForHeaderInSection:section])];
    header.backgroundColor = [UIColor colorWithRed:110 green:223 blue:158];
    header.text = NSLocalizedString(@"Unadded Locks", nil);
    header.textColor = [UIColor whiteColor];
    header.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    header.textAlignment = NSTextAlignmentCenter;
    header.userInteractionEnabled = YES;
    
    UIImage *backImage = [UIImage imageNamed:@"icon_chevron_left_white"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                      CGRectGetMidY(header.bounds) - 1.5*backImage.size.height,
                                                                      6*backImage.size.width,
                                                                      3*backImage.size.height)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchDown];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12.0f, 0, 0);
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.frame = CGRectMake(header.bounds.size.width - spinner.bounds.size.width - 12.0f,
                               CGRectGetMidY(header.bounds) - .5*spinner.bounds.size.height,
                               spinner.bounds.size.width,
                               spinner.bounds.size.height);
    [spinner startAnimating];

    [header addSubview:backButton];
    [header addSubview:spinner];
    
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLLock *lock = self.locks[indexPath.row];
    [SLLockManager.manager addLock:lock];
    
    if ([self.delegate respondsToSelector:@selector(addLockViewController:didAddLock:)]) {
        [self.delegate addLockViewController:self didAddLock:lock];
    }
}
@end
