//
//  SLAcceptNotificationsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/4/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

@objc protocol SLAcceptNotificationsViewControllerDelegate {
    func userAcceptsLocationUse(acceptNotificationsVC: SLAcceptNotificationsViewController)
    func userAcceptsNotifications(acceptNotificationsVC: SLAcceptNotificationsViewController)
    func acceptsNotificationsControllerWantsExit(
        acceptNotiticationViewController: SLAcceptNotificationsViewController,
        animated: Bool
    )
}

@objc class SLAcceptNotificationsViewController: UIViewController {
    enum NotificationStep {
        case Location
        case Notifications
        case Done
    }

    
    let xPadding:CGFloat = 35.0
    var delegate:SLAcceptNotificationsViewControllerDelegate?
    var currentNotificationStep:NotificationStep = .Location
    
    lazy var backgroundView:UIImageView = {
        let image:UIImage = UIImage(named: "login_use_location_background")!
        let imageView:UIImageView = UIImageView(image: image)
        imageView.frame = self.view.bounds
        
        return imageView
    }()
    
    lazy var okButton:UIButton = {
        let image:UIImage = UIImage(named: "button_ok_onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(okButtonPressed),
            forControlEvents: .TouchDown
        )
        button.setImage(image, forState: .Normal)
        
        return button
    }()
 
    lazy var infoLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(12)
        let text = NSLocalizedString(
            "We use geo-tracking to locate your Ellipse and any shared bikes " +
            "you have access to. When we know where you are, we can show you nearby " +
            "bikes, and help you locate them with precise directions.",
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
            0.5*(self.view.bounds.size.width - labelSize.width),
            CGRectGetMinY(self.okButton.frame) - labelSize.height - 50.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var useLocationLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(17)
        let text = NSLocalizedString("Ellipse would like to use your location", comment: "")
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelSize.width),
            CGRectGetMinY(self.infoLabel.frame) - labelSize.height - 25.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 102, green: 177, blue: 227)
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.okButton)
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.useLocationLabel)
    }
    
    func okButtonPressed() {
        switch self.currentNotificationStep {
        case .Location:
            self.delegate?.userAcceptsLocationUse(self)
            self.currentNotificationStep = .Notifications
        case .Notifications:
            let appDelegate:SLAppDelegate = UIApplication.sharedApplication().delegate as! SLAppDelegate
            appDelegate.setUpNotficationSettings()
            self.currentNotificationStep = .Done
        case .Done:
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "SLUserDefaultsOnBoardingComplete")
            userDefaults.synchronize()
            
            self.dismissViewControllerAnimated(false, completion: nil)
            self.delegate?.acceptsNotificationsControllerWantsExit(self, animated: false)
        }
    }
}
