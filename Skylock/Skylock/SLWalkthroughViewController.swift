//
//  SLWalkthroughViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/3/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughViewController: UIViewController, SLWalkthroughCardViewControllerDelegate {
    let cardDelta:CGFloat = 5.0
    let pageViewController = SLPageViewController(numberOfDots: 5, width: 100)
    var cardViewControllers = [SLWalkthroughCardViewController]()
    var dummyCardViewControllers = [SLWalkthroughCardViewController]()
    var baseFrame:CGRect = CGRectZero
    var currentCardIndex:Int = 0
    let numberOfCards = 5
    let numberOfDummyCards = 4
    let animationDurration = 0.5
    var topCardViewController:SLWalkthroughCardViewController?
    var bottomCardViewController:SLWalkthroughCardViewController?
    
    // lazy variables
    lazy var nextButton:UIButton = {
        let image = UIImage(named: "Next_Button")
        let button = UIButton(frame: CGRectMake(
            0.5*(self.view.bounds.size.width - image!.size.width),
            self.pageViewController.view.frame.origin.y - 10 - image!.size.height,
            image!.size.width,
            image!.size.height
            )
        )
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(self, action: "nextButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        
        return button
    }()
    
    lazy var prevButton:UIButton = {
        let image = UIImage(named: "Previous_Button")
        let button = UIButton(frame: CGRectMake(
            0.5*(self.view.bounds.size.width - image!.size.width),
            self.pageViewController.view.frame.origin.y - 10 - image!.size.height,
            image!.size.width,
            image!.size.height
            )
        )
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(self, action: "previousButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        
        return button
    }()
    
    lazy var swipeLabel: UILabel = {
        let frame = CGRectMake(
            self.baseFrame.origin.x,
            CGRectGetMaxY(self.baseFrame) - 15,
            self.baseFrame.size.width,
            13
        )
        let label = UILabel(frame: frame)
        label.text = NSLocalizedString("Swipe to go to next step", comment: "")
        label.font = UIFont(name:"Helvetica", size:12)
        label.textColor = UIColor(red: 155, green: 155, blue: 155)
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    // end lazy variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 236, green: 236, blue: 236)
        
        self.baseFrame = CGRectMake(
            18,
            21,
            self.view.bounds.size.width - 40,
            self.view.bounds.size.height - 50
        )
        
        self.addCardViewControllers()
        self.addPageViewController()
        
        self.view.addSubview(self.swipeLabel)
        self.view.addSubview(self.nextButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.bringSubviewsToFont()
    }
    
    func addCardViewControllers() {
        for index in 0...self.numberOfDummyCards - 1 {
            let wcvcFrame = self.cardFrameWithIndex(self.numberOfDummyCards - index)
            let wcvc = SLWalkthroughCardViewController(
                viewSize:wcvcFrame.size,
                scaleFactor:wcvcFrame.size.width/self.baseFrame.size.width
            )
            wcvc.delegate = self
            wcvc.view.frame = wcvcFrame
            wcvc.isActiveController = false
            self.addChildViewController(wcvc)
            self.view.addSubview(wcvc.view)
            wcvc.didMoveToParentViewController(self)
            
            self.dummyCardViewControllers.append(wcvc)
        }
        
        let topCardFrame = self.cardFrameWithIndex(0)
        let cardVC1 = SLWalkthroughOneViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        cardVC1.delegate = self
        cardVC1.view.frame = topCardFrame
        cardVC1.isActiveController = true
        
        let cardVC2 = SLWalkthroughTwoViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        cardVC2.delegate = self
        cardVC2.view.frame = topCardFrame
        cardVC2.isActiveController = false
        
        self.cardViewControllers.append(cardVC1)
        self.cardViewControllers.append(cardVC2)
        
        self.topCardViewController = self.cardViewControllers[0]
        self.addChildViewController(self.topCardViewController!)
        self.view.addSubview(self.topCardViewController!.view)
        self.topCardViewController!.didMoveToParentViewController(self)
    }
    
    func addPageViewController() {
        let rect = self.pageViewController.viewRect()
        self.pageViewController.view.frame = CGRectMake(
            0.5*(self.view.bounds.size.width - rect.size.width),
            CGRectGetMinY(self.swipeLabel.frame) - rect.size.height - 5,
            rect.size.width,
            rect.size.height
        )
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.view.bringSubviewToFront(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    func cardFrameWithIndex(index: Int) -> CGRect {
        let delta = CGFloat(index)*self.cardDelta
        return CGRectMake(
            self.baseFrame.origin.x + 3*delta,
            self.baseFrame.origin.y + delta,
            self.baseFrame.size.width - 2*delta,
            self.baseFrame.size.height - 2*delta
        )
    }
    
    func bringSubviewsToFont() {
        self.view.bringSubviewToFront(self.topCardViewController!.view)
        self.view.bringSubviewToFront(self.nextButton)
        self.view.bringSubviewToFront(self.pageViewController.view)
        self.view.bringSubviewToFront(self.swipeLabel)
    }
    func shrinkBottomCard() {
        
    }
    
    func moveBottomCardToTop() {
        
    }
    
    func nextButtonPressed() {
        print("next button pressed")
    }
    
    func previousButtonPressed() {
        print("previous button pressed")
    }
    
    // pragma-mark SLWalkthroughCardViewControllerDelegate methods
    func cardViewControllerViewOffscreenLeft(wcvc: SLWalkthroughCardViewController) {
        if (self.currentCardIndex + 1 < self.cardViewControllers.count) {
            wcvc.isActiveController = false
            wcvc.view.removeFromSuperview()
            let nextWcvc = self.cardViewControllers[++self.currentCardIndex]
            nextWcvc.isActiveController = true
            UIView .animateWithDuration(self.animationDurration, animations: { () -> Void in
                nextWcvc.view.frame = self.cardFrameWithIndex(0)
                }, completion: { (finished) -> Void in
                    self.topCardViewController = nextWcvc
                    self.bottomCardViewController = nil
                    self.bringSubviewsToFont()
            })
        }
    }
    
    func cardViewControllerViewOffscreenRight(wcvc: SLWalkthroughCardViewController) {
        if (self.currentCardIndex > 0) {
            wcvc.isActiveController = false
            wcvc.view.removeFromSuperview()
            let previousWcvc = self.cardViewControllers[--self.currentCardIndex]
            previousWcvc.isActiveController = true
            self.view.bringSubviewToFront(previousWcvc.view)
        }
    }
    
    func cardViewControllerViewMovingLeft(wcvc: SLWalkthroughCardViewController) {
        print("card moving left")
        if let dummyVC = self.dummyCardViewControllers.last where self.currentCardIndex + 1 < self.cardViewControllers.count {
            self.bottomCardViewController = self.cardViewControllers[self.currentCardIndex + 1]
            self.bottomCardViewController!.view.frame = self.cardFrameWithIndex(0)
            self.addChildViewController(self.bottomCardViewController!)
            self.view.insertSubview(
                self.bottomCardViewController!.view,
                belowSubview: self.topCardViewController!.view
            )
            self.bottomCardViewController!.view.autoresizesSubviews = true
            self.bottomCardViewController!.view.frame = dummyVC.view.frame
            self.bottomCardViewController!.didMoveToParentViewController(self)
            
//            let test = UIView(frame: self.bottomCardViewController!.view.frame)
//            test.backgroundColor = UIColor.blueColor()
//            self.view.addSubview(test)
            
            print("frame: \(self.bottomCardViewController!.view.frame)")
        }
    }
    
    func cardViewControllerViewMovingRight(wcvc: SLWalkthroughCardViewController) {
        print("card moving right")
    }
}
