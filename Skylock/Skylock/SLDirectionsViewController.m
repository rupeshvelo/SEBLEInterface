//
//  SLDirectionsViewController.m
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDirectionsViewController.h"
#import "SLDirectionsTableViewCell.h"

#define kSLDirectionViewControllerDirectionCellId @"kSLDirectionViewControllerDirectionCellId"

@interface SLDirectionsViewController()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SLDirectionsViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[SLDirectionsTableViewCell class]
           forCellReuseIdentifier:kSLDirectionViewControllerDirectionCellId];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 90.0f;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLDirectionsTableViewCell *cell = (SLDirectionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSLDirectionViewControllerDirectionCellId];
    [cell setPropertiesWithDirection:self.directions[indexPath.row] isFirstDirection:indexPath.row == 0];
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return <#expression#>
//}

@end
