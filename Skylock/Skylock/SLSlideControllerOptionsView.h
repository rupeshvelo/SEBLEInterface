//
//  SLSlideControllerOptionsView.h
//  Skylock
//
//  Created by Andre Green on 7/16/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSlideControllerOptionsView;

typedef NS_ENUM(NSUInteger, SLSlideOptionsViewAction) {
    SLSlideOptionsViewActionNone,
    SLSlideOptionsViewActionAddLock,
    SLSlideOptionsViewActionStore,
    SLSlideOptionsViewActionSettings,
    SLSlideOptionsViewActionHelp
};

@protocol SLSlideControllerOptionsViewDelegate <NSObject>

- (void)slideOptionsView:(SLSlideControllerOptionsView *)optionsView
                  action:(SLSlideOptionsViewAction)action;


@end

@interface SLSlideControllerOptionsView : UIView

@property (nonatomic, weak) id <SLSlideControllerOptionsViewDelegate> delegate;
@end
