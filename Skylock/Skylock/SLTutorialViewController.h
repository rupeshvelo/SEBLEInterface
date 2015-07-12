//
//  SLTutorialViewController.h
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSLTutorialVCLabelHeightScaler .075

@interface SLTutorialViewController : UIViewController

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *mainText;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UILabel *mainInfoLabel;
@property (nonatomic, strong) UILabel *detailInfoLabel;
@property (nonatomic, strong) UIImageView *iconView;
@end
