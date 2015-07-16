//
//  SLMainTutorialViewController.m
//  Skylock
//
//  Created by Andre Green on 7/9/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

#import "SLMainTutorialViewController.h"
#import "SLTutorialViewController.h"
#import "SLTutorial1ViewController.h"
#import "SLConstants.h"
#import "SLMapViewController.h"
#import "SLUserDefaults.h"

#define kSLTutorialXPadding 25.0f

typedef NS_ENUM(NSUInteger, SLMainTutorialButtonPosition) {
    SLMainTutorialButtonPositionNone,
    SLMainTutorialButtonPositionLeft,
    SLMainTutorialButtonPositionCenter,
    SLMainTutorialButtonPositionRight
};

@interface SLMainTutorialViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) UIButton *nextButton;
@property (strong, nonatomic) UIButton *backButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) NSArray *tutorialViewControllers;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSDictionary *tutorialText;
@property (nonatomic, assign) BOOL isNextPage;
@end

@implementation SLMainTutorialViewController

- (NSArray *)tutorialViewControllers
{
    if (!_tutorialViewControllers) {
        SLTutorial1ViewController *tvc1 = [SLTutorial1ViewController new];
        tvc1.pageIndex = 0;
        tvc1.imageName = @"img_walkthrough1";
        tvc1.iconName = @"wifi-icon";
        tvc1.mainText = self.tutorialText[@"1Main"];
        tvc1.detailText = self.tutorialText[@"1Detail"];
        tvc1.orderInfoText = self.tutorialText[@"1OrderInfo"];
        tvc1.orderText = self.tutorialText[@"1Order"];
        tvc1.padding = kSLTutorialXPadding;
        
        SLTutorialViewController *tvc2 = [SLTutorialViewController new];
        tvc2.pageIndex = 1;
        tvc2.imageName = @"img_walkthrough2";
        tvc2.iconName = @"bluetooth-icon";
        tvc2.mainText = self.tutorialText[@"2Main"];
        tvc2.detailText = self.tutorialText[@"2Detail"];
        tvc2.padding = kSLTutorialXPadding;

        SLTutorialViewController *tvc3 = [SLTutorialViewController new];
        tvc3.pageIndex = 2;
        tvc3.imageName = @"img_walkthrough3";
        tvc3.mainText = self.tutorialText[@"3Main"];
        tvc3.detailText = self.tutorialText[@"3Detail"];
        tvc3.padding = kSLTutorialXPadding;

        SLTutorialViewController *tvc4 = [SLTutorialViewController new];
        tvc4.pageIndex = 3;
        tvc4.imageName = @"img_walkthrough3";
        tvc4.mainText = self.tutorialText[@"4Main"];
        tvc4.detailText = self.tutorialText[@"4Detail"];
        tvc4.padding = kSLTutorialXPadding;

        _tutorialViewControllers = @[tvc1, tvc2, tvc3, tvc4];
    }
    
    return _tutorialViewControllers;
}

- (UIButton *)nextButton
{
    if (!_nextButton) {
        UIImage *image = [UIImage imageNamed:@"btn_next"];
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_nextButton addTarget:self
                        action:@selector(nextButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_nextButton setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_nextButton];
    }
    
    return _nextButton;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        UIImage *image = [UIImage imageNamed:@"btn_back"];
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_backButton addTarget:self
                        action:@selector(backButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_backButton setImage:image forState:UIControlStateNormal];
        _backButton.hidden = YES;
        [self.view addSubview:_backButton];
    }
    
    return _backButton;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        UIImage *image = [UIImage imageNamed:@"btn_done"];
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                 0.0f,
                                                                 image.size.width,
                                                                 image.size.height)];
        [_doneButton addTarget:self
                        action:@selector(doneButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_doneButton setImage:image forState:UIControlStateNormal];
        _doneButton.hidden = YES;
        [self.view addSubview:_doneButton];
    }
    
    return _doneButton;
}

- (UIButton *)searchButton
{
    if (!_searchButton) {
        UIImage *image = [UIImage imageNamed:@"btn_search"];
        _searchButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   image.size.width,
                                                                   image.size.height)];
        [_searchButton addTarget:self
                        action:@selector(searchButtonPressed)
              forControlEvents:UIControlEventTouchDown];
        [_searchButton setImage:image forState:UIControlStateNormal];
        _searchButton.hidden = YES;
        [self.view addSubview:_searchButton];
    }
    
    return _searchButton;
}
- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl.currentPage = 0;
        _pageControl.numberOfPages = self.tutorialViewControllers.count;
    }
    
    return _pageControl;
}

- (NSDictionary *)tutorialText
{
    if (!_tutorialText) {
        _tutorialText = @{@"1Main":NSLocalizedString(@"Let’s get started. All you’ll need is a Skylock.", nil),
                          @"1Detail":NSLocalizedString(@"Setup requires internet access to register your Skylock.", nil),
                          @"1OrderInfo":NSLocalizedString(@"Don't have one yet?", nil),
                          @"1Order":NSLocalizedString(@"Order a Skylock", nil),
                          @"2Main":NSLocalizedString(@"Skylock uses Bluetooth wireless to talk to your phone.", nil),
                          @"2Detail":NSLocalizedString(@"Bluetooth must be on for Skylock to work. Don’t worry, leaving it on has a minimal impact on battery life.", nil),
                          @"3Main":NSLocalizedString(@"Press any capacitive button on the lock to wake it up.", nil),
                          @"3Detail":NSLocalizedString(@"Wait for Skylock to begin blinking. This sets Skylock into discover mode.", nil),
                          @"4Main":NSLocalizedString(@"Your Skylock has been paired.", nil),
                          @"4Detail":NSLocalizedString(@"What are you waiting for? Get out there and start riding!", nil)
                          };
    }
    
    return _tutorialText;
}

- (UIPageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        [_pageViewController setViewControllers:@[self.tutorialViewControllers[self.currentIndex]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
        _pageViewController.view.frame = self.view.bounds;
        _pageViewController.dataSource = self;
        _pageViewController.delegate = self;
    }
    
    return _pageViewController;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isNextPage = YES;
    self.currentIndex = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.view bringSubviewToFront:self.pageControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat yButtonPadding = .1*self.view.bounds.size.height;

    self.nextButton.frame = CGRectMake(.5*(self.view.bounds.size.width - self.nextButton.bounds.size.width),
                                       self.view.bounds.size.height - yButtonPadding - self.nextButton.frame.size.height,
                                       self.nextButton.bounds.size.width,
                                       self.nextButton.bounds.size.height);
    
    self.backButton.frame = CGRectMake(kSLTutorialXPadding,
                                       self.view.bounds.size.height - yButtonPadding - self.backButton.frame.size.height,
                                       self.backButton.bounds.size.width,
                                       self.backButton.bounds.size.height);
    
    
    self.doneButton.frame = CGRectMake(.5f*(self.view.bounds.size.width - self.doneButton.bounds.size.width),
                                       self.view.bounds.size.height - yButtonPadding - self.doneButton.frame.size.height,
                                       self.doneButton.bounds.size.width,
                                       self.doneButton.bounds.size.height);
    
    self.searchButton.frame = CGRectMake(self.view.bounds.size.width - self.searchButton.bounds.size.width - kSLTutorialXPadding,
                                         self.view.bounds.size.height - yButtonPadding - self.searchButton.frame.size.height,
                                         self.searchButton.bounds.size.width,
                                         self.searchButton.bounds.size.height);
}

- (void)arrangeButtons
{
    NSLog(@"current index: %@, next page: %@", @(self.currentIndex), self.isNextPage?@"YES":@"NO");
    if (self.currentIndex == 0) {
        if (self.isNextPage) {
            [self animateButton:self.nextButton shouldFade:NO shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionCenter];
            [self animateButton:self.backButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionLeft];
        } else {
            [self animateButton:self.nextButton shouldFade:NO shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionCenter];
            [self animateButton:self.backButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionLeft];
        }
    } else if (self.currentIndex == 1) {
        if (self.isNextPage) {
            [self animateButton:self.nextButton shouldFade:NO shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionRight];
            [self animateButton:self.backButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionLeft];
        } else {
            [self animateButton:self.nextButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionRight];
            [self animateButton:self.backButton shouldFade:NO shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionLeft];
            [self animateButton:self.searchButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionRight];
        }
    } else if (self.currentIndex == 2) {
        if (self.isNextPage) {
            [self animateButton:self.nextButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionRight];
            [self animateButton:self.searchButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionRight];
        } else {
            [self animateButton:self.searchButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionRight];
            [self animateButton:self.backButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionLeft];
            [self animateButton:self.doneButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionCenter];
        }
    } else if (self.currentIndex == 3) {
        [self animateButton:self.searchButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionRight];
        [self animateButton:self.backButton shouldFade:YES shouldFadeIn:NO toPosition:SLMainTutorialButtonPositionLeft];
        [self animateButton:self.doneButton shouldFade:YES shouldFadeIn:YES toPosition:SLMainTutorialButtonPositionCenter];
    }
}

- (void)animateButton:(UIButton *)button
           shouldFade:(BOOL)shouldFade
         shouldFadeIn:(BOOL)shouldFadeIn
           toPosition:(SLMainTutorialButtonPosition)position
{
    CGFloat xPosition = [self locationForButton:button atPosition:position];
    
    if (shouldFade) {
        [self fadeButton:button shouldFadeIn:shouldFadeIn withCompletion:^{
            [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
                button.frame = CGRectMake(xPosition,
                                          button.frame.origin.y,
                                          button.bounds.size.width,
                                          button.bounds.size.height);
            }];
        }];
    } else {
        [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
            button.frame = CGRectMake(xPosition,
                                      button.frame.origin.y,
                                      button.bounds.size.width,
                                      button.bounds.size.height);
        }];
    }
}

- (void)fadeButton:(UIButton *)button
      shouldFadeIn:(BOOL)shouldFadeIn
    withCompletion:(void(^)(void))completion
{
    button.alpha = shouldFadeIn ? 0.0f:1.0f;
    
    if (shouldFadeIn) {
        button.hidden = NO;
    }
    
    [UIView animateWithDuration:SLConstantsAnimationDurration1 animations:^{
        button.alpha = shouldFadeIn ? 1.0f:0.0f;
    } completion:^(BOOL finished) {
        if (!shouldFadeIn) {
            button.hidden = YES;
        }
        
        if (completion) {
            completion();
        }
    }];
}

- (CGFloat)locationForButton:(UIButton *)button atPosition:(SLMainTutorialButtonPosition)position
{
    CGFloat location;
    switch (position) {
        case SLMainTutorialButtonPositionNone:
            location = button.frame.origin.x;
            break;
        case SLMainTutorialButtonPositionLeft:
            location = kSLTutorialXPadding;
            break;
        case SLMainTutorialButtonPositionCenter:
            location = .5*(self.view.bounds.size.width - button.bounds.size.width);
            break;
        case SLMainTutorialButtonPositionRight:
            location = self.view.bounds.size.width - button.bounds.size.width - kSLTutorialXPadding;
        default:
            break;
    }
    
    return location;
}

- (void)nextButtonPressed
{
    NSLog(@"next button pressed");
    SLTutorialViewController *nextVC = self.tutorialViewControllers[++self.currentIndex];
    __weak typeof (self)weakself = self;
    [self.pageViewController setViewControllers:@[nextVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                             weakself.isNextPage = YES;
                                             [weakself arrangeButtons];
                                         }
                                     }];
}

- (void)backButtonPressed
{
    NSLog(@"back button pressed");
    SLTutorialViewController *prevVC = self.tutorialViewControllers[--self.currentIndex];
    
    __weak typeof (self)weakself = self;
    [self.pageViewController setViewControllers:@[prevVC]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                             weakself.isNextPage = NO;
                                             [weakself arrangeButtons];
                                         }
                                     }];
}

- (void)doneButtonPressed
{
    NSLog(@"done button pressed");
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(YES) forKey:SLUserDefaultsTutorialComplete];
    [ud synchronize];
    
    SLMapViewController *mvc = [SLMapViewController new];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (void)searchButtonPressed
{
    NSLog(@"search button search");
}

#pragma mark UIPageViewController delegate and datasouce methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    SLTutorialViewController *tutorialController = (SLTutorialViewController *)viewController;
    NSUInteger nextPageIndex = tutorialController.pageIndex + 1;
    if (nextPageIndex >= self.tutorialViewControllers.count) {
        return nil;
    }
    
    return self.tutorialViewControllers[nextPageIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    SLTutorialViewController *tutorialController = (SLTutorialViewController *)viewController;
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
    NSLog(@"current Index: %@", @(self.currentIndex));
    return self.currentIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController *tutorialViewController = [pendingViewControllers firstObject];
    NSUInteger pageIndex = NSUIntegerMax;
    if ([tutorialViewController isKindOfClass:[SLTutorialViewController class]]) {
        SLTutorialViewController *tvc = (SLTutorialViewController *)tutorialViewController;
        pageIndex = tvc.pageIndex;
    }
    
    self.isNextPage = pageIndex > self.currentIndex ;
    self.currentIndex = pageIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        self.pageControl.currentPage = self.currentIndex;
        [self.pageControl updateCurrentPageDisplay];
        [self arrangeButtons];
    }
}

@end
