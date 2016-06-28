//
//  SLOnboardingController.swift
//  Skylock
//
//  Created by Andre Green on 5/26/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

@objc public class SLOnboardingPageViewController:UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var pageIndex:Int = 0
    var onboardingControllers = [SLOnboardingViewController]()
    
    
    lazy var pageViewController:UIPageViewController = {
        let pageController:UIPageViewController = UIPageViewController(
            transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
            navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
            options: nil
        )
        pageController.setViewControllers(
            [self.onboardingControllers[0]],
            direction: UIPageViewControllerNavigationDirection.Forward,
            animated: false,
            completion: nil
        )
        pageController.delegate = self
        pageController.dataSource = self
        
        return pageController
    }()
    
    lazy var getStartedButton:UIButton = {
        let image:UIImage = UIImage(named: "button_get_started_now_onboarding")!
        let frame:CGRect = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 30.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(getStartedButtonPressed),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: UIControlState.Normal)
        
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let picName1 = "onboarding_main_image_1"
        let topText1 = NSLocalizedString(
            "Ellipse is a keyless, solar powered, bluetooth enabled, state of the art bike lock.",
            comment: ""
        )
        let bottomText1 = NSLocalizedString(
            "Welcome to the future.  No more searching for lost keys or struggling with bulky " +
            "chain locks, with Ellipse all you need is your smart phone to lock and unlock your " +
            "bike safely and securely. But there’s lot's more.",
            comment: ""
        )
        
        let picName2 = "onboarding_main_image_2"
        let topText2 = NSLocalizedString(
            "Make the most of your bike by sharing with your friends.",
            comment: ""
        )
        let bottomText2 = NSLocalizedString(
            "Ellipse lets you share your bike with up to 5 friends. Once they've installed the app, " +
            "they'll be able to lock and unlock it too, so they can borrow it when you’re not using it.",
            comment: ""
        )
        
        let picName3 = "onboarding_main_image_3"
        let topText3 = NSLocalizedString(
            "State of the art theft detection means peace of mind for you.",
            comment: ""
        )
        let bottomText3 = NSLocalizedString(
            "Ellipse uses its built-in accelerometer to detect theft threats. When your bike is being " +
            "tampered with, Ellipse will detect the motion and send you an alert.",
            comment: ""
        )
        
        let picName4 = "onboarding_main_image_4"
        let topText4 = NSLocalizedString(
            "Crash detection sends auto alerts to your emergency contacts.",
            comment: ""
        )
        let bottomText4 = NSLocalizedString(
            "Nominate up to 3 emergency contacts, and if Ellipse detects an accident, it will " +
            "automatically notify them. Simply swipe to cancel if you're ok.",
            comment: ""
        )
        
        let obvc1 = SLOnboardingViewController(
            nibName: nil,
            bundle: nil,
            picName: picName1,
            topText: topText1,
            bottomText: bottomText1,
            yBottomBound: CGRectGetMinY(self.getStartedButton.frame)
        )
        
        let obvc2 = SLOnboardingViewController(
            nibName: nil,
            bundle: nil,
            picName: picName2,
            topText: topText2,
            bottomText: bottomText2,
            yBottomBound: CGRectGetMinY(self.getStartedButton.frame)
        )
        
        let obvc3 = SLOnboardingViewController(
            nibName: nil,
            bundle: nil,
            picName: picName3,
            topText: topText3,
            bottomText: bottomText3,
            yBottomBound: CGRectGetMinY(self.getStartedButton.frame)
        )
        
        let obvc4 = SLOnboardingViewController(
            nibName: nil,
            bundle: nil,
            picName: picName4,
            topText: topText4,
            bottomText: bottomText4,
            yBottomBound: CGRectGetMinY(self.getStartedButton.frame)
        )
        
        self.onboardingControllers = [
            obvc1,
            obvc2,
            obvc3,
            obvc4
        ]
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        self.view.addSubview(self.getStartedButton)
    }
    
    func getStartedButtonPressed() {
        let signInViewController = SLSignInViewController()
        self.presentViewController(signInViewController, animated: true, completion: nil)
    }
    
    func indexForOnboardingViewController(onboardingViewController: SLOnboardingViewController) -> Int? {
        return self.onboardingControllers.indexOf(onboardingViewController)
    }
    
    public func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController
        ) -> UIViewController?
    {
        if let index = self.onboardingControllers.indexOf(viewController as! SLOnboardingViewController) where
            index < self.onboardingControllers.count - 1
        {
            return self.onboardingControllers[index + 1]
        }
        
        return nil
    }
    
    public func pageViewController(
        pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController
        ) -> UIViewController?
    {
        if let index = self.onboardingControllers.indexOf(viewController as! SLOnboardingViewController) where index > 0 {
            return self.onboardingControllers[index - 1]
        }
        
        return nil
    }
    
    public func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.onboardingControllers.count
    }
    
    public func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageIndex
    }
    
    public func pageViewController(
        pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
                           previousViewControllers: [UIViewController],
                           transitionCompleted completed: Bool
        )
    {
        
    }
    
    public func pageViewController(
        pageViewController: UIPageViewController,
        willTransitionToViewControllers pendingViewControllers: [UIViewController]
        )
    {
        
    }
}
