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
    var baseFrame:CGRect = CGRectZero
    var currentCardIndex:Int = 0
    let numberOfCards = 5
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
        self.view.bringSubviewToFront(self.nextButton)
        self.view.bringSubviewToFront(self.pageViewController.view)
        self.view.bringSubviewToFront(self.swipeLabel)
    }
    
    func addCardViewControllers() {
        for index in 1...self.numberOfCards - 2 {
            let wcvcFrame = self.cardFrameWithIndex(index)
            let wcvc = SLWalkthroughCardViewController(
                viewSize:wcvcFrame.size,
                scaleFactor:wcvcFrame.size.width/self.baseFrame.size.width
            )
            wcvc.delegate = self
            wcvc.view.frame = wcvcFrame
            wcvc.isActiveController = false
            
            self.cardViewControllers.append(wcvc)
        }
        
        let topCardFrame = self.cardFrameWithIndex(0)
        self.topCardViewController = SLWalkthroughOneViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        
        self.bottomCardViewController = SLWalkthroughOneViewController
        
        for wcvc in self.cardViewControllers {
            self.addChildViewController(wcvc)
            self.view.addSubview(wcvc.view)
            wcvc.didMoveToParentViewController(self)
        }
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
        let delta = CGFloat(self.numberOfCards - index)*self.cardDelta
        return CGRectMake(
            self.baseFrame.origin.x + 3*delta,
            self.baseFrame.origin.y + delta,
            self.baseFrame.size.width - 2*delta,
            self.baseFrame.size.height - 2*delta
        )
    }
    
    func nextButtonPressed() {
        print("next button pressed")
    }
    
    func previousButtonPressed() {
        print("previous button pressed")
    }
    
    // pragma-mark SLWalkthroughCardViewControllerDelegate methods
    func cardViewControllerViewOffscreenLeft(wcvc: SLWalkthroughCardViewController) {
        if (self.currentCardIndex < 4) {
            wcvc.isActiveController = false
            wcvc.view.removeFromSuperview()
            let nextWcvc = self.cardViewControllers[++self.currentCardIndex]
            nextWcvc.isActiveController = true
            self.view.bringSubviewToFront(nextWcvc.view)
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
}
