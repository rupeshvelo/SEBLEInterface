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

#define kSLSharingVCXPadding    25.0f
#define kSLSharingVCHeaderFont  [UIFont fontWithName:@"HelveticaNeue" size:13.0f]
#define kSLSharingVCInfoFont    [UIFont fontWithName:@"HelveticaNeue" size:10.0f]
#define kSLSharingVCHeaderColor [UIColor colorWithRed:97 green:100 blue:100]
#define kSLSharingVCInfoColor   [UIColor colorWithRed:146 green:148 blue:151]

@interface SLSharingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *sharedContacts;
@property (nonatomic, strong) UISwitch *sharingSwitch;
@property (nonatomic, strong) UIView *sharingInfoHeader;
@property (nonatomic, strong) UIView *lockView;

@end

@implementation SLSharingViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   CGRectGetMaxY(self.sharingInfoHeader.frame),
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - CGRectGetMaxY(self.sharingInfoHeader.frame))
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView registerClass:[SLSharingTableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([SLSharingTableViewCell class])];
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (NSMutableArray *)allContacts
{
    if (!_contacts) {
        _contacts = [NSMutableArray new];
    }
    
    return _contacts;
}

- (NSMutableArray *)sharedContacts
{
    if (!_sharedContacts) {
        _sharedContacts = [NSMutableArray new];
    }
    
    return _sharedContacts;
}

- (UIView *)lockView
{
    if (!_lockView) {
        _lockView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                             0.0f,
                                                             self.view.bounds.size.width,
                                                             self.view.bounds.size.height)];
        _lockView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9f];
    }
    
    return _lockView;
}

- (UIView *)sharingInfoHeader
{
    if (!_sharingInfoHeader) {
        _sharingInfoHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      self.view.bounds.size.width -
                                                                      2*kSLSharingVCXPadding,
                                                                      92.0f)];
        
        NSString *headerText = NSLocalizedString(@"Sharing", nil);
        CGSize headerSize = [headerText sizeWithFont:kSLSharingVCHeaderFont
                                             maxSize:CGSizeMake(.5*_sharingInfoHeader.bounds.size.width, CGFLOAT_MAX)];
        UILabel *sharingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                                15.0f,
                                                                                headerSize.width,
                                                                                headerSize.height)];
        sharingHeaderLabel.text = headerText;
        sharingHeaderLabel.font = kSLSharingVCHeaderFont;
        sharingHeaderLabel.textColor = kSLSharingVCHeaderColor;
        [_sharingInfoHeader addSubview:sharingHeaderLabel];
        
        UISwitch *sharingSwitch = [UISwitch new];
        sharingSwitch.frame = CGRectMake(_sharingInfoHeader.bounds.size.width - sharingSwitch.bounds.size.width,
                                         CGRectGetMidY(sharingHeaderLabel.frame) - .5*sharingSwitch.bounds.size.height,
                                         sharingSwitch.bounds.size.width,
                                         sharingSwitch.bounds.size.height);
        [sharingSwitch addTarget:self
                          action:@selector(sharingSwitchFlipped:)
                forControlEvents:UIControlEventValueChanged];
        [_sharingInfoHeader addSubview:sharingSwitch];
        
        NSString *infoText = NSLocalizedString(@"Friends from your share list have access to unlock your bike", nil);
        CGSize infoSize = [infoText sizeWithFont:kSLSharingVCInfoFont
                                         maxSize:CGSizeMake(_sharingInfoHeader.bounds.size.width, CGFLOAT_MAX)];
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                       _sharingInfoHeader.bounds.size.height - infoSize.height - 15.0f,
                                                                       infoSize.width,
                                                                       infoSize.height)];
        infoLabel.text = infoText;
        infoLabel.font = kSLSharingVCInfoFont;
        infoLabel.textColor = kSLSharingVCInfoColor;
        infoLabel.numberOfLines = 0;
        [_sharingInfoHeader addSubview:infoLabel];
        
        static CGFloat bottomLineHeight = 1.0f;
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      _sharingInfoHeader.bounds.size.height - bottomLineHeight,
                                                                      _sharingInfoHeader.bounds.size.width,
                                                                      bottomLineHeight)];
        bottomLine.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
        [_sharingInfoHeader addSubview:bottomLine];
        [self.view addSubview:_sharingInfoHeader];
    }
    
    return _sharingInfoHeader;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:110 green:223 blue:158];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = self.lock.name;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_chevron_left_white"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    [self checkAddressBookStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.sharingInfoHeader.frame = CGRectMake(kSLSharingVCXPadding,
                                              CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                              self.sharingInfoHeader.bounds.size.width,
                                              self.sharingInfoHeader.bounds.size.height);
    
    self.tableView.frame = CGRectMake(0.0f,
                                      CGRectGetMaxY(self.sharingInfoHeader.frame),
                                      self.tableView.bounds.size.width,
                                      self.tableView.bounds.size.height);
}

- (void)fillAllContactsWithCompletion:(void(^)(void))completionBlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    __block NSMutableArray *allContactsArray = [NSMutableArray new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (!addressBook) {
            return;
        }
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        for (int i = 0; i < allContacts.count; i++) {
            ABRecordRef person = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            /*
             NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
             contacts.image = [UIImage imageWithData:imgData];
             if (!contacts.image) {
             contacts.image = [UIImage imageNamed:@"NOIMG.png"];
             }
             */
            
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef numbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0; i < ABMultiValueGetCount(numbers); i++) {
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(numbers, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
            }
            
            NSString *phoneNumber = [phoneNumbers firstObject];
            
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
            }
            
            NSString *email = [contactEmails firstObject];
            if (firstName && phoneNumber) {
                SLContact *contact = [SLContact contactWithFirstName:firstName
                                                            lastName:lastName
                                                               email:email
                                                         phoneNumber:phoneNumber];
                [allContactsArray addObject:contact];
            }
            
            [allContactsArray sortUsingComparator:^NSComparisonResult(SLContact *contact1, SLContact *contact2) {
                return [contact1.firstName compare:contact2.firstName options:NSCaseInsensitiveSearch];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contacts = [NSMutableArray arrayWithArray:allContactsArray];
            if (completionBlock) {
                completionBlock();
            }
        });
    });
    
}

- (void)lockContacts
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view addSubview:self.lockView];
    });
}

- (void)unlock
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lockView removeFromSuperview];
    });
}

- (void)checkAddressBookStatus
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        [self lockContacts];
        [self presentAddressBookAccessDeniedAlertView];
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        [self unlock];
        [self fillAllContactsWithCompletion:^{
            [self unlock];
            NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationTop];

        }];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (granted){
                [self fillAllContactsWithCompletion:^{
                    [self unlock];
                    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
                    [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationTop];

                }];
            } else {
                [self lockContacts];
                [self presentAddressBookAccessDeniedAlertView];
            }
        });
    }
}

- (void)presentAddressBookAccessDeniedAlertView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = NSLocalizedString(@"To invite friends please go to your phone's settings and enable contacts under privacy", nil);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Banter! can't invite friends"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)sharingSwitchFlipped:(UISwitch *)sharingSwitch
{
    
}

- (void)backButtonPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableview delegate and datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLSharingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SLSharingTableViewCell class])];
    
    SLContact *contact = self.contacts[indexPath.row];
    cell.textLabel.text = contact.fullName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                              0.0f,
                                                              tableView.bounds.size.width,
                                                              [self tableView:tableView heightForHeaderInSection:section])];
    
    NSString *headerText = NSLocalizedString(@"Shared with...", nil);
    CGSize headerSize = [headerText sizeWithFont:kSLSharingVCHeaderFont
                                             maxSize:CGSizeMake(header.bounds.size.width - 2*kSLSharingVCXPadding, CGFLOAT_MAX)];
    UILabel *sharedHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSLSharingVCXPadding, 5.0f, headerSize.width, headerSize.height)];
    sharedHeaderLabel.font = kSLSharingVCHeaderFont;
    sharedHeaderLabel.text = headerText;
    sharedHeaderLabel.textColor = kSLSharingVCHeaderColor;
    [header addSubview:sharedHeaderLabel];
    
    UIImage *shareImage = [UIImage imageNamed:@"icon_share"];
    UIImageView *shareView = [[UIImageView alloc] initWithImage:shareImage];
    shareView.frame = CGRectMake(kSLSharingVCXPadding,
                                 CGRectGetMaxY(sharedHeaderLabel.frame) + 10.0f,
                                 shareView.bounds.size.width,
                                 shareView.bounds.size.height);
    [header addSubview:shareView];
    
    NSString *shareText = NSLocalizedString(@"You can only share Skylock with your Facebook friends", nil);
    CGSize shareSize = [shareText sizeWithFont:kSLSharingVCInfoFont
                                       maxSize:CGSizeMake(header.bounds.size.width - shareView.bounds.size.width - 2*kSLSharingVCXPadding, CGFLOAT_MAX)];
    UILabel *shareInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(shareView.frame),
                                                                        CGRectGetMaxY(shareView.frame) - shareSize.height,
                                                                        shareSize.width,
                                                                        shareSize.height)];
    shareInfoLabel.font = kSLSharingVCInfoFont;
    shareInfoLabel.text = shareText;
    shareInfoLabel.textColor = kSLSharingVCInfoColor;
    [header addSubview:shareInfoLabel];
    
    return header;
}
@end
