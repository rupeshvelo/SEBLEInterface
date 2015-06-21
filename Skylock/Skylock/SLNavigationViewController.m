//
//  SLNavigationViewController.m
//  Skylock
//
//  Created by Andre Green on 6/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLNavigationViewController.h"
#import "SLConstants.h"

@interface SLNavigationViewController ()

@end

@implementation SLNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = SLConstantsMainTeal;
    self.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *barOptions = @{NSForegroundColorAttributeName:SLConstantsNavControllerTitleColor,
                                 NSFontAttributeName:SLConstantsNavControllerFont
                                 };
    
    self.navigationBar.titleTextAttributes = barOptions;
    self.navigationItem.rightBarButtonItem = self.leftBarButton;
}

- (UIBarButtonItem *)leftBarButton
{
//    UIImage *arrowImage = [UIImage imageNamed:@"left-back-arrow-button"];
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:arrowImage
//                                                                  style:UIBarButtonItemStylePlain
//                                                                 target:self
//                                                                 action:@selector(leftBarButtonPressed)];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Lock"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(leftBarButtonPressed)];
    barButton.tintColor = [UIColor redColor];
    return barButton;
}

- (UIView *)leftBarView
{
    UIImage *arrowImage = [UIImage imageNamed:@"left-back-arrow-button"];
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImage];

    UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               0.0f,
                                                               .25*self.view.bounds.size.width,
                                                               arrowImage.size.height)];
    
    static CGFloat spacer = 5.0f;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(arrowImage.size.width + spacer,
                                                                    0.0f,
                                                                    barView.bounds.size.width - arrowImage.size.width - spacer,
                                                                    barView.bounds.size.height)];
    titleLabel.textColor = SLConstantsNavControllerTitleColor;
    titleLabel.text = NSLocalizedString(@"Lock", nil);
    
    [barView addSubview:arrowView];
    [barView addSubview:titleLabel];
    
    return barView;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)leftBarButtonPressed
{
    
}

@end
