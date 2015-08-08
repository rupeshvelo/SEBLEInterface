//
//  SLTutorial1ViewController.m
//  Skylock
//
//  Created by Andre Green on 7/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLTutorial1ViewController.h"
#import "NSString+Skylock.h"
#import "UIColor+RGB.h"

#define kSLTutorial1VCInfoFont [UIFont fontWithName:@"HelveticaNeue" size:13.0f]

@interface SLTutorial1ViewController ()

@property (nonatomic, strong) UILabel *orderInfoLabel;
@property (nonatomic, strong) UILabel *orderLabel;
@end

@implementation SLTutorial1ViewController

- (UILabel *)orderInfoLabel
{
    if (!_orderInfoLabel) {
        CGSize size = [self.orderInfoText sizeWithFont:kSLTutorial1VCInfoFont
                                               maxSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
        _orderInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    size.width,
                                                                    size.height)];
        _orderInfoLabel.text = self.orderInfoText;
        _orderInfoLabel.font = kSLTutorial1VCInfoFont;
        _orderInfoLabel.textColor = [UIColor colorWithRed:146 green:148 blue:151];
        _orderInfoLabel.numberOfLines = 1;
        [self.view addSubview:_orderInfoLabel];
    }
    
    return _orderInfoLabel;
}

- (UILabel *)orderLabel
{
    if (!_orderLabel) {
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(infoLabelTouched)];
        tgr.numberOfTapsRequired = 1;
        CGSize size = [self.orderText sizeWithFont:kSLTutorial1VCInfoFont
                                               maxSize:CGSizeMake(self.view.bounds.size.width, CGFLOAT_MAX)];
        _orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                size.width,
                                                                size.height)];
        _orderLabel.text = self.orderText;
        _orderLabel.font = kSLTutorial1VCInfoFont;
        _orderLabel.textColor = [UIColor colorWithRed:43 green:132 blue:210];
        _orderLabel.numberOfLines = 1;
        _orderLabel.userInteractionEnabled = YES;
        [_orderLabel addGestureRecognizer:tgr];
        [self.view addSubview:_orderLabel];
    }
    
    return _orderLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.orderInfoLabel.frame = CGRectMake(self.padding,
                                           CGRectGetMaxY(self.mainInfoLabel.frame),
                                           self.orderInfoLabel.bounds.size.width,
                                           self.orderInfoLabel.bounds.size.height);
    
    self.orderLabel.frame = CGRectMake(CGRectGetMaxX(self.orderInfoLabel.frame) + 3.0f,
                                       self.orderInfoLabel.frame.origin.y,
                                       self.orderLabel.frame.size.width,
                                       self.orderLabel.frame.size.height);
}

- (void)infoLabelTouched
{
    NSLog(@"info label touched");
}

@end
