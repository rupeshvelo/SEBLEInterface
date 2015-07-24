//
//  SLEditLockTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 7/23/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLEditLockTableViewCell.h"
#import "SLSlideControllerOptionsButton.h"
#import "UIColor+RGB.h"

#define kSLEditLockTableCellFont        [UIFont fontWithName:@"HelveticaNeue-Light" size:9]
#define kSLEditLockTableCellTitleColor  [UIColor colorWithRed:97 green:100 blue:100]


@interface SLEditLockTableViewCell()

@property (nonatomic, strong) SLSlideControllerOptionsButton *renameButton;
@property (nonatomic, strong) SLSlideControllerOptionsButton *removeButton;
@property (nonatomic, strong) UIView *verticalSeperator;

@end

@implementation SLEditLockTableViewCell

- (UIView *)verticalSeperator
{
    if (!_verticalSeperator) {
        _verticalSeperator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      0.0f,
                                                                      1.0f,
                                                                      self.bounds.size.height)];
        _verticalSeperator.backgroundColor = [UIColor colorWithRed:191 green:191 blue:191];
        [self.contentView addSubview:_verticalSeperator];
    }
    
    return _verticalSeperator;
}

- (SLSlideControllerOptionsButton *)renameButton
{
    if (!_renameButton) {
        NSString *title = NSLocalizedString(@"Rename", nil);
        NSString *imageName = @"icon_rename";
        
        _renameButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         0.0f,
                                                                                         .5*(self.bounds.size.width - self.verticalSeperator.bounds.size.width),
                                                                                         self.bounds.size.height)
                                                                        title:title
                                                                    imageName:imageName
                                                                         font:kSLEditLockTableCellFont
                                                                   titleColor:kSLEditLockTableCellTitleColor];
        [_renameButton addTarget:self
                          action:@selector(renameButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:_renameButton];
    }
    
    return _renameButton;
}

- (SLSlideControllerOptionsButton *)removeButton
{
    if (!_removeButton) {
        NSString *title = NSLocalizedString(@"Remove", nil);
        NSString *imageName = @"icon_remove";
        
        _removeButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         0.0f,
                                                                                         .5*(self.bounds.size.width - self.verticalSeperator.bounds.size.width),
                                                                                         self.bounds.size.height)
                                                                        title:title
                                                                    imageName:imageName
                                                                         font:kSLEditLockTableCellFont
                                                                   titleColor:kSLEditLockTableCellTitleColor];
        [_removeButton addTarget:self
                          action:@selector(removeButtonPressed)
                forControlEvents:UIControlEventTouchDown];
        [self.contentView addSubview:_removeButton];
    }
    
    return _removeButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.renameButton.frame = CGRectMake(0.0f,
                                         0.0f,
                                         self.renameButton.bounds.size.width,
                                         self.renameButton.bounds.size.height);
    
    self.verticalSeperator.frame = CGRectMake(CGRectGetMaxX(self.renameButton.frame),
                                              0.0f,
                                              self.verticalSeperator.bounds.size.width,
                                              self.verticalSeperator.bounds.size.height);
    
    self.removeButton.frame = CGRectMake(CGRectGetMaxX(self.verticalSeperator.frame),
                                         0.0f,
                                         self.removeButton.bounds.size.width,
                                         self.removeButton.bounds.size.height);
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)renameButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(editLockCellRenamePushed:)]) {
        [self.delegate editLockCellRenamePushed:self];
    }
}

- (void)removeButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(editLockCellRemovePushed:)]) {
        [self.delegate editLockCellRemovePushed:self];
    }
}

@end
