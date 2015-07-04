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
        _tableView.rowHeight = 80.0f;
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
    
    self.locks = [NSArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.view.subviews containsObject:self.tableView]) {
        [self.view addSubview:self.tableView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(lockDiscovered)
                                                 name:kSLNotificationLockManagerDiscoverdLock
                                               object:nil];
}

- (void)lockDiscovered
{
    self.locks = [SLLockManager.manager unaddedLocks];
    [self.tableView reloadData];
}

- (void)headerButtonPressed
{
    NSLog(@"header button pressed");
    [SLLockManager.manager startScan];
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
    cell.textLabel.text =lock.name;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.headerHeight;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                            0.0f,
                                                                            self.tableView.bounds.size.width,
                                                                            [self tableView:tableView heightForHeaderInSection:section])];
        [headerButton addTarget:self action:@selector(headerButtonPressed) forControlEvents:UIControlEventTouchDown];
        [headerButton setTitle:NSLocalizedString(@"Scan For Devices", nil) forState:UIControlStateNormal];
        [headerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [headerButton setBackgroundColor:SLConstantsMainTeal];
        headerButton.titleLabel.font = SLConstantsDefaultFont;
        return headerButton;
    }
    
    return nil;
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
