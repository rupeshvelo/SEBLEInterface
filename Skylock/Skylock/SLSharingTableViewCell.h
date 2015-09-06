//
//  SLSharingTableViewCell.h
//  Skylock
//
//  Created by Andre Green on 8/7/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLContact;

@interface SLSharingTableViewCell : UITableViewCell

- (void)setPropertiesWithContact:(SLContact *)contact;

@end
