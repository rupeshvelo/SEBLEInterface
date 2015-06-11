//
//  SLSlideViewController.m
//  Skylock
//
//  Created by Andre Green on 6/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLSlideViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SLSlideViewController()

@property (nonatomic, strong) UIButton *testButton;

@end

@implementation SLSlideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:.95f];
    
    self.testButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
    [self.testButton addTarget:self
                        action:@selector(testButtonPressed)
              forControlEvents:UIControlEventTouchDown];
    [self.testButton setBackgroundColor:[UIColor blueColor]];
    self.testButton.center = self.view.center;
    self.testButton.clipsToBounds = YES;
    self.testButton.layer.cornerRadius = .5*self.testButton.bounds.size.width;
    [self.view addSubview:self.testButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)testButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(slideViewController:buttonPushed:)]) {
        [self.delegate slideViewController:self buttonPushed:SLSlideViewControllerButtonActionExit];
    }
}

@end
