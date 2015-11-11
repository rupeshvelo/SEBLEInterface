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
    
    [SLLockManager.sharedManager startScan];
    
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
    //[SLLockManager.manager stopScan];
    //[SLLockManager.manager removeUnconnectedLocks];
}

- (void)lockDiscovered
{
    NSArray *unaddedLocks = [SLLockManager.sharedManager unaddedLocks];
    __block NSMutableArray *paths = [NSMutableArray new];
    
    [unaddedLocks enumerateObjectsUsingBlock:^(SLLock *unaddedLock, NSUInteger idx, BOOL *stop) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", unaddedLock.name];
        NSArray *results = [self.locks filteredArrayUsingPredicate:predicate];
        if (results.count == 0) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
            [paths addObject:path];
        }
    }];
    
    if (paths.count > 0) {
        self.locks = [NSArray arrayWithArray:unaddedLocks];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
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
    return 100.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                tableView.bounds.size.width,
                                                                [self tableView:tableView heightForHeaderInSection:section])];
    header.text = NSLocalizedString(@"Unadded Locks", nil);
    header.textColor = [UIColor colorWithRed:97 green:100 blue:100];
    header.font = [UIFont fontWithName:@"Helvetica" size:17.0f];
    header.textAlignment = NSTextAlignmentCenter;
    header.userInteractionEnabled = YES;
    
    UIImage *backImage = [UIImage imageNamed:@"icon_chevron_left"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                      CGRectGetMidY(header.bounds) - 1.5*backImage.size.height,
                                                                      6*backImage.size.width,
                                                                      3*backImage.size.height)];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchDown];
    [backButton setImage:backImage forState:UIControlStateNormal];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12.0f, 0, 0);
    
    UIFont *searchFont = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    NSString *searchText = NSLocalizedString(@"Searching", nil);
    CGSize searchSize = [searchText sizeWithFont:searchFont
                                         maxSize:CGSizeMake(header.bounds.size.width, CGFLOAT_MAX)];
    UILabel *searchingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMidX(header.bounds) - .5*searchSize.width,
                                                                        header.bounds.size.height - searchSize.height - 10.0f,
                                                                        searchSize.width,
                                                                        searchSize.height)];
    searchingLabel.font = searchFont;
    searchingLabel.text = searchText;
    searchingLabel.textColor = [UIColor colorWithRed:191 green:191 blue:191];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(searchingLabel.frame.origin.x - spinner.bounds.size.width - 3.0f,
                               CGRectGetMidY(searchingLabel.frame) - .5*spinner.bounds.size.height,
                               spinner.bounds.size.width,
                               spinner.bounds.size.height);
    [spinner startAnimating];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                header.bounds.size.height - 1.0f,
                                                                header.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
    
    [header addSubview:backButton];
    [header addSubview:searchingLabel];
    [header addSubview:spinner];
    [header addSubview:lineView];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                              0.0f,
                                                              tableView.bounds.size.width,
                                                              1.0f)];
    footer.backgroundColor = tableView.backgroundColor;
    
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLLock *lock = self.locks[indexPath.row];
    [SLLockManager.sharedManager addLock:lock];
    
    if ([self.delegate respondsToSelector:@selector(addLockViewController:didAddLock:)]) {
        [self.delegate addLockViewController:self didAddLock:lock];
    }
}
@end
