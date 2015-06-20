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
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}


- (NSArray *)locks
{
    if (!_locks) {
        _locks = [SLLockManager.manager orderedLocks];
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
    
    [self.tableView registerClass:[SLLockTableViewCell class] forCellReuseIdentifier:self.lockTableViewCellIdentifier];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
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

@end
