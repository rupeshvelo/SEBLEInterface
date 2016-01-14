//
//  SLWalkthroughViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/3/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit



class SLWalkthroughViewController: UIViewController, SLWalkthroughCardViewControllerDelegate {
    private enum SwipeText {
        case FirstPage
        case LastPage
        case MiddlePage
    }
    
    private enum Page:Int {
        case One = 0
        case Two = 1
        case Three = 2
        case Four = 3
        case Five = 4
    }
    
    let cardDelta:CGFloat = 5.0
    let pageViewController = SLPageViewController(numberOfDots: 5, width: 100)
    private var cardViewControllers = [Page:SLWalkthroughCardViewController]()
    var dummyCardViewControllers = [SLWalkthroughCardViewController]()
    var baseFrame:CGRect = CGRectZero
    private var currentPage:Page = Page.One
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
            self.view.bounds.size.height - 40
        )
        
        self.addCardViewControllers()
        self.addPageViewController()
        
        self.view.addSubview(self.swipeLabel)
        self.setSwipeLabelText(.FirstPage)
        self.view.addSubview(self.nextButton)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.bringSubviewsToFront()
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
        
        let cardVC3 = SLWalkthroughThreeViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        cardVC3.delegate = self
        cardVC3.view.frame = topCardFrame
        cardVC3.isActiveController = false
        
        let cardVC4 = SLWalkthoughFourViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        cardVC4.delegate = self
        cardVC4.view.frame = topCardFrame
        cardVC4.isActiveController = false
        
        let cardVC5 = SLWalkthroughFiveViewController(
            viewSize: topCardFrame.size,
            scaleFactor: 1
        )
        cardVC5.delegate = self
        cardVC5.view.frame = topCardFrame
        cardVC5.isActiveController = false
        
        self.cardViewControllers[.One] = cardVC1
        self.cardViewControllers[.Two] = cardVC2
        self.cardViewControllers[.Three] = cardVC3
        self.cardViewControllers[.Four] = cardVC4
        self.cardViewControllers[.Five] = cardVC5
        
        self.topCardViewController = cardVC1
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
    
    func bringSubviewsToFront() {
        self.view.bringSubviewToFront(self.topCardViewController!.view)
        self.view.bringSubviewToFront(self.nextButton)
        self.view.bringSubviewToFront(self.pageViewController.view)
        self.view.bringSubviewToFront(self.swipeLabel)
    }
    
    private func setSwipeLabelText(swipeCase:SwipeText) {
        let text: String
        switch swipeCase {
        case .FirstPage:
            text = NSLocalizedString("Swipe left to go to next step", comment: "")
        case .LastPage:
            text = NSLocalizedString("Swipe right to go to the previous step", comment: "")
        case .MiddlePage:
            text = NSLocalizedString("Swift to go back & forward", comment: "")
        }
        
        self.swipeLabel.text = text
    }
    
    func placeButtons() {
        let nextImage = UIImage(named: "Next_Button")
        let nextBaseFrame = CGRectMake(
            0.5*(self.view.bounds.size.width - nextImage!.size.width),
            self.pageViewController.view.frame.origin.y - 10 - nextImage!.size.height,
            nextImage!.size.width,
            nextImage!.size.height
        )
        
        let previousImage = UIImage(named: "Previous_Button")
        let previousBaseFrame =  CGRectMake(
            0.5*(self.view.bounds.size.width - previousImage!.size.width),
            self.pageViewController.view.frame.origin.y - 10 - previousImage!.size.height,
            previousImage!.size.width,
            previousImage!.size.height
        )
    }
    
    func increaseCurrentPage() {
        self.currentPage = self.nextPage()
    }
    
    func decreaseCurrentPage() {
        self.currentPage = self.previousPage()
    }
    
    private func nextPage() -> Page {
        let page:Page
        switch self.currentPage {
        case .One:
            page = .Two
        case .Two:
            page = .Three
        case .Three:
            page = .Four
        case .Four, .Five:
            page = .Five
        }
        
        return page
    }
    
    private func previousPage() -> Page {
        let page:Page
        switch self.currentPage {
        case .One, .Two:
            page = .One
        case .Three:
            page = .Two
        case .Four:
            page = .Three
        case .Five:
            page = .Four
        }
        
        return page
    }
    
    func nextButtonPressed() {
        print("next button pressed")
    }
    
    func previousButtonPressed() {
        print("previous button pressed")
    }
    
    // pragma-mark SLWalkthroughCardViewControllerDelegate methods
    func cardViewControllerViewOffscreenLeft(wcvc: SLWalkthroughCardViewController) {
        self.increaseCurrentPage()
        if let nextWcvc = self.cardViewControllers[self.currentPage] where nextWcvc != wcvc {
            wcvc.isActiveController = false
            wcvc.view.removeFromSuperview()
            nextWcvc.isActiveController = true
            let swipeTextCase:SwipeText = self.currentPage == .Five ? .LastPage : .MiddlePage
            UIView .animateWithDuration(self.animationDurration, animations: { () -> Void in
                self.pageViewController.increaseActiveDot()
                nextWcvc.view.frame = self.cardFrameWithIndex(0)
                }, completion: { (finished) -> Void in
                    self.topCardViewController = nextWcvc
                    self.bottomCardViewController = nil
                    self.bringSubviewsToFront()
                    self.setSwipeLabelText(swipeTextCase)
            })
        }
    }
    
    func cardViewControllerViewOffscreenRight(wcvc: SLWalkthroughCardViewController) {
        
    }
    
    func cardViewControllerViewMovingLeft(wcvc: SLWalkthroughCardViewController) {
        print("card moving left")
        if let dummyVC = self.dummyCardViewControllers.last where self.currentPage != .Five {
            self.bottomCardViewController = self.cardViewControllers[self.nextPage()]
            self.bottomCardViewController!.view.frame = self.cardFrameWithIndex(0)
            self.addChildViewController(self.bottomCardViewController!)
            self.view.insertSubview(
                self.bottomCardViewController!.view,
                belowSubview: self.topCardViewController!.view
            )
            self.bottomCardViewController!.view.autoresizesSubviews = true
            self.bottomCardViewController!.view.frame = dummyVC.view.frame
            self.bottomCardViewController!.didMoveToParentViewController(self)
        }
    }
    
    func cardViewControllerViewMovingRight(wcvc: SLWalkthroughCardViewController) {
        print("card moving right")
    }
}
