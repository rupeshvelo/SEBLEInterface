//
//  SLRequestContactsAccessViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLRequestContactsAccessViewController: UIViewController {
    let xPadding:CGFloat = 20.0
    
    lazy var backgroundView:UIView = {
        let image = UIImage(named: "emergency_contact_circle")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: (self.navigationController?.navigationBar.bounds.size.height)!
                + UIApplication.sharedApplication().statusBarFrame.size.height + 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(image: image)
        view.frame = frame
        
        return view
    }()
    
    lazy var mainInfoLabel:UILabel = {
        let text = NSLocalizedString("Alert your emergency contacts if a crash is detected", comment: "")
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.backgroundView.frame) + 20.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(red: 102, green: 177, blue: 227)
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var detailInfoLabel:UILabel = {
        let text = NSLocalizedString(
            "We hope it never happens, but should an accident be detected, " +
            "your Ellipse can detect it and can send an SMS to your chosen emergency contacts to notify " +
            "them so that they can send help. You can switch this on or off anytime.",
            comment: ""
        )
        
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(9)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.mainInfoLabel.frame) + 20.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var acceptButton:UIButton = {
        let image:UIImage = UIImage(named: "button_yes_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(acceptButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var declineButton:UIButton = {
        let image:UIImage = UIImage(named: "button_not_now_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: CGRectGetMinY(self.acceptButton.frame) - image.size.height - 20.0 ,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(declineButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.backgroundView)
        self.view.addSubview(self.mainInfoLabel)
        self.view.addSubview(self.detailInfoLabel)
        self.view.addSubview(self.acceptButton)
        self.view.addSubview(self.declineButton)
    }
    
    func acceptButtonPressed() {
        let contactHandler = SLContactHandler()
        contactHandler.requestAuthorization { (allowedAccess) in
            if allowedAccess {
                let ecvc = SLEmergencyContactsViewController()
                ecvc.onExit = {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                self.navigationController?.pushViewController(ecvc, animated: true)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    func declineButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
