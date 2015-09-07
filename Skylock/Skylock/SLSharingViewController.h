//
//  SLSharingViewController.h
//  Skylock
//
//  Created by Andre Green on 6/27/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLLock;

@interface SLSharingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SLLock *lock;

@end
