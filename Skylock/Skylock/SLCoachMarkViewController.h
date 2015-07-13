//
//  SLCoachMarkViewController.h
//  Skylock
//
//  Created by Andre Green on 7/12/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLCoachMarkViewController;

typedef NS_ENUM(NSUInteger, SLCoachMarkPage) {
    SLCoachMarkPageCrash,
    SLCoachMarkPageTheft,
    SLCoachMarkPageSharing
};

@protocol SLCoachMarkViewControllerDelegate <NSObject>

- (void)coachMarkViewControllerDoneButtonPressed:(SLCoachMarkViewController *)cmvc;

@end


@interface SLCoachMarkViewController : UIViewController

@property (nonatomic, strong) NSDictionary *buttonPositions;
@property (nonatomic, weak) id <SLCoachMarkViewControllerDelegate>delegate;

@end
