//
//  SLEditLockTableViewCell.h
//  Skylock
//
//  Created by Andre Green on 7/23/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLEditLockTableViewCell;

@protocol SLEditLockTableViewCellDelegate <NSObject>

- (void)editLockCellRenamePushed:(SLEditLockTableViewCell *)cell;
- (void)editLockCellRemovePushed:(SLEditLockTableViewCell *)cell;
- (void)editLockCellLongPressActivated:(SLEditLockTableViewCell *)cell;

@end


@interface SLEditLockTableViewCell : UITableViewCell

@property (nonatomic, weak) id <SLEditLockTableViewCellDelegate> delegate;

@end
