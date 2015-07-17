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
        
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        self.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
        
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
        self.detailTextLabel.textColor = [UIColor colorWithRed:191 green:191 blue:191];
    }
    
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
}



- (void)updateCellWithLock:(SLLock *)lock
{
    self.textLabel.text = lock.name;
    self.detailTextLabel.text = [[NSString alloc] stringWithDistance:lock.distanceAway];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
