//
//  SLLockTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLLockTableViewCell.h"
#import "SLLock.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"

@interface SLLockTableViewCell()


@end

@implementation SLLockTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"icon_chevron_right"];
        self.accessoryView = [[UIImageView alloc] initWithImage:image];
        
        [self setNormalLabelFont];
        
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
        self.detailTextLabel.textColor = [UIColor colorWithRed:191 green:191 blue:191];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:lpgr];
    }
    
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)setNormalLabelFont
{
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
}

- (void)updateCellWithLock:(SLLock *)lock
{
    self.textLabel.text = lock.displayName;
    self.detailTextLabel.text = [[NSString alloc] stringWithDistance:lock.distanceAway];
    
    if (lock.isCurrentLock.boolValue) {
        [self setSelectedLabelFont];
    } else {
        [self setNormalLabelFont];
    }
}

- (void)setSelectedLabelFont
{
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    self.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)lpgr
{
    if ([self.delegate respondsToSelector:@selector(lockTableViewCellLongPressOccured:)] &&
        lpgr.state == UIGestureRecognizerStateBegan) {
        [self.delegate lockTableViewCellLongPressOccured:self];
    }
}

@end
