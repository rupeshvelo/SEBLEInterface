//
//  SLMainTutorialViewController.m
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMainTutorialViewController.h"
#import "SLTutorialViewController.h"

@interface SLMainTutorialViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) NSArray *tutorialViewControllers;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation SLMainTutorialViewController

- (NSArray *)tutorialViewControllers
{
    if (!_tutorialViewControllers) {
        
    }
    
    return _tutorialViewControllers;
}

- (UIButton *)nextButton
{
    if (!_nextButton) {
        UIImage *image = [UIImage imageNamed:@"next-btn"];
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_nextButton addTarget:self
                        action:@selector(nextButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:_nextButton];
    }
    
    return _nextButton;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        UIImage *image = [UIImage imageNamed:@"back-btn"];
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_backButton addTarget:self
                        action:@selector(backButtonPressed)
              forControlEvents:UIControlEventTouchDown];
    }
    
    return _backButton;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        UIImage *image = [UIImage imageNamed:@"done-btn"];
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_doneButton addTarget:self
                        action:@selector(doneButtonPressed)
              forControlEvents:UIControlEventTouchDown];
    }
    
    return _doneButton;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:205.0f/255.0f
                                                                  green:205.0f/255.0f
                                                                   blue:205.0f/255.0f
                                                                  alpha:1.0f];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:110.0f/255.0f
                                                                     green:223.0f/255.0f
                                                                      blue:158.0f/255.0f
                                                                     alpha:1.0f];
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = self.tutorialViewControllers.count;
        [_pageControl updateCurrentPageDisplay];
    }
    
    return _pageControl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat xButtonPadding = .1*self.view.bounds.size.width;
    CGFloat yButtonPadding = .1*self.view.bounds.size.height;
    
    self.backButton.frame = CGRectMake(xButtonPadding,
                                       self.view.bounds.size.height - yButtonPadding - self.backButton.frame.size.height,
                                       self.backButton.bounds.size.width,
                                       self.backButton.bounds.size.height);
    
    self.nextButton.frame = CGRectMake(self.view.bounds.size.width - xButtonPadding - self.nextButton.bounds.size.width,
                                       self.view.bounds.size.height - yButtonPadding - self.nextButton.frame.size.height,
                                       self.nextButton.bounds.size.width,
                                       self.nextButton.bounds.size.height);
    
    self.doneButton.frame = CGRectMake(.5f*(self.view.bounds.size.width - self.doneButton.bounds.size.width),
                                       self.view.bounds.size.height - yButtonPadding - self.doneButton.frame.size.height,
                                       self.doneButton.bounds.size.width,
                                       self.doneButton.bounds.size.height);
    
    self.pageControl.frame = CGRectMake(.5*(self.view.bounds.size.width - self.pageControl.bounds.size.width),
                                        self.view.bounds.size.height - self.pageControl.bounds.size.height,
                                        self.pageControl.bounds.size.width,
                                        self.pageControl.bounds.size.height);
}

- (void)nextButtonPressed
{
    
}

- (void)backButtonPressed
{
    
}

- (void)doneButtonPressed
{
    
}

#pragma mark UIPageViewController delegate and datasouce methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    ALTutorialViewController *tutorialController = (ALTutorialViewController *)viewController;
    NSUInteger nextPageIndex = tutorialController.pageIndex + 1;
    if (nextPageIndex >= self.tutorialViewControllers.count) {
        return nil;
    }
    
    return self.tutorialViewControllers[nextPageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    ALTutorialViewController *tutorialController = (ALTutorialViewController *)viewController;
    NSInteger previousPageIndex = tutorialController.pageIndex - 1;
    if (previousPageIndex < 0) {
        return nil;
    }
    
    return self.tutorialViewControllers[previousPageIndex];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.tutorialViewControllers.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController *tutorialViewController = [pendingViewControllers firstObject];
    NSUInteger pageIndex = NSUIntegerMax;
    if ([tutorialViewController isMemberOfClass:[ALTutorialViewController class]]) {
        ALTutorialViewController *tvc = (ALTutorialViewController *)tutorialViewController;
        pageIndex = tvc.pageIndex;
    } else if ([tutorialViewController isMemberOfClass:[ALFaceBookFriendsViewController class]]) {
        ALFaceBookFriendsViewController *ffvc = (ALFaceBookFriendsViewController *)tutorialViewController;
        pageIndex = ffvc.pageIndex;
    }
    
    self.currentIndex = pageIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    self.pageControl.currentPage = self.currentIndex;
    [self.pageControl updateCurrentPageDisplay];
    
    if (self.currentIndex == self.tutorialViewControllers.count - 1) {
        self.finishedTutorialButton.alpha = 0.0f;
        self.finishedTutorialButton.hidden = NO;
        self.inviteFriendsButton.alpha = 0.0f;
        self.inviteFriendsButton.hidden = NO;
        [self.view bringSubviewToFront:self.finishedTutorialButton];
        [UIView animateWithDuration:.25 animations:^{
            self.finishedTutorialButton.alpha = 1.0f;
            self.inviteFriendsButton.alpha = 1.0f;
        }];
    } else {
        if (!self.finishedTutorialButton.hidden) {
            [UIView animateWithDuration:.25 animations:^{
                self.finishedTutorialButton.alpha = 0.0f;
                self.inviteFriendsButton.alpha = 0.0f;
            } completion:^(BOOL finished) {
                self.finishedTutorialButton.hidden = YES;
                self.inviteFriendsButton.hidden = YES;
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isMemberOfClass:[ALInviteFriendsViewController class]]) {
        ALInviteFriendsViewController *ifvc = (ALInviteFriendsViewController *)segue.destinationViewController;
        ifvc.fromTutorial = YES;
    }
}


- (void)finishedTutorialButtonPressed:(id)sender
{
    [[ALUserManager manager] setUserCompletedTutorial:YES];
    [self performSegueWithIdentifier:kALSegueTutorialToMap sender:sender];
}

- (void)inviteFriendsButtonPressed:(id)sender
{
    [[ALUserManager manager] setUserCompletedTutorial:YES];
    [self performSegueWithIdentifier:kALSegueTutorialToInviteFriends sender:sender];
}


@end
