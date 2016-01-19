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
            30,
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
            CGRectGetMaxY(touchPadView.frame) + 40,
            cardView.bounds.size.width - 2*self.xPadding,
            headingSize.height
        )
        
        let headingLabel = UILabel(frame: headingFrame)
        headingLabel.text = headingText
        headingLabel.font = headingFont
        headingLabel.numberOfLines = 1
        headingLabel.textAlignment = NSTextAlignment.Center
        cardView.addSubview(headingLabel)
        
        return cardView
    }
    
    func yesButtonPressed() {
        print("yes button pressed")
    }
    
    func noButtonPressed() {
        print("no button pressed")
    }
}
