//
//  SLBackButton.h
//  Skylock
//
//  Created by Andre Green on 6/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLBackButton;

@protocol SLBackButtonDelegate <NSObject>

- (void)backButtonPressed:(SLBackButton *)backButton;

@end
@interface SLBackButton : UIButton

@property (nonatomic, weak) id <SLBackButtonDelegate> delegate;

- (id)initWithTitle:(NSString *)title;

@end
