//
//  SLSharingContactTableViewCell.h
//  Skylock
//
//  Created by Andre Green on 9/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLContact;
@class SLSharingContactTableViewCell;

@protocol SLSharingContactTableViewCellDelegate <NSObject>

- (void)sharingContactCellPhoneButtonPushed:(SLSharingContactTableViewCell *)sharingContactCell;

- (void)sharingContactCellEmailButtonPushed:(SLSharingContactTableViewCell *)sharingContactCell;
@end

@interface SLSharingContactTableViewCell : UITableViewCell

@property (nonatomic, weak) id <SLSharingContactTableViewCellDelegate> delegate;

- (void)setPropertiesWithContact:(SLContact *)contact;


@end
