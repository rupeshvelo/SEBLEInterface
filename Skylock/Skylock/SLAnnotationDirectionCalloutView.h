//
//  SLAnnotationDirectionCalloutView.h
//  Skylock
//
//  Created by Andre Green on 9/10/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLAnnotationDirectionCalloutView;

@protocol SLAnnotationDirectionCalloutViewDelegate <NSObject>

- (void)annotationDirection:(SLAnnotationDirectionCalloutView *)calloutView leftButtonIsSelected:(BOOL)isSelected;

- (void)annotationDirection:(SLAnnotationDirectionCalloutView *)calloutView rightButtonIsSelected:(BOOL)isSelected;

@end


@interface SLAnnotationDirectionCalloutView : UIView

@property (nonatomic, weak) id <SLAnnotationDirectionCalloutViewDelegate> delegate;

@end
