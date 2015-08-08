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

@property (nonatomic, strong) SLSlideControllerOptionsButton *shareButton;
@property (nonatomic, strong) SLSlideControllerOptionsButton *removeButton;
@property (nonatomic, strong) UIView *verticalSeperator;

@end

@implementation SLEditLockTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(longPressActivated:)];
        lpgr.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:lpgr];
    }
    
    return self;
}

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

- (SLSlideControllerOptionsButton *)shareButton
{
    if (!_shareButton) {
        NSString *title = NSLocalizedString(@"Share", nil);
        NSString *imageName = @"icon_share";
        
        _shareButton = [[SLSlideControllerOptionsButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         0.0f,
                                                                                         .5*(self.bounds.size.width - self.verticalSeperator.bounds.size.width),
                                                                                         self.bounds.size.height)
                                                                        title:title
                                                                    imageName:imageName
                                                                         font:kSLEditLockTableCellFont
                                                                   titleColor:kSLEditLockTableCellTitleColor];
        [_shareButton addTarget:self
                          action:@selector(shareButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_shareButton];
    }
    
    return _shareButton;
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
                forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_removeButton];
    }
    
    return _removeButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.shareButton.frame = CGRectMake(0.0f,
                                         0.0f,
                                         self.shareButton.bounds.size.width,
                                         self.shareButton.bounds.size.height);
    
    self.verticalSeperator.frame = CGRectMake(CGRectGetMaxX(self.shareButton.frame),
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

- (void)shareButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(editLockCellSharePushed:)]) {
        [self.delegate editLockCellSharePushed:self];
    }
}

- (void)removeButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(editLockCellRemovePushed:)]) {
        [self.delegate editLockCellRemovePushed:self];
    }
}

- (void)longPressActivated:(UILongPressGestureRecognizer *)lpgr
{
        if ([self.delegate respondsToSelector:@selector(editLockCellLongPressActivated:)] &&
            lpgr.state == UIGestureRecognizerStateBegan) {
            [self.delegate editLockCellLongPressActivated:self];
        }
}

@end
