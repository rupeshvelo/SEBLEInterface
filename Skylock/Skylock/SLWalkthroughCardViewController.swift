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
}

class SLWalkthroughCardViewController: UIViewController {
    let viewSize: CGSize
    var xPosition:CGFloat = 0.0
    var initialFrame = CGRectZero
    let animationDurration = 0.5
    var isCardMovingOffscreen = false
    var delegate: SLWalkthroughCardViewControllerDelegate?
    var isActiveController = false
    var scaleFactor:CGFloat
    let xPadding:CGFloat = 30
    
    init(viewSize: CGSize, scaleFactor: CGFloat) {
        self.viewSize = viewSize
        self.scaleFactor = scaleFactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view = self.newCardView()
        self.initialFrame = self.view.frame
        print("initial frame: \(self.initialFrame)")
    }
    
    func newCardView() -> SLWalkthroughCardView {
        let pgr = UIPanGestureRecognizer(target: self, action: "cardViewDragged:")
        let rect = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height)
        if (self.isActiveController) {
            let cardView = SLWalkthoughCardView1(frame: rect, scaleFactor:self.scaleFactor)
            cardView.userInteractionEnabled = true
            cardView.addGestureRecognizer(pgr)
            
            return cardView
        }
        
        let cardView = SLWalkthroughCardView(frame: rect, scaleFactor: self.scaleFactor)
        cardView.userInteractionEnabled = true
        cardView.addGestureRecognizer(pgr)
        
        return cardView
    }
    
    func cardViewDragged(pgr: UIPanGestureRecognizer) {
        if (!self.isActiveController) {
            return
        }
        
        let translation = pgr.translationInView(self.view)
        pgr.view!.center = CGPointMake(pgr.view!.center.x + translation.x, pgr.view!.center.y)
        pgr.setTranslation(CGPointZero, inView: self.view)
        print("translation \(translation)")
        print("new frame: \(self.view.frame)")
        
        if (self.view.frame.origin.x < self.initialFrame.origin.x - 0.5*self.initialFrame.size.width
            && !self.isCardMovingOffscreen) {
            print("should move card off screen to the left")
            self.moveCardViewLeft()
        } else if (self.view.frame.origin.x > self.initialFrame.origin.x + 0.5*self.initialFrame.size.width
            && !self.isCardMovingOffscreen) {
            print("should move card off screen to the right")
            self.moveCardViewRight()
        }
        
        if (pgr.state == UIGestureRecognizerState.Ended && !self.isCardMovingOffscreen) {
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
        }
    }
    
    func moveCardToOrginalPosition() {
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(self.animationDurration, animations: { () -> Void in
                self.view.frame = self.initialFrame
            }) { (finished) -> Void in
               self.view.userInteractionEnabled = true
        }
    }
}
