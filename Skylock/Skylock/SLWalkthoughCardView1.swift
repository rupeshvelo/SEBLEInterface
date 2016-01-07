//
//  SLWalkthoughCardView1.swift
//  Skylock
//
//  Created by Andre Green on 1/4/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthoughCardView1: SLWalkthroughCardView {
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let radarView = UIImageView(image: UIImage(named: "Radar"))
//        radarView.frame = CGRectMake(15, 30, radarView.frame.size.width, radarView.frame.size.height)
//        self.addSubview(radarView)
//        
//        let lockView = UIImageView(image: UIImage(named: "Lock"))
//        lockView.frame = CGRectMake(40, 82, lockView.bounds.size.width, lockView.bounds.size.height)
//        self.addSubview(lockView)
//        
//        let phoneView = UIImageView(image: UIImage(named: "Iphone"))
//        phoneView.frame = CGRectMake(
//            self.bounds.size.width - lockView.frame.origin.x - phoneView.bounds.size.width,
//            55,
//            phoneView.bounds.size.width,
//            phoneView.bounds.size.height
//        )
//        self.addSubview(phoneView)
//        
//        let logo = UIImageView(image: UIImage(named: "Skylock-Logo"))
//        logo.frame = CGRectMake(
//            lockView.frame.origin.x,
//            CGRectGetMaxY(phoneView.frame) + 10,
//            logo.bounds.size.width,
//            logo.bounds.size.height
//        )
//        self.addSubview(logo)
//
//        let utility: SLUtilities = SLUtilities()
//        
//        let getStartedText = NSLocalizedString("Let's get started. All you need is a Skylock", comment: "")
//        let getStartedFont = UIFont(name:"Helvetica", size:18)
//        let getStartedSize = utility.sizeForLabel(
//            getStartedFont!,
//            text: getStartedText,
//            maxWidth: self.bounds.size.width - 2*lockView.frame.origin.x,
//            maxHeight: CGFloat.max,
//            numberOfLines: 0
//        )
//        let getStartedFrame = CGRectMake(
//            lockView.frame.origin.x,
//            CGRectGetMaxY(logo.frame) + 10,
//            getStartedSize.width,
//            getStartedSize.height
//        )
//        let getStartedLabel = UILabel(frame: getStartedFrame)
//        getStartedLabel.text = getStartedText
//        getStartedLabel.font = getStartedFont
//        getStartedLabel.numberOfLines = 0
//        self.addSubview(getStartedLabel)
//        
//        let dontHaveOneText = NSLocalizedString("Don't have one yet? Don't worry,", comment: "")
//        let dontHaveOneFont = UIFont(name:"Helvetica", size:15)
//        let dontHaveOneSize = utility.sizeForLabel(
//            dontHaveOneFont!,
//            text: dontHaveOneText,
//            maxWidth: self.bounds.size.width - 2*lockView.frame.origin.x,
//            maxHeight: CGFloat.max,
//            numberOfLines: 0
//        )
//        let dontHaveOneFrame = CGRectMake(
//            lockView.frame.origin.x,
//            CGRectGetMaxY(getStartedLabel.frame) + 10,
//            dontHaveOneSize.width,
//            dontHaveOneSize.height
//        )
//        let dontHaveOneLabel = UILabel(frame: dontHaveOneFrame)
//        dontHaveOneLabel.text = dontHaveOneText
//        dontHaveOneLabel.font = dontHaveOneFont
//        dontHaveOneLabel.numberOfLines = 0
//        dontHaveOneLabel.textColor = UIColor(red: 155, green: 155, blue: 155)
//        self.addSubview(dontHaveOneLabel)
//        
//        let orderSkylockText = NSLocalizedString("Order a Skylock", comment: "")
//        let orderSkylockSize = utility.sizeForLabel(
//            dontHaveOneFont!,
//            text: orderSkylockText,
//            maxWidth: self.bounds.size.width - 2*lockView.frame.origin.x,
//            maxHeight: CGFloat.max,
//            numberOfLines: 1
//        )
//        let orderSkylockButtonFrame = CGRectMake(
//            lockView.frame.origin.x,
//            CGRectGetMaxY(dontHaveOneLabel.frame) + 5,
//            orderSkylockSize.width,
//            orderSkylockSize.height
//        )
//        let orderSkylockButton = UIButton(frame: orderSkylockButtonFrame)
//        orderSkylockButton.setTitle(orderSkylockText, forState: UIControlState.Normal)
//        orderSkylockButton.setTitleColor(UIColor(red: 105, green: 224, blue: 156), forState: UIControlState.Normal)
//        orderSkylockButton.addTarget(self, action: "orderSkylockButtonPressed", forControlEvents: UIControlEvents.TouchDown)
//    }
}
