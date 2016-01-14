//
//  SLWalkthoughFourViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthoughFourViewController: SLWalkthroughCardViewController {
    override func newCardView() -> SLWalkthroughCardView {
        let cardView = super.newCardView()
        
        let touchPadView = UIImageView(image: UIImage(named: "walkthrough4_touch_pad"))
        touchPadView.frame = CGRectMake(
            0,
            20,
            touchPadView.bounds.size.width,
            touchPadView.bounds.size.height
        )
        cardView.addSubview(touchPadView)
        
        let utility: SLUtilities = SLUtilities()
        
        let headingText = NSLocalizedString("Did your skylock blink?", comment: "")
        let headingFont = UIFont(name:"Helvetica", size:18)
        let headingSize = utility.sizeForLabel(
            headingFont!,
            text: headingText,
            maxWidth: cardView.bounds.size.width,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        let headingFrame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(touchPadView.frame) + 10,
            headingSize.width,
            headingSize.height
        )
        let headingLabel = UILabel(frame: headingFrame)
        headingLabel.text = headingText
        headingLabel.font = headingFont
        headingLabel.numberOfLines = 1
        headingLabel.textAlignment = NSTextAlignment.Center
        cardView.addSubview(headingLabel)
        
        let yesButtonImage = UIImage(named: "walkthrough4_yes_button")
        let yesButton = UIButton(frame: CGRectMake(
            0.5*(cardView.bounds.size.width - yesButtonImage!.size.width),
            headingLabel.frame.origin.y - 10 - yesButtonImage!.size.height,
            headingLabel.bounds.size.width,
            headingLabel.bounds.size.height
            )
        )
        yesButton.setImage(yesButtonImage, forState: UIControlState.Normal)
        yesButton.addTarget(self, action: "yesButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        cardView.addSubview(yesButton)
        
        let noButtonImage = UIImage(named: "walkthrough4_no_button")
        let noButton = UIButton(frame: CGRectMake(
            0.5*(cardView.bounds.size.width - noButtonImage!.size.width),
            headingLabel.frame.origin.y - 10 - noButtonImage!.size.height,
            headingLabel.bounds.size.width,
            headingLabel.bounds.size.height
            )
        )
        noButton.setImage(yesButtonImage, forState: UIControlState.Normal)
        noButton.addTarget(self, action: "noButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        cardView.addSubview(noButton)
        
        return cardView
    }
    
    func yesButtonPressed() {
        print("yes button pressed")
    }
    
    func noButtonPressed() {
        print("no button pressed")
    }
}
