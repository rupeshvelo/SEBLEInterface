//
//  SLAddContactViewController.m
//  Skylock
//
//  Created by Andre Green on 9/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLAddContactViewController.h"
#import "SLContact.h"
#import "SLSharingContactTableViewCell.h"


#define kSLSharingContactTableViewCellId    @"kSLSharingContactTableViewCellId"
@interface SLAddContactViewController()

@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) UIView *lockView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation SLAddContactViewController

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

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        CGFloat y0 = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f,
                                                                   y0,
                                                                   self.view.bounds.size.width,
                                                                   45.0f)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"Invite Friends", nil);
        [_searchBar setShowsCancelButton:YES animated:YES];
        _searchBar.showsBookmarkButton = NO;
        _searchBar.barTintColor = [UIColor whiteColor];
        [self.view addSubview:_searchBar];
    }
    
    return _searchBar;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat height = self.view.bounds.size.height - CGRectGetMaxY(self.searchBar.frame) - self.keyboardHeight;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   CGRectGetMaxY(self.searchBar.frame),
                                                                   self.view.bounds.size.width,
                                                                   height)
                                                  style:UITableViewStylePlain];
        [_tableView registerClass:[SLSharingContactTableViewCell class]
           forCellReuseIdentifier:kSLSharingContactTableViewCellId];
        _tableView.rowHeight = 55.0f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self checkAddressBookStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if (info[UIKeyboardFrameEndUserInfoKey]) {
        NSValue *keyboardFrameValue = info[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = keyboardFrameValue.CGRectValue;
        self.keyboardHeight = keyboardFrame.size.height;
        [self.view addSubview:self.tableView];
    }
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
            
            NSData  *imageData = (__bridge NSData *)ABPersonCopyImageData(person);
            
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
                                                         phoneNumber:phoneNumber
                                                           imageData:imageData];
                [allContactsArray addObject:contact];
            }
            
            [allContactsArray sortUsingComparator:^NSComparisonResult(SLContact *contact1, SLContact *contact2) {
                return [contact1.firstName compare:contact2.firstName options:NSCaseInsensitiveSearch];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allContacts = [NSArray arrayWithArray:allContactsArray];
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
        }];
    } else{
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (granted){
                [self fillAllContactsWithCompletion:^{
                    [self unlock];
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

#pragma mark - UITableView delegate and datasource methods
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
    SLContact *contact = self.contacts[indexPath.row];
    SLSharingContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSLSharingContactTableViewCellId];
    [cell setPropertiesWithContact:contact];
    
    return cell;
}

#pragma mark - UISearchbar delegate methods
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"search text: %@", searchText);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName BEGINSWITH[c] %@", searchText];
    NSArray *results = [self.allContacts filteredArrayUsingPredicate:predicate];
    self.contacts = results;
    [self.tableView reloadData];
}

@end
