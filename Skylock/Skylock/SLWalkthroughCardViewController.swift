//
//  SLWalkthroughCardViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/3/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

protocol SLWalkthroughCardViewControllerDelegate {
    func cardViewControllerViewOffscreenLeft(wcvc:SLWalkthroughCardViewController)
    func cardViewControllerViewOffscreenRight(wcvc:SLWalkthroughCardViewController)
    func cardViewControllerViewMovingLeft(wcvc:SLWalkthroughCardViewController)
    func cardViewControllerViewMovingRight(wcvc:SLWalkthroughCardViewController)
    func cardViewControllerViewMovedBackToCenter(wcvc:SLWalkthroughCardViewController)
    func cardViewControllerWantsNextCard(wcvc:SLWalkthroughCardViewController)
}

class SLWalkthroughCardViewController: UIViewController {
    
    enum CardMovementDirection {
        case Left
        case Right
        case None
    }
    
    let viewSize: CGSize
    var xPosition: CGFloat = 0.0
    var initialFrame = CGRectZero
    let animationDurration = 0.5
    var isCardMovingOffscreen = false
    var delegate: SLWalkthroughCardViewControllerDelegate?
    var isActiveController = false
    var scaleFactor: CGFloat
    let xPadding: CGFloat = 30
    var isCardMoving = false
    var previousX: CGFloat?
    let shouldMoveLeft: Bool
    let shouldMoveRight: Bool
    var movementDirection = CardMovementDirection.None
    var tag: String?
    
    init(viewSize: CGSize, scaleFactor: CGFloat, shouldMoveLeft: Bool, shouldMoveRight: Bool) {
        self.viewSize = viewSize
        self.scaleFactor = scaleFactor
        self.shouldMoveLeft = shouldMoveLeft
        self.shouldMoveRight = shouldMoveRight
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = self.newCardView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.initialFrame == CGRectZero {
            self.initialFrame = self.view.frame
            self.previousX = self.view.center.x
        }
    }
    
    func newCardView() -> SLWalkthroughCardView {
        let pgr = UIPanGestureRecognizer(target: self, action: #selector(cardViewDragged(_:)))
        let cardView = SLWalkthroughCardView(
            frame: CGRectMake(0, 0, self.viewSize.width, self.viewSize.height),
            scaleFactor: self.scaleFactor
        )
        cardView.userInteractionEnabled = true
        cardView.addGestureRecognizer(pgr)
        
        return cardView
    }
    
    func cardViewDragged(pgr: UIPanGestureRecognizer) {
        if !self.isActiveController || pgr.view == nil {
            return
        }
        
        let translation = pgr.translationInView(self.view)
        if self.movementDirection == .None && translation.x > 0.0 && !self.shouldMoveRight {
            print("Current card is not allowed to move right")
            return
        }
        
        if self.movementDirection == .None && translation.x < 0.0 && !self.shouldMoveLeft {
            print("Current card is not allowed to move left")
            return
        }
        
        pgr.view!.center = CGPointMake(pgr.view!.center.x + translation.x, pgr.view!.center.y)
        pgr.setTranslation(CGPointZero, inView: self.view)
        
        if self.view.frame.origin.x < self.initialFrame.origin.x - 0.5*self.initialFrame.size.width
            && !self.isCardMovingOffscreen {
            print("should move card off screen to the left")
            self.moveCardViewLeft()
            return
        } else if (self.view.frame.origin.x > self.initialFrame.origin.x + 0.5*self.initialFrame.size.width
            && !self.isCardMovingOffscreen) {
            print("should move card off screen to the right")
            self.moveCardViewRight()
            return
        }
        
        if self.previousX == nil {
            self.previousX = self.view.center.x
        } else {
            print("initial center x: \(CGRectGetMidX(self.initialFrame))")
            print("current center x: \(CGRectGetMidX(self.view.frame))")
            if self.isCardMoving &&
                self.view.center.x > self.previousX &&
                self.delegate != nil &&
                self.movementDirection == .Left &&
                CGRectGetMidX(self.view.frame) > CGRectGetMidX(self.initialFrame) {
                // card moved from left to right movement
                self.movementDirection = .Right
                self.delegate!.cardViewControllerViewMovingRight(self)
                return
            } else if self.view.center.x < self.previousX &&
                self.delegate != nil &&
                !self.isCardMoving &&
                self.movementDirection == .Right &&
                CGRectGetMidX(self.view.frame) < CGRectGetMidX(self.initialFrame) {
                // card moved from right to left movement
                self.movementDirection = .Left
                self.delegate!.cardViewControllerViewMovingLeft(self)
                return
            }
            
            if self.view.center.x > self.previousX && self.delegate != nil && !self.isCardMoving {
                self.isCardMoving = true
                self.movementDirection = .Right
                self.delegate!.cardViewControllerViewMovingRight(self)
            } else if self.view.center.x < self.previousX && self.delegate != nil && !self.isCardMoving {
                self.isCardMoving = true
                self.movementDirection = .Left
                self.delegate!.cardViewControllerViewMovingLeft(self)
            } else {
                self.previousX = self.view.center.x
            }
        }
        
        if pgr.state == UIGestureRecognizerState.Ended && !self.isCardMovingOffscreen {
            self.movementDirection = .None
            self.moveCardToOrginalPosition()
        }
    }
    
    func moveCardViewLeft() {
        self.isCardMovingOffscreen = true
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(self.animationDurration, animations: { () -> Void in
            self.view.frame = CGRectMake(
                -2*self.view.bounds.size.width,
                self.view.frame.origin.x,
                self.view.bounds.size.width,
                self.view.bounds.size.height
            )
            }) { (completion) -> Void in
                if let delegate = self.delegate {
                    delegate.cardViewControllerViewOffscreenLeft(self)
                }
                
                self.isCardMovingOffscreen = false
                self.isCardMoving = false
                self.view.userInteractionEnabled = true
        }
    }
    
    func moveCardViewRight() {
        self.isCardMovingOffscreen = true
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(self.animationDurration, animations: { () -> Void in
            self.view.frame = CGRectMake(
                2*self.view.bounds.size.width,
                self.view.frame.origin.x,
                self.view.bounds.size.width,
                self.view.bounds.size.height
            )
            }) { (complete) -> Void in
                if let delegate = self.delegate {
                    delegate.cardViewControllerViewOffscreenRight(self)
                }
                
                self.isCardMovingOffscreen = false
                self.isCardMoving = false
                self.view.userInteractionEnabled = true
        }
    }
    
    func moveCardToOrginalPosition() {
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(self.animationDurration, animations: { () -> Void in
            self.view.frame = self.initialFrame
            }) { (finished) -> Void in
                self.view.userInteractionEnabled = true
                self.previousX = nil
                self.isCardMoving = false
                if let delegate = self.delegate {
                    delegate.cardViewControllerViewMovedBackToCenter(self)
                }
        }
    }
}
