//
//  SLAccountInfoFieldView.h
//  Skylock
//
//  Created by Andre Green on 7/21/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLAccountInfoFieldView;


@interface SLAccountInfoFieldView : UIView


@property (nonatomic, copy) void (^buttonPressedBlock)();

- (id)initWithFrame:(CGRect)frame headerString:(NSString *)headerString infoString:(NSString *)infoString buttonString:(NSString *)buttonString showSecure:(BOOL)showSecure;

- (void)setButtonEnabled:(BOOL)shouldSetEnabled;

- (void)changeLabelText:(NSString *)text;

@end
