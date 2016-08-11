//
//  SLRequestContactsAccessViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLRequestContactsAccessViewController: UIViewController {
    let xPadding:CGFloat = 20.0
    
    lazy var mainInfoLabel:UILabel = {
        let text = NSLocalizedString("Ellipse keeps you safe.", comment: "")
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 22.0)!
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            (self.navigationController?.navigationBar.bounds.size.height)!
                + UIApplication.sharedApplication().statusBarFrame.size.height + 20.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var detailInfoLabel:UILabel = {
        let text = NSLocalizedString(
            "Ellipse can detect if you've been in an accident and alert your loved ones by SMS. "
                + "You can switch this off at any time.",
            comment: ""
        )
        
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 12.0)!
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
        label.textColor = UIColor.whiteColor()
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var acceptButton:UIButton = {
        let height:CGFloat = 55.0
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - height,
            width: self.view.bounds.size.width,
            height: height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.addTarget(self, action: #selector(acceptButtonPressed), forControlEvents: .TouchDown)
        button.setTitle(NSLocalizedString("SET UP EMERGENCY CONTACTS", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        
        return button
    }()
    
    lazy var phoneView:UIView = {
        let image = UIImage(named: "emergency_contacts_phone_image")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: CGRectGetMinY(self.acceptButton.frame) - image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(image: image)
        view.frame = frame
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 160, green: 200, blue: 224)
        
        self.view.addSubview(self.mainInfoLabel)
        self.view.addSubview(self.detailInfoLabel)
        self.view.addSubview(self.acceptButton)
        self.view.addSubview(self.phoneView)
    }
    
    func acceptButtonPressed() {
        let contactHandler = SLContactHandler()
        contactHandler.requestAuthorization { (allowedAccess) in
            dispatch_async(dispatch_get_main_queue(), { 
                if allowedAccess {
                    let ecvc = SLEmergencyContactsViewController()
                    ecvc.onExit = {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    self.navigationController?.pushViewController(ecvc, animated: true)
                } else {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
}
