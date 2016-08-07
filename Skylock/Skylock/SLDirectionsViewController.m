//
//  SLDirectionsViewController.m
//  Skylock
//
//  Created by Andre Green on 9/11/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLDirectionsViewController.h"
#import "SLDirectionsTableViewCell.h"
#import "NSString+Skylock.h"
#import "Ellipse-Swift.h"


#define kSLDirectionViewControllerDirectionCellId @"kSLDirectionViewControllerDirectionCellId"

@interface SLDirectionsViewController()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat xPadding;

@end

#define kSLDirectionsVCHeaderHeight 150.0f

@implementation SLDirectionsViewController

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.view.bounds.size.width,
                                                                      kSLDirectionsVCHeaderHeight)];
        
        UIImage *collapseDirectionsImage = [UIImage imageNamed:@"button_close_window_large_Mapview"];
        UIButton *removeDirectionsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.xPadding,
                                                                                      25.0f,
                                                                                      2.0f*collapseDirectionsImage.size.width,
                                                                                      2.0f*collapseDirectionsImage.size.height)];
        [removeDirectionsButton addTarget:self action:@selector(collapseButtonPressed) forControlEvents:UIControlEventTouchDown];
        [removeDirectionsButton setImage:collapseDirectionsImage forState:UIControlStateNormal];
        [_headerView addSubview:removeDirectionsButton];
        
        NSString *directionsText = NSLocalizedString(@"Directions", nil);
        CGSize maxSize = CGSizeMake(_headerView.bounds.size.width - 2*CGRectGetMaxX(removeDirectionsButton.frame) + 10.0f, CGFLOAT_MAX);
        
        static NSString *fontName = @"Roboto-Regular";
        UIFont *directionsLabelFont = [UIFont fontWithName:fontName size:14.0f];
        
        CGSize directionsLabelSize = [directionsText sizeWithFont:directionsLabelFont maxSize:maxSize];
        UILabel *directionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(.5*(_headerView.bounds.size.width - directionsLabelSize.width),
                                                                             CGRectGetMidY(removeDirectionsButton.frame) - .5*directionsLabelSize.height,
                                                                             directionsLabelSize.width,
                                                                             directionsLabelSize.height)];
        directionsLabel.text = directionsText;
        directionsLabel.textAlignment = NSTextAlignmentCenter;
        directionsLabel.font = directionsLabelFont;
        directionsLabel.textColor = [UIColor whiteColor];
        [_headerView addSubview:directionsLabel];
        
        UIImage *directionsIconImage = [UIImage imageNamed:@"directions_walking_icon"];
        UIImageView *directionsIconView = [[UIImageView alloc] initWithImage:directionsIconImage];
        directionsIconView.frame = CGRectMake(.5*(_headerView.bounds.size.width - directionsIconImage.size.width),
                                              CGRectGetMaxY(directionsLabel.frame) + 10.0f,
                                              directionsIconView.bounds.size.width,
                                              directionsIconView.bounds.size.height);
        [_headerView addSubview:directionsIconView];
        
        maxSize = CGSizeMake(_headerView.bounds.size.width - 2*self.xPadding, CGFLOAT_MAX);
        
        UIFont *subLabelFont = [UIFont fontWithName:fontName size:11.0f];
        
        CGSize addressLabelSize = [self.endAddress sizeWithFont:subLabelFont maxSize:maxSize];
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(.5*(_headerView.bounds.size.width - addressLabelSize.width),
                                                                          CGRectGetMaxY(directionsIconView.frame) + 10.0f,
                                                                          addressLabelSize.width,
                                                                          addressLabelSize.height)];
        addressLabel.text = self.endAddress;
        addressLabel.textAlignment = NSTextAlignmentCenter;
        addressLabel.font = subLabelFont;
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.numberOfLines = 3;
        [_headerView addSubview:addressLabel];
        
        
        NSString *totalDistanceText = [NSString stringWithFormat:@"%@ %.1f%@",
                                       NSLocalizedString(@"Total Distance", nil),
                                       self.totalDistance,
                                       NSLocalizedString(@"mi", nil)];
        maxSize = CGSizeMake(_headerView.bounds.size.width - 2*self.xPadding, CGFLOAT_MAX);
        
        CGSize totalDistanceSize = [totalDistanceText sizeWithFont:subLabelFont maxSize:maxSize];
        UILabel *totalDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(.5*(_headerView.bounds.size.width - totalDistanceSize.width),
                                                                                CGRectGetMaxY(addressLabel.frame) + 5.0f,
                                                                                totalDistanceSize.width,
                                                                                totalDistanceSize.height)];
        totalDistanceLabel.text = totalDistanceText;
        totalDistanceLabel.textAlignment = NSTextAlignmentCenter;
        totalDistanceLabel.font = subLabelFont;
        totalDistanceLabel.textColor = [UIColor whiteColor];
        [_headerView addSubview:totalDistanceLabel];
        
        static CGFloat seperatorViewHeight = .5f;
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         _headerView.bounds.size.height - seperatorViewHeight,
                                                                         _headerView.bounds.size.width,
                                                                         seperatorViewHeight)];
        
        seperatorView.backgroundColor = [UIColor whiteColor];
        [_headerView addSubview:seperatorView];
        
        [self.view addSubview:_headerView];
    }
    
    return _headerView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat headerHeight = CGRectGetMaxY(self.headerView.frame);
        CGRect frame = CGRectMake(0.0f,
                                  headerHeight,
                                  self.view.bounds.size.width,
                                  self.view.bounds.size.height - headerHeight);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        [_tableView registerClass:[SLDirectionsTableViewCell class]
           forCellReuseIdentifier:kSLDirectionViewControllerDirectionCellId];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 90.0f;
        _tableView.layoutMargins = UIEdgeInsetsZero;
        _tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_tableView];
    }
    
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.xPadding = 10.0f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.headerView.backgroundColor = [UIColor clearColor];
    
    [self.tableView reloadData];
}

- (void)collapseButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(directionsViewControllerWantsExit:)]) {
        [self.delegate directionsViewControllerWantsExit:self];
    }
}

- (CGFloat)totalDistance
{
    CGFloat distance = 0.0;
    for (SLDirection *direction in self.directions) {
        distance += [direction distanceInMiles];
    }
    
    return distance;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.directions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SLDirectionsTableViewCell *cell = (SLDirectionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kSLDirectionViewControllerDirectionCellId];
    [cell setPropertiesWithDirection:self.directions[indexPath.row] isFirstDirection:indexPath.row == 0];
    return cell;
}

@end
