//
//  SLWalktroughControllerOne.swift
//  Skylock
//
//  Created by Andre Green on 1/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughOneViewController: SLWalkthroughCardViewController {
    override func newCardView() -> SLWalkthroughCardView {
        let cardView = super.newCardView()
        
        let lockView = UIImageView(image: UIImage(named: "Lock"))
        lockView.frame = CGRectMake(
            self.xPadding,
            60,
            lockView.bounds.size.width,
            lockView.bounds.size.height
        )
        cardView.addSubview(lockView)
        
        let phoneView = UIImageView(image: UIImage(named: "Iphone"))
        phoneView.frame = CGRectMake(
            cardView.bounds.size.width - self.xPadding - phoneView.bounds.size.width,
            CGRectGetMidY(lockView.frame) - 0.5*phoneView.bounds.size.height,
            phoneView.bounds.size.width,
            phoneView.bounds.size.height
        )
        cardView.addSubview(phoneView)
        
        let radarView = UIImageView(image: UIImage(named: "walkthrough_radar"))
        radarView.frame = CGRectMake(
            0.5*(cardView.bounds.size.width - radarView.bounds.size.width),
            CGRectGetMidY(lockView.frame) - 0.5*radarView.bounds.size.height,
            radarView.frame.size.width,
            radarView.frame.size.height
        )
        cardView.addSubview(radarView)
        
        let logo = UIImageView(image: UIImage(named: "Skylock-Logo"))
        logo.frame = CGRectMake(
            lockView.frame.origin.x,
            CGRectGetMaxY(phoneView.frame) + 10,
            logo.bounds.size.width,
            logo.bounds.size.height
        )
        cardView.addSubview(logo)
        
        let utility: SLUtilities = SLUtilities()
        
        let getStartedText = NSLocalizedString("Let's get started. All you need is a Skylock", comment: "")
        let getStartedFont = UIFont(name:"Helvetica", size:18)
        let getStartedSize = utility.sizeForLabel(
            getStartedFont!,
            text: getStartedText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let getStartedFrame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(logo.frame) + 10,
            getStartedSize.width,
            getStartedSize.height
        )
        let getStartedLabel = UILabel(frame: getStartedFrame)
        getStartedLabel.text = getStartedText
        getStartedLabel.font = getStartedFont
        getStartedLabel.numberOfLines = 0
        cardView.addSubview(getStartedLabel)
        
        let dontHaveOneText = NSLocalizedString("Don't have one yet? Don't worry,", comment: "")
        let dontHaveOneFont = UIFont(name:"Helvetica", size:15)
        let dontHaveOneSize = utility.sizeForLabel(
            dontHaveOneFont!,
            text: dontHaveOneText,
            maxWidth: self.view.bounds.size.width - 2*lockView.frame.origin.x,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let dontHaveOneFrame = CGRectMake(
            lockView.frame.origin.x,
            CGRectGetMaxY(getStartedLabel.frame) + 10,
            dontHaveOneSize.width,
            dontHaveOneSize.height
        )
        let dontHaveOneLabel = UILabel(frame: dontHaveOneFrame)
        dontHaveOneLabel.text = dontHaveOneText
        dontHaveOneLabel.font = dontHaveOneFont
        dontHaveOneLabel.numberOfLines = 0
        dontHaveOneLabel.textColor = UIColor(red: 155, green: 155, blue: 155)
        cardView.addSubview(dontHaveOneLabel)
        
        let orderSkylockText = NSLocalizedString("Order a Skylock", comment: "")
        let orderSkylockSize = utility.sizeForLabel(
            dontHaveOneFont!,
            text: orderSkylockText,
            maxWidth: self.view.bounds.size.width - 2*lockView.frame.origin.x,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        let orderSkylockButtonFrame = CGRectMake(
            lockView.frame.origin.x,
            CGRectGetMaxY(dontHaveOneLabel.frame) + 5,
            orderSkylockSize.width,
            orderSkylockSize.height
        )
        let orderSkylockButton = UIButton(frame: orderSkylockButtonFrame)
        orderSkylockButton.setTitle(orderSkylockText, forState: UIControlState.Normal)
        orderSkylockButton.setTitleColor(UIColor(red: 105, green: 224, blue: 156), forState: UIControlState.Normal)
        orderSkylockButton.addTarget(self, action: #selector(orderSkylockButtonPressed), forControlEvents: UIControlEvents.TouchDown)
        orderSkylockButton.titleLabel?.font = dontHaveOneFont
        cardView.addSubview(orderSkylockButton)
        
        let setupRequirementText = NSLocalizedString("Setup will require an internet connection to register your Skylock", comment: "")
        let setupRequirementSize = utility.sizeForLabel(
            dontHaveOneFont!,
            text: setupRequirementText,
            maxWidth: self.view.bounds.size.width - 2*lockView.frame.origin.x,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let setupRequirementFrame = CGRectMake(
            lockView.frame.origin.x,
            CGRectGetMaxY(orderSkylockButton.frame) + 10,
            setupRequirementSize.width,
            setupRequirementSize.height
        )
        let setupRequirementLabel = UILabel(frame: setupRequirementFrame)
        setupRequirementLabel.text = setupRequirementText
        setupRequirementLabel.font = dontHaveOneFont
        setupRequirementLabel.numberOfLines = 0
        setupRequirementLabel.textColor = UIColor(red: 250, green: 115, blue: 115)
        cardView.addSubview(setupRequirementLabel)
        
        let wifiView = UIImageView(image: UIImage(named: "wifi86"))
        wifiView.frame = CGRectMake(
            0.5*(cardView.bounds.size.width - wifiView.bounds.size.width),
            cardView.bounds.size.height - wifiView.bounds.size.height,
            wifiView.bounds.size.width,
            wifiView.bounds.size.height
        )
        cardView.addSubview(wifiView)
        
        return cardView
    }
    
    func orderSkylockButtonPressed() {
        print("orderSkylockButton Pressed");
    }
    
    
}
