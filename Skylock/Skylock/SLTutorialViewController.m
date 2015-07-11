//
//  SLTutorialViewController.m
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLTutorialViewController.h"

@interface SLTutorialViewController ()

@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UILabel *mainInfoLabel;
@property (nonatomic, strong) UILabel *detailInfoLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation SLTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

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
        _mainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.view.bounds.size.width,
                                                                   .1*self.view.bounds.size.height)];
        [self.view addSubview:_mainInfoLabel];
    }
    
    return _mainInfoLabel;
}

- (UILabel *)detailInfoLabel
{
    
}

@end
