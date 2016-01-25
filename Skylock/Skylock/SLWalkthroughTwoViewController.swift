//
//  SLWalkthroughTwoViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughTwoViewController: SLWalkthroughCardViewController {
    override func newCardView() -> SLWalkthroughCardView {
        let cardView = super.newCardView()
        
        let phoneView = UIImageView(image: UIImage(named: "walkthrough2_Iphone"))
        phoneView.frame = CGRectMake(
            CGRectGetMidX(cardView.bounds) - 0.5*phoneView.bounds.size.width,
            20,
            phoneView.bounds.size.width,
            phoneView.bounds.size.height
        )
        cardView.addSubview(phoneView)
        
        let blurView = UIImageView(image: UIImage(named: "walkthrough2_blurred_rectangle"))
        blurView.frame = CGRectMake(
            CGRectGetMidX(cardView.bounds) - 0.5*blurView.bounds.size.width,
            CGRectGetMaxY(phoneView.frame) - 0.75*blurView.bounds.size.height,
            blurView.bounds.size.width,
            blurView.bounds.size.height
        )
        cardView.addSubview(blurView)
        
        let utility: SLUtilities = SLUtilities()
        
        let headingText = NSLocalizedString("Skylock uses wirless Bluetooth to talk to your phone", comment: "")
        let headingFont = UIFont(name:"Helvetica", size:18)
        let headingSize = utility.sizeForLabel(
            headingFont!,
            text: headingText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let headingFrame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(phoneView.frame) + 10,
            headingSize.width,
            headingSize.height
        )
        let headingLabel = UILabel(frame: headingFrame)
        headingLabel.text = headingText
        headingLabel.font = headingFont
        headingLabel.numberOfLines = 0
        cardView.addSubview(headingLabel)
        
        let detailText = NSLocalizedString("Bluetooth must be turned on for your Skylock to work. Don't worry it doesn't drain your battery", comment: "")
        let detailFont = UIFont(name:"Helvetica", size:15)
        let detailSize = utility.sizeForLabel(
            detailFont!,
            text: detailText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let detailFrame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(headingLabel.frame) + 10,
            detailSize.width,
            detailSize.height
        )
        let detailLabel = UILabel(frame: detailFrame)
        detailLabel.text = detailText
        detailLabel.font = detailFont
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor(red: 155, green: 155, blue: 155)
        cardView.addSubview(detailLabel)
        
        let blueToothView = UIImageView(image: UIImage(named: "walkthrough2_blue_tooth_icon"))
        blueToothView.frame = CGRectMake(
            CGRectGetMidX(cardView.bounds) - 0.5*blueToothView.bounds.size.width,
            cardView.bounds.size.height - blueToothView.bounds.size.height,
            blueToothView.bounds.size.width,
            blueToothView.bounds.size.height
        )
        cardView.addSubview(blueToothView)
        
        return cardView
    }
}
