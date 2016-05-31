//
//  SLConnectLockInfoViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConnectLockInfoViewController: UIViewController {
    var xPadding: CGFloat = 0
    let lightBlueColor:UIColor = UIColor(red: 102, green: 177, blue: 227)
    
    lazy var connectEllipseLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let text = NSLocalizedString("Do you want to connect  your new Ellipse?", comment: "")
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            107.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.lightBlueColor
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var yesButton:UIButton = {
        let image:UIImage = UIImage(named: "button_yes_Onboarding")!
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.connectEllipseLabel.frame) + 20,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(yesButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var infoLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(11)
        let text = NSLocalizedString(
            "If you have bought an Ellipse, you can connect to it " +
            "now and configure it. All you need is a Ellipse, a bluetooth-enabled smart " +
            "phone and an internet connection.  Ellipse uses low energy Bluetooth so it won't " +
            "drain your battery).",
            comment: ""
        )
        
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.yesButton.frame) + 26.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 155, green: 155, blue: 155)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var invitationButton:UIButton = {
        let image:UIImage = UIImage(named: "button_invitation_to_share_Onboarding")!
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.infoLabel.frame) + 26.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(invitationButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let buttonImage:UIImage = UIImage(named: "button_yes_Onboarding")!
        self.xPadding = 0.5*(self.view.bounds.size.width - buttonImage.size.width)
        
        self.view.addSubview(self.connectEllipseLabel)
        self.view.addSubview(self.yesButton)
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.invitationButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func yesButtonPressed() {
        let lockManager = SLLockManager.sharedManager()
        lockManager.shouldEnterActiveSearchMode(true)
        lockManager.startScan()
        
        let alvc = SLAvailableLocksViewController()
        self.navigationController?.pushViewController(alvc, animated: true)
    }
    
    func invitationButtonPressed() {
        
    }
}
