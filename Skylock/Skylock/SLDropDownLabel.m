//
//  SLDropDownLabel.m
//  Skylock
//
//  Created by Andre Green on 6/19/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDropDownLabel.h"


#define kSLDropDownLabelXGapScaler  .5f


@interface SLDropDownLabel()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIFont *font;

@end


@implementation SLDropDownLabel

- (id)initWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font
{
    self = [super initWithFrame:frame];
    if (self) {
        _text = text;
        _font = font;
    }
    
    return self;
}

- (UILabel *)label
{
    if (!_label) {
//        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
//                                                           0.0f,
//                                                           self.bounds.size.width - 1.1*self.arrowView.bounds.size.width,
//                                                           self.bounds.size.height)];
        _label = [[UILabel alloc] initWithFrame:[self labelFramewithOptions:nil]];
        _label.text = self.text;
        _label.font = self.font;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    
    return _label;
}

- (UIImageView *)arrowView
{
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow-down-more-small"]];
        [self addSubview:_arrowView];
    }
    
    return _arrowView;
}

- (void)layoutSubviews
{
    CGFloat x0 = .5*(self.bounds.size.width - self.label.bounds.size.width - self.arrowView.bounds.size.width);
    self.label.frame = CGRectMake(x0,
                                  .5*(self.bounds.size.height - self.label.bounds.size.height),
                                  self.label.bounds.size.width,
                                  self.label.bounds.size.height);
    
    self.arrowView.frame = CGRectMake(CGRectGetMaxX(self.label.frame) + kSLDropDownLabelXGapScaler*self.arrowView.frame.size.width,
                                      .5*(self.bounds.size.height - self.arrowView.bounds.size.height),
                                      self.arrowView.bounds.size.width,
                                      self.arrowView.bounds.size.height);
}

- (CGRect)labelFramewithOptions:(NSDictionary *)options
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{NSFontAttributeName: self.font}];
    
    if (options) {
        [attributes addEntriesFromDictionary:options];
    }
    
    CGSize maxSize = CGSizeMake(self.bounds.size.width - kSLDropDownLabelXGapScaler*self.arrowView.bounds.size.width,
                                self.bounds.size.height);
    CGRect frame = [self.text boundingRectWithSize:maxSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes
                                      context:nil];
    
    return frame;
}


@end
