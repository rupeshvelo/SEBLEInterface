//
//  SLSharingViewController.m
//  Skylock
//
//  Created by Andre Green on 6/27/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSharingViewController.h"
#import "SLContact.h"


@interface SLSharingViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *sharedContacts;

@end

@implementation SLSharingViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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

#pragma mark - tableview delegate and datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.sharedContacts.count;
    } else {
        return self.allContacts.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    return cell;
}

@end
