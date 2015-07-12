//
//  SLTutorial1ViewController.m
//  Skylock
//
//  Created by Andre Green on 7/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLTutorial1ViewController.h"

#define kSLTutorial1VCInfoFont [UIFont fontWithName:@"HelveticaNeue" size:13.0f]

@interface SLTutorial1ViewController ()

@property (nonatomic, strong) UILabel *orderInfoLabel;
@property (nonatomic, strong) UILabel *orderLabel;
@end

@implementation SLTutorial1ViewController

- (UILabel *)orderInfoLabel
{
    if (!_orderInfoLabel) {
        _orderInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                    0.0f,
                                                                    .5*(self.view.bounds.size.width - 2*self.padding),
                                                                    20.0f)];
        _orderInfoLabel.text = self.orderInfoText;
        _orderInfoLabel.font = kSLTutorial1VCInfoFont;
        _orderInfoLabel.textColor = [UIColor colorWithRed:146.0f/255.0f
                                                    green:148.0f/255.0f
                                                     blue:151.0f/255.0f
                                                    alpha:1.0f];
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
        
        _orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                0.0f,
                                                                self.orderInfoLabel.bounds.size.width,
                                                                self.orderInfoLabel.bounds.size.height)];
        _orderLabel.text = self.orderText;
        _orderLabel.font = kSLTutorial1VCInfoFont;
        _orderLabel.textColor = [UIColor blueColor];
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
    
    self.orderLabel.frame = CGRectMake(CGRectGetMaxX(self.orderInfoLabel.frame),
                                       self.orderInfoLabel.frame.origin.y,
                                       self.orderLabel.frame.size.width,
                                       self.orderLabel.frame.size.height);
}

- (void)infoLabelTouched
{
    NSLog(@"info label touched");
}

@end
