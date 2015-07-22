//
//  SLAccountInfoFieldView.h
//  Skylock
//
//  Created by Andre Green on 7/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLAccountInfoFieldView;

@protocol SLAccountInfoFieldViewDelegate <NSObject>

- (void)accountInfoFieldViewButtonPushed:(SLAccountInfoFieldView *)view;

@end

@interface SLAccountInfoFieldView : UIView

@property (nonatomic, strong) UITextField *infoField;
@property (nonatomic, weak) id <SLAccountInfoFieldViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame headerString:(NSString *)headerString infoString:(NSString *)infoString buttonString:(NSString *)buttonString showSecure:(BOOL)showSecure;

@end
