//
//  SLTutorialViewController.m
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLTutorialViewController.h"


@interface SLTutorialViewController ()



@end

@implementation SLTutorialViewController

- (UIImageView *)picView
{
    if (!_picView) {
        UIImage *image = [UIImage imageNamed:self.imageName];
        _picView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 270.0f,
                                                                 176.0f)];
        _picView.image = image;
        [self.view addSubview:_picView];
    }
    
    return _picView;
}

- (UILabel *)mainInfoLabel
{
    if (!_mainInfoLabel) {
        _mainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width - 2*self.padding,
                                                                   kSLTutorialVCLabelHeightScaler*self.view.bounds.size.height)];
        _mainInfoLabel.text = self.mainText;
        _mainInfoLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _mainInfoLabel.textColor = [UIColor colorWithRed:97.0f/255.0f
                                                   green:97.0f/255.0f
                                                    blue:97.0f/255.0f
                                                   alpha:1.0f];
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
        _detailInfoLabel.textColor = [UIColor colorWithRed:146.0f/255.0f
                                                     green:148.0f/255.0f
                                                      blue:151.0f/255.0f
                                                     alpha:1.0f];
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
    
    self.picView.frame = CGRectMake(self.padding,
                                    self.padding,
                                    self.picView.bounds.size.width,
                                    self.picView.bounds.size.height);
    
    self.mainInfoLabel.frame = CGRectMake(self.padding,
                                          CGRectGetMaxY(self.picView.frame) + 40.0f,
                                          self.mainInfoLabel.frame.size.width,
                                          self.mainInfoLabel.frame.size.height);
    
    self.iconView.frame = CGRectMake(.5*(self.view.bounds.size.width - self.iconView.bounds.size.width),
                                     CGRectGetMaxY(self.mainInfoLabel.frame) + 30.0f,
                                     self.iconView.frame.size.width,
                                     self.iconView.frame.size.height);
    
    self.detailInfoLabel.frame = CGRectMake(self.padding,
                                            CGRectGetMaxY(self.mainInfoLabel.frame) + 80.0f,
                                            self.detailInfoLabel.bounds.size.width,
                                            self.detailInfoLabel.bounds.size.height);
}

@end
