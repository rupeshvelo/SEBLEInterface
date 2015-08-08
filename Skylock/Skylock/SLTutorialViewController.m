//
//  SLTutorialViewController.m
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLTutorialViewController.h"
#import "UIColor+RGB.h"
#import "NSString+Skylock.h"

@interface SLTutorialViewController ()



@end

@implementation SLTutorialViewController

- (UIImageView *)picView
{
    if (!_picView) {
        UIImage *image = [UIImage imageNamed:self.imageName];
        _picView = [[UIImageView alloc] initWithImage:image];

        [self.view addSubview:_picView];
    }
    
    return _picView;
}

- (UILabel *)mainInfoLabel
{
    if (!_mainInfoLabel) {
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        CGSize size = [self.mainText sizeWithFont:font
                                          maxSize:CGSizeMake(self.view.bounds.size.width - 2*self.padding, CGFLOAT_MAX)];
        _mainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   size.width,
                                                                   size.height)];
        _mainInfoLabel.text = self.mainText;
        _mainInfoLabel.font = font;
        _mainInfoLabel.textColor = [UIColor colorWithRed:97 green:97 blue:97];
        _mainInfoLabel.numberOfLines = 0;
        [self.view addSubview:_mainInfoLabel];
    }
    
    return _mainInfoLabel;
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:self.iconName];
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  36.0f,
                                                                  36.0f)];
        _iconView.image = image;
        [self.view addSubview:_iconView];
    }
    
    return _iconView;
}

- (UILabel *)detailInfoLabel
{
    if (!_detailInfoLabel) {
        _detailInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     self.view.bounds.size.width - 2*self.padding,
                                                                     kSLTutorialVCLabelHeightScaler*self.view.bounds.size.height)];
        _detailInfoLabel.text = self.detailText;
        _detailInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        _detailInfoLabel.textColor = [UIColor colorWithRed:146 green:148 blue:151];
        _detailInfoLabel.numberOfLines = 0;
        [self.view addSubview:_detailInfoLabel];
    }
    
    return _detailInfoLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.picView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.picView.bounds.size.width),
                                    self.padding,
                                    self.picView.bounds.size.width,
                                    self.picView.bounds.size.height);
    
    CGFloat mainInfoY0 = self.iconView.image ? 40.0f : 97.0f;
    CGFloat detailInfoY0 = self.iconView.image ? 80.0f : 18.0f;
    
    self.mainInfoLabel.frame = CGRectMake(self.padding,
                                          CGRectGetMaxY(self.picView.frame) + mainInfoY0,
                                          self.mainInfoLabel.frame.size.width,
                                          self.mainInfoLabel.frame.size.height);
    
    self.iconView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.iconView.bounds.size.width),
                                     CGRectGetMaxY(self.mainInfoLabel.frame) + 30.0f,
                                     self.iconView.frame.size.width,
                                     self.iconView.frame.size.height);
    
    
    
    
    self.detailInfoLabel.frame = CGRectMake(self.padding,
                                            CGRectGetMaxY(self.mainInfoLabel.frame) + detailInfoY0,
                                            self.detailInfoLabel.bounds.size.width,
                                            self.detailInfoLabel.bounds.size.height);
}

@end
