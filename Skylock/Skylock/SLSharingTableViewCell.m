//
//  SLSharingTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 8/7/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSharingTableViewCell.h"
#import "UIColor+RGB.h"

@implementation SLSharingTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        self.textLabel.textColor = [UIColor colorWithRed:146 green:148 blue:151];
        
        UIImage *icon = [UIImage imageNamed:@"icon_share"];
        self.accessoryView = [[UIImageView alloc] initWithImage:icon];
    }
    
    return self;
}
@end
