//
//  SLSharingContactTableViewCell.m
//  Skylock
//
//  Created by Andre Green on 9/5/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSharingContactTableViewCell.h"
#import "SLContact.h"
#import "UIColor+RGB.h"

@interface SLSharingContactTableViewCell()

@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIView *dividerView;
@end

@implementation SLSharingContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        self.textLabel.textColor = [UIColor colorWithRed:97 green:100 blue:100];
    }
    
    return self;
}

- (UIButton *)phoneButton
{
    if (!_phoneButton) {
        UIImage *image = [UIImage imageNamed:@"icon_lock"];
        _phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        [_phoneButton setImage:image forState:UIControlStateNormal];
        [_phoneButton addTarget:self action:@selector(phoneButtonPressed)
               forControlEvents:UIControlEventTouchDown];
    }
    
    return _phoneButton;
}

- (UIButton *)emailButton
{
    if (!_emailButton) {
        UIImage *image = [UIImage imageNamed:@"icon_help"];
        _emailButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  image.size.width,
                                                                  image.size.height)];
        [_emailButton setImage:image forState:UIControlStateNormal];
        [_emailButton addTarget:self action:@selector(emailButtonPressed)
               forControlEvents:UIControlEventTouchDown];
    }
    
    return _emailButton;
}

- (UIView *)dividerView
{
    if (!_dividerView) {
        _dividerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                0.5f,
                                                                self.bounds.size.height - 10.0f)];
        _dividerView.backgroundColor = [UIColor colorWithRed:146 green:148 blue:151];
    }
    
    return _dividerView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    static CGFloat xPadding = 10.0f;
    static CGFloat xDividerSpacing = 10.0f;
    
    self.emailButton.frame = CGRectMake(self.contentView.bounds.size.width - xPadding - self.emailButton.bounds.size.width,
                                        CGRectGetMidY(self.contentView.frame) - .5f*self.emailButton.bounds.size.height,
                                        self.emailButton.bounds.size.width,
                                        self.emailButton.bounds.size.height);
    
    [self.contentView addSubview:self.emailButton];
    
    self.dividerView.frame = CGRectMake(self.emailButton.frame.origin.x - xDividerSpacing - self.dividerView.bounds.size.width,
                                        CGRectGetMidY(self.contentView.frame) - .5*self.dividerView.bounds.size.height,
                                        self.dividerView.bounds.size.width,
                                        self.dividerView.bounds.size.height);
    
    [self.contentView addSubview:self.dividerView];
    
    self.phoneButton.frame = CGRectMake(self.dividerView.frame.origin.x - xDividerSpacing - self.phoneButton.bounds.size.width,
                                        CGRectGetMidY(self.contentView.frame) - .5f*self.phoneButton.bounds.size.height,
                                        self.phoneButton.bounds.size.width,
                                        self.phoneButton.bounds.size.height);
    
    [self.contentView addSubview:self.phoneButton];
}

- (void)setPropertiesWithContact:(SLContact *)contact
{
    UIImage *image;
    if (contact.imageData) {
        UIImage *currentImage = [UIImage imageWithData:contact.imageData];
        image = [self resizedImage:currentImage];
    } else {
        image = [UIImage imageNamed:@"img_userav_small"];
    }
    
    self.textLabel.text = contact.fullName;
    self.imageView.image = image;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = .5f*self.imageView.bounds.size.width;
}

- (void)phoneButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(sharingContactCellPhoneButtonPushed:)]) {
        [self.delegate sharingContactCellPhoneButtonPushed:self];
    }
}

- (void)emailButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(sharingContactCellEmailButtonPushed:)]) {
        [self.delegate sharingContactCellEmailButtonPushed:self];
    }
}

- (UIImage *)resizedImage:(UIImage *)image
{
    UIImage *defaultImage = [UIImage imageNamed:@"img_userav_small"];
    UIGraphicsBeginImageContext(defaultImage.size);
    [image drawInRect:CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
