//
//  SLDirectionsTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDirectionsTableViewCell.h"
#import "Skylock-Swift.h"
#import "NSString+Skylock.h"    


@interface SLDirectionsTableViewCell()

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, assign) BOOL isFirst;

@end

@implementation SLDirectionsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        self.textLabel.textColor = [UIColor whiteColor];
        
        self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.numberOfLines = 2;
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat maxX = self.bounds.size.width - self.textLabel.frame.origin.y;
    CGSize maxSize = CGSizeMake(maxX, CGFLOAT_MAX);
    
    CGSize detailSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font maxSize:maxSize];
    
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x,
                                            CGRectGetMaxY(self.textLabel.frame) + 3.0f,
                                            detailSize.width,
                                            detailSize.height);
    
    if ([self.subviews containsObject:self.verticalLineView]) {
        [self.verticalLineView removeFromSuperview];
        self.verticalLineView = nil;
    }
    
    static CGFloat lineWidth = .5f;
    CGFloat lineHeightDiff = self.isFirst ? self.bounds.size.height - CGRectGetMinY(self.imageView.frame) : 0.0f;
    CGRect lineViewFrame = CGRectMake(CGRectGetMidX(self.imageView.frame) - lineWidth,
                                      lineHeightDiff,
                                      lineWidth,
                                      self.bounds.size.height - lineHeightDiff);
    
    self.verticalLineView = [[UIView alloc] initWithFrame:lineViewFrame];
    self.verticalLineView.backgroundColor = [UIColor whiteColor];
    [self insertSubview:self.verticalLineView belowSubview:self.imageView];
}

- (void)setPropertiesWithDirection:(SLDirection *)direction isFirstDirection:(BOOL)isFirst
{
    CGFloat distance = [direction distanceInMiles];
    self.textLabel.text = distance == CGFLOAT_MAX ? @"" : [NSString stringWithFormat:@"%.1fmi", distance];
    
    self.detailTextLabel.text = direction.directions;
    
    self.isFirst = isFirst;
    
    NSString *imageName = isFirst ? @"directions_first_cell_icon" : @"directions_dot_icon";
    self.imageView.image = [UIImage imageNamed:imageName];
}

@end
