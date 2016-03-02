//
//  SLWalkthroughThreeViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/8/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughThreeViewController: SLWalkthroughCardViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "foundLock:",
            name: "kSLNotificationLockManagerDiscoverdLock",
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "pairedLock:",
            name: "kSLNotificationLockPaired",
            object: nil
        )
    }
    
    override func newCardView() -> SLWalkthroughCardView {
        let cardView = super.newCardView()
        
        let middleButtonView = UIImageView(image: UIImage(named: "middle_button"))
        middleButtonView.frame = CGRectMake(
            cardView.bounds.size.width - self.xPadding - middleButtonView.bounds.size.width,
            0,
            middleButtonView.bounds.size.width,
            middleButtonView.bounds.size.height
        )
        cardView.addSubview(middleButtonView)
        
        let handView = UIImageView(image: UIImage(named: "walkthrough3_hand"))
        handView.frame = CGRectMake(
            cardView.bounds.size.width - self.xPadding - handView.bounds.size.width - 15,
            CGRectGetMidY(middleButtonView.frame) - 5,
            handView.bounds.size.width,
            handView.bounds.size.height
        )
        cardView.addSubview(handView)
        
        let utility: SLUtilities = SLUtilities()
        
        let headerText = NSLocalizedString("Press the middle button on your Skylock", comment: "")
        let headerFont = UIFont(name:"Helvetica", size:18)
        let headerSize = utility.sizeForLabel(
            headerFont!,
            text: headerText,
            maxWidth: cardView.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let headerFrame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(handView.frame) + 10,
            headerSize.width,
            headerSize.height
        )
        let headerLabel = UILabel(frame: headerFrame)
        headerLabel.text = headerText
        headerLabel.font = headerFont
        headerLabel.numberOfLines = 0
        cardView.addSubview(headerLabel)
        
        let detailText = NSLocalizedString("Wait for the light to start blinking on your Skylock. This means the device is connecting to your phone.", comment: "")
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
            CGRectGetMaxY(headerLabel.frame) + 10,
            detailSize.width,
            detailSize.height
        )
        let detailLabel = UILabel(frame: detailFrame)
        detailLabel.text = detailText
        detailLabel.font = detailFont
        detailLabel.numberOfLines = 0
        detailLabel.textColor = UIColor(red: 155, green: 155, blue: 155)
        cardView.addSubview(detailLabel)
        
        let blueToothImage = UIImage(named: "walkthrough3_Bluetooth")
        let blueToothButtonFrame = CGRectMake(
            0.5*(cardView.bounds.size.width - blueToothImage!.size.width),
            CGRectGetMaxY(detailLabel.frame) + 15,
            blueToothImage!.size.width,
            blueToothImage!.size.height
        )
        let blueToothButton = UIButton(frame: blueToothButtonFrame)
        blueToothButton.setImage(blueToothImage, forState: UIControlState.Normal)
        blueToothButton.addTarget(self, action: "blueToothButtonPressed", forControlEvents: UIControlEvents.TouchDown)
        cardView.addSubview(blueToothButton)

        return cardView
    }
    
    func blueToothButtonPressed() {
        print("blue tooth button pressed")
        
        let lockManager = SLLockManager.sharedManager()
        lockManager.shouldEnterSearchMode(true)
        lockManager.startScan()
    }
    
    func foundLock(notification: NSNotification) {
        print("found lock")
        let lockManager = SLLockManager.sharedManager()
        lockManager.shouldEnterSearchMode(false)
    }
    
    func pairedLock(notification: NSNotification) {
        print("paired lock")
        if let delegate = self.delegate {
            delegate.cardViewControllerWantsNextCard(self)
        }
    }
}
