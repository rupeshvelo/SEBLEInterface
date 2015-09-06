//
//  SLSharingViewController.m
//  Skylock
//
//  Created by Andre Green on 6/27/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSharingViewController.h"
#import "SLContact.h"
#import "UIColor+RGB.h"
#import "NSString+Skylock.h"
#import "SLSharingTableViewCell.h"
#import "SLLock.h"
#import "SLDatabaseManager.h"
#import "SLAddContactViewController.h"


#define kSLSharingVCXPadding    25.0f
#define kSLSharingVCHeaderFont  [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define kSLSharingVCInfoFont    [UIFont fontWithName:@"HelveticaNeue" size:12.0f]
#define kSLSharingVCHeaderColor [UIColor colorWithRed:97 green:100 blue:100]
#define kSLSharingVCInfoColor   [UIColor colorWithRed:146 green:148 blue:151]

@interface SLSharingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *sharedContacts;
@property (nonatomic, strong) UIView *sharedWithHeader;
@property (nonatomic, strong) UIView *inviteFriendsHeader;

@end

@implementation SLSharingViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[SLSharingTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([SLSharingTableViewCell class])];
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}



- (UIView *)sharedWithHeader
{
    if (!_sharedWithHeader) {
        _sharedWithHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                     0.0f,
                                                                     self.tableView.bounds.size.width,
                                                                     [self tableView:self.tableView heightForHeaderInSection:0])];
        
        NSString *headerText = NSLocalizedString(@"Shared with...", nil);
        CGSize headerSize = [headerText sizeWithFont:kSLSharingVCHeaderFont
                                             maxSize:CGSizeMake(_sharedWithHeader.bounds.size.width - 2*kSLSharingVCXPadding, CGFLOAT_MAX)];
        UILabel *sharedHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSLSharingVCXPadding,
                                                                               25.0f,
                                                                               headerSize.width,
                                                                               headerSize.height)];
        sharedHeaderLabel.font = kSLSharingVCHeaderFont;
        sharedHeaderLabel.text = headerText;
        sharedHeaderLabel.textColor = kSLSharingVCHeaderColor;
        [_sharedWithHeader addSubview:sharedHeaderLabel];
        
        UIImage *shareImage = [UIImage imageNamed:@"icon_share"];
        UIImageView *shareView = [[UIImageView alloc] initWithImage:shareImage];
        shareView.frame = CGRectMake(kSLSharingVCXPadding,
                                     CGRectGetMaxY(sharedHeaderLabel.frame) + 3.0f,
                                     shareView.bounds.size.width,
                                     shareView.bounds.size.height);
        [_sharedWithHeader addSubview:shareView];
        
        NSString *shareText = NSLocalizedString(@"You can only share Skylock with your Facebook friends", nil);
        CGSize shareSize = [shareText sizeWithFont:kSLSharingVCInfoFont
                                           maxSize:CGSizeMake(_sharedWithHeader.bounds.size.width - shareView.bounds.size.width - 2*kSLSharingVCXPadding - 3.0f, CGFLOAT_MAX)];
        UILabel *shareInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shareView.frame) + 3.0f,
                                                                            shareView.frame.origin.y,
                                                                            shareSize.width,
                                                                            shareSize.height)];
        shareInfoLabel.font = kSLSharingVCInfoFont;
        shareInfoLabel.text = shareText;
        shareInfoLabel.textColor = kSLSharingVCInfoColor;
        shareInfoLabel.numberOfLines = 0;
        [_sharedWithHeader addSubview:shareInfoLabel];
    }
    
    return _sharedWithHeader;
}

- (UIView *)inviteFriendsHeader
{
    if (!_inviteFriendsHeader) {
        _inviteFriendsHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                        00.0f,
                                                                        self.tableView.bounds.size.width,
                                                                        [self tableView:self.tableView heightForHeaderInSection:1])];
        
        NSString *headerText = NSLocalizedString(@"Invite friends...", nil);
        CGSize headerSize = [headerText sizeWithFont:kSLSharingVCHeaderFont
                                             maxSize:CGSizeMake(_sharedWithHeader.bounds.size.width - 2*kSLSharingVCXPadding, CGFLOAT_MAX)];
        UILabel *sharedHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSLSharingVCXPadding,
                                                                               25.0f,
                                                                               headerSize.width,
                                                                               headerSize.height)];
        sharedHeaderLabel.font = kSLSharingVCHeaderFont;
        sharedHeaderLabel.text = headerText;
        sharedHeaderLabel.textColor = kSLSharingVCHeaderColor;
        [_inviteFriendsHeader addSubview:sharedHeaderLabel];
    }
    
    return _inviteFriendsHeader;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:110 green:223 blue:158];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Sharing", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_chevron_left_white"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];

    self.sharedContacts = [SLDatabaseManager.manager sharedContactsForLock:self.lock];
    
    [self.tableView reloadData];
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview delegate and datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.sharedContacts.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SLSharingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SLSharingTableViewCell class])];
        
        SLContact *contact = self.sharedContacts[indexPath.row];
        [cell setPropertiesWithContact:contact];
        
        return cell;
    } else {
        static NSString *inviteFriendsCellId = @"inviteFriendsCellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteFriendsCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:inviteFriendsCellId];
        }
        
        cell.textLabel.font = kSLSharingVCInfoFont;
        cell.textLabel.textColor = kSLSharingVCInfoColor;
        cell.textLabel.text = NSLocalizedString(@"Add friend", nil);
        cell.imageView.image = [UIImage imageNamed:@"icon_share"];
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 65.0f : 45.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return self.sharedWithHeader;
    } else {
        return self.inviteFriendsHeader;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSLog(@"first section selected");
    } else if (indexPath.section == 1) {
        SLAddContactViewController *acvc = [SLAddContactViewController new];
        [self.navigationController pushViewController:acvc animated:YES];
    }
}
@end
