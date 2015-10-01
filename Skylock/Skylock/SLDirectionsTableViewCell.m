//
//  SLDirectionsTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDirectionsTableViewCell.h"
#import "Skylock-Swift.h"

@implementation SLDirectionsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        self.textLabel.textColor = [UIColor whiteColor];
        
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.numberOfLines = 0;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setPropertiesWithDirection:(SLDirection *)direction isFirstDirection:(BOOL)isFirst
{
    self.textLabel.text = [NSString stringWithFormat:@"%.1fkm", direction.distance/1000.0f];
    self.detailTextLabel.text = direction.directions;
    
    NSString *imageName = isFirst ? @"direction_pin_white" : @"directions_dot_white";
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
