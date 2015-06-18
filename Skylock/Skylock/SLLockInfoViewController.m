//
//  SLLockInfoViewController.m
//  Skylock
//
//  Created by Andre Green on 6/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockInfoViewController.h"
#import "SLLockInfoViewHeader.h"
#import "SLLock.h"

@interface SLLockInfoViewController()

@property (nonatomic, strong) SLLockInfoViewHeader *header;

@end
@implementation SLLockInfoViewController

- (void)viewDidLoad
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // add lock for testing
    SLLock *lock = [[SLLock alloc] initWithName:@"Bad Ass Lock"
                               batteryRemaining:@(46.7)
                                   wifiStrength:@(56.8)
                                   cellStrength:@(87.98)
                                       lastTime:@(354)
                                   distanceAway:@(12765)
                                       isLocked:@(YES)
                                         lockId:@"bkdidlldie830387jdod9"];
    
    // add header temporarily
    self.header = [[SLLockInfoViewHeader alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 50.0f)
                                                      andLock:lock];
    self.header.delegate = self;
    [self.view addSubview:self.header];
}

#pragma mark - SLLockInfoViewHeaderDelegate Methods
- (void)lockInfoViewHeaderSettingButtonPressed:(SLLockInfoViewHeader *)headerView
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}


@end
