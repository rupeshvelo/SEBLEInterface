//
//  SLWalkthroughFiveViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/13/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughFiveViewController: SLWalkthroughCardViewController {
    override func newCardView() -> SLWalkthroughCardView {
        let cardView = super.newCardView()
        
        let bikeView = UIImageView(image: UIImage(named: "walkthrough5_bike"))
        bikeView.frame = CGRectMake(
            0.5*(cardView.bounds.size.width - bikeView.bounds.size.width),
            50,
            bikeView.bounds.size.width,
            bikeView.bounds.size.height
        )
        cardView.addSubview(bikeView)
        
        let utility: SLUtilities = SLUtilities()
        
        let headingText = NSLocalizedString("Your Skylock has been paired", comment: "")
        let headingFont = UIFont(name:"Helvetica", size:18)
        let headingSize = utility.sizeForLabel(
            headingFont!,
            text: headingText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        let headingFrame = CGRectMake(
            0.5*(cardView.bounds.size.width - headingSize.width),
            CGRectGetMaxY(bikeView.frame) + 50,
            headingSize.width,
            headingSize.height
        )
        let headingLabel = UILabel(frame: headingFrame)
        headingLabel.text = headingText
        headingLabel.font = headingFont
        headingLabel.numberOfLines = 1
        headingLabel.textAlignment = NSTextAlignment.Center
        cardView.addSubview(headingLabel)
        
        let detailText = NSLocalizedString("We're all done here! What are you waiting for get out and get cycling!", comment: "")
        let detailFont = UIFont(name:"Helvetica", size:15)
        let detailSize = utility.sizeForLabel(
            detailFont!,
            text: detailText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let detailFrame = CGRectMake(
            0.5*(cardView.bounds.size.width - detailSize.width),
            CGRectGetMaxY(headingLabel.frame) + 10,
            detailSize.width,
            detailSize.height
        )
        let detailLabel = UILabel(frame: detailFrame)
        detailLabel.text = detailText
        detailLabel.font = detailFont
        detailLabel.textColor = UIColor(red: 155, green: 155, blue: 155)
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = NSTextAlignment.Center
        cardView.addSubview(detailLabel)
        
        let trophyView = UIImageView(image: UIImage(named: "walkthrough5_award73"))
        trophyView.frame = CGRectMake(
            0.5*(cardView.bounds.size.width - trophyView.bounds.size.width),
            cardView.bounds.size.height - trophyView.bounds.size.height,
            trophyView.bounds.size.width,
            trophyView.bounds.size.height
        )
        cardView.addSubview(trophyView)
        
        return cardView
    }
}
