//
//  SLDirectionsTableViewCell.h
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SLDirection;
@interface SLDirectionsTableViewCell : UITableViewCell

- (void)setPropertiesWithDirection:(SLDirection *)direction
                  isFirstDirection:(BOOL)isFirst;

@end
