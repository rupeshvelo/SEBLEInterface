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

@interface SLLockTableViewCell()

@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation SLLockTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}

- (UIImageView *)rightImageView
{
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharebike-icon"]];
        [self.contentView addSubview:_rightImageView];
    }
    
    return _rightImageView;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.rightImageView.image = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.rightImageView.frame = CGRectMake(self.contentView.bounds.size.width - self.rightImageView.bounds.size.width - 10.0f,
                                           .5*(self.contentView.bounds.size.height - self.rightImageView.bounds.size.height),
                                           self.rightImageView.bounds.size.width,
                                           self.rightImageView.bounds.size.height);
    
    
    CGSize imageViewSize = self.imageViewSize;
//    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
//                                      self.imageView.frame.origin.y,
//                                      imageViewSize.width,
//                                      imageViewSize.height);
    
    
    self.textLabel.frame = CGRectMake(imageViewSize.width + 20.0f,
                                      self.textLabel.frame.origin.y,
                                      self.textLabel.frame.size.width,
                                      self.textLabel.frame.size.height);
    
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x,
                                            self.detailTextLabel.frame.origin.y,
                                            self.detailTextLabel.frame.size.width,
                                            self.textLabel.frame.size.height);
}

- (void)updateCellWithLock:(SLLock *)lock
{
    self.textLabel.text = lock.name;
    self.detailTextLabel.text = [[NSString alloc] stringWithDistance:lock.distanceAway];
    self.imageView.image = lock.isLocked.boolValue ? [UIImage imageNamed:@"lock-icon"] : self.placeHolderImage;
    self.rightImageView.image = lock.isSharingOn.boolValue ? [UIImage imageNamed:@"sharebike-icon"] : nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)imageViewSize
{
    UIImage *image = [UIImage imageNamed:@"sharebike-icon"];
    return image.size;
}

- (UIImage *)placeHolderImage
{
    CGSize imageSize = self.imageViewSize;
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *holderImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return holderImage;
}

@end
