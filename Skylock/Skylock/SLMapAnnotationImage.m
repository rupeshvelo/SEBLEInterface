//
//  SLMapAnnotationImage.m
//  Skylock
//
//  Created by Andre Green on 7/19/15.
//  Copyright (c) 2015 Andre Green. All  reserved.
//

#import "SLMapAnnotationImage.h"

@implementation SLMapAnnotationImage

- (void)drawInRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat carrotWidth = .2*self.size.width;
    CGFloat carrotHeight = .2*self.size.height;
    CGFloat radius = .5*(self.size.height - carrotHeight);
    CGFloat theta = acos(carrotWidth/radius);
    CGFloat startAngle = 2*M_PI - theta;
    CGFloat endAngle = M_PI + theta;
    
    CGPoint startPoint = CGPointMake(.5*self.size.width,self.size.height);
    CGPoint rightCarrot = CGPointMake(startPoint.x + carrotWidth, startPoint.y + carrotHeight);
    CGPoint center = CGPointMake(.5*self.size.width, radius);
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:rightCarrot];
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    [path addLineToPoint:startPoint];
    [path closePath];
}

@end
