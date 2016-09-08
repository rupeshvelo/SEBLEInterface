//
//  SLConnectLockInfoViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConnectLockInfoViewController: UIViewController {
    let xPadding: CGFloat = 15.0
    
    let labelTextColor:UIColor = UIColor(red: 160, green: 200, blue: 224)
    
    lazy var getStartedLabel:UILabel = {
        let frame = CGRect(x: 0.0, y: 50.0, width: self.view.bounds.size.width, height: 22.0)
        let label:UILabel = UILabel(frame: frame)
        label.text = NSLocalizedString("Let's get you started.", comment: "")
        label.textColor = UIColor(white: 140.0/255.0, alpha: 1.0)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 18.0)
        label.textAlignment = .Center
        
        return label
    }()
    
    lazy var connectEllipseLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text = NSLocalizedString(
            "To get the most out of this app you'll\nneed to set up at least one Ellipse.",
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
            CGRectGetMaxY(self.getStartedLabel.frame) + 76.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.labelTextColor
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var setUpEllipseButton:UIButton = {
        
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.connectEllipseLabel.frame) + 20,
            width: self.view.bounds.size.width - 2.0*self.xPadding,
            height: 44.0
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("SET UP MY OWN ELLISPE", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 12.0)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.addTarget(self, action: #selector(yesButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
//    lazy var sharingInfoLabel:UILabel = {
//        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
//        let utility = SLUtilities()
//        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
//        let text = NSLocalizedString(
//            "I have received an invitation code to\nborrow a friend’s Ellipse.",
//            comment: ""
//        )
//        
//        let labelSize:CGSize = utility.sizeForLabel(
//            font,
//            text: text,
//            maxWidth: labelWidth,
//            maxHeight: CGFloat.max,
//            numberOfLines: 0
//        )
//        
//        let frame = CGRectMake(
//            0.5*(self.view.bounds.size.width - labelSize.width),
//            CGRectGetMaxY(self.setUpEllipseButton.frame) + 26.0,
//            labelSize.width,
//            labelSize.height
//        )
//        
//        let label:UILabel = UILabel(frame: frame)
//        label.textColor = self.labelTextColor
//        label.text = text
//        label.textAlignment = NSTextAlignment.Center
//        label.font = font
//        label.numberOfLines = 0
//        
//        return label
//    }()
//    
//    lazy var invitationButton:UIButton = {
//        let color = UIColor(red: 87, green: 216, blue: 255)
//        let frame = CGRect(
//            x: self.xPadding,
//            y: CGRectGetMaxY(self.sharingInfoLabel.frame) + 26.0,
//            width: self.setUpEllipseButton.bounds.size.width,
//            height: self.setUpEllipseButton.bounds.size.height
//        )
//        
//        let button:UIButton = UIButton(type: .System)
//        button.frame = frame
//        button.setTitle(NSLocalizedString("ADD A FRIEND'S ELLIPSE", comment: ""), forState: .Normal)
//        button.setTitleColor(color, forState: .Normal)
//        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 12.0)
//        button.addTarget(self, action: #selector(invitationButtonPressed), forControlEvents: .TouchDown)
//        button.layer.borderWidth = 1.0
//        button.layer.borderColor = color.CGColor
//        button.enabled = false
//        
//        return button
//    }()
    
    lazy var goToAppLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text = NSLocalizedString(
            "No Ellipse? Come on in.",
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
            CGRectGetMaxY(self.setUpEllipseButton.frame) + 26.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.labelTextColor
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var goToAppButton:UIButton = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.goToAppLabel.frame) + 26.0,
            width: self.setUpEllipseButton.bounds.size.width,
            height: self.setUpEllipseButton.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("GET STARTED", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 12.0)
        button.addTarget(self, action: #selector(goToAppButtonPressed), forControlEvents: .TouchDown)
        button.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("WELCOME ON BOARD :)", comment: "")
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.connectEllipseLabel)
        self.view.addSubview(self.setUpEllipseButton)
//        self.view.addSubview(self.sharingInfoLabel)
//        self.view.addSubview(self.invitationButton)
        self.view.addSubview(self.goToAppLabel)
        self.view.addSubview(self.goToAppButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func yesButtonPressed() {
        let alvc = SLAvailableLocksViewController()
        alvc.dismissConcentricCirclesViewController = false
        self.navigationController?.pushViewController(alvc, animated: true)
    }
    
    func invitationButtonPressed() {
        
    }
    
    func goToAppButtonPressed() {
        let lvc = SLLockViewController()
        self.presentViewController(lvc, animated: true, completion: nil)
    }
}
