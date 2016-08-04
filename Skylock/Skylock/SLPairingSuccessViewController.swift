//
//  SLParingSuccessViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/1/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLPairingSuccessViewController: UIViewController, UITextFieldDelegate {
    let xPadding:CGFloat = 30.0
    let lightBlueColor = UIColor(red: 102, green: 177, blue: 227)
    let buttonSeperation:CGFloat = 20.0
    
    lazy var dismissKeyboardButton:UIButton = {
        let image:UIImage = UIImage(named: "button_close_window_extra_large_Onboarding")!
        let frame:CGRect = CGRect(
            x: self.view.bounds.size.width - image.size.width - 10.0,
            y: CGRectGetMinY(self.successLabel.frame) - image.size.height - 5.0,
            width: image.size.width,
            height: image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(
            self,
            action: #selector(dismissKeyboardButtonPressed),
            forControlEvents: .TouchDown
        )
        button.hidden = true
        
        return button
    }()
    
    lazy var successLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(24)
        let text = NSLocalizedString("Success!", comment: "")
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            self.xPadding,
            100.0,
            labelWidth,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.lightBlueColor
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var successSubLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(20)
        let text = NSLocalizedString("Your Ellipse has been paired.", comment: "")
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.successLabel.frame) + 5.0,
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
    
    lazy var detailsLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(10)
        let text = NSLocalizedString(
            "We just need a few details from you to set up your Ellipse " +
            "and your profile and you're ready to go.",
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
            CGRectGetMaxY(self.successSubLabel.frame) + 10.0,
            labelWidth,
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
    
    lazy var chooseNameLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(12)
        let text = NSLocalizedString(
            "Choose a name for your Ellipse\n(max 40 characters)",
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
            CGRectGetMaxY(self.detailsLabel.frame) + 55.0,
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
    
    lazy var nameField:UITextField = {
        let xSpacer:CGFloat = 10.0
        let frame = CGRect(
            x: xSpacer,
            y: CGRectGetMaxY(self.chooseNameLabel.frame) + 15.0,
            width: self.view.bounds.size.width - 2*xSpacer,
            height: 20
        )
        
        let field:UITextField = UITextField(frame: frame)
        field.font = UIFont.systemFontOfSize(18)
        field.placeholder = NSLocalizedString("Name your Ellipse.", comment: "")
        field.textColor = UIColor(white: 155.0/255.0, alpha: 1)
        field.textAlignment = .Center
        field.delegate = self
        field.autocapitalizationType = .Words
        field.returnKeyType = .Done
        
        return field
    }()
    
    lazy var underlineView:UIView = {
        let frame = CGRect(
            x: CGRectGetMinX(self.nameField.frame),
            y: CGRectGetMaxY(self.nameField.frame) + 1.0,
            width: self.nameField.bounds.size.width,
            height: 1.0
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(white: 210.0/255.0, alpha: 1.0)
        
        return view
    }()
    
    lazy var noButton:UIButton = {
        let image:UIImage = UIImage(named: "button_no_small_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - self.buttonSeperation) - image.size.width,
            y: self.view.bounds.size.height - image.size.height - 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(noButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var yesButton:UIButton = {
        let image:UIImage = UIImage(named: "button_yes_small_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width + self.buttonSeperation),
            y: CGRectGetMinY(self.noButton.frame),
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(yesButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var setPinNowLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let text = NSLocalizedString(
            "Would you like to set a PIN now?",
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
            CGRectGetMinY(self.noButton.frame) - 25.0,
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("NAME YOUR ELLIPSE", comment: "")
        self.navigationItem.hidesBackButton = true
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.successLabel)
        self.view.addSubview(self.successSubLabel)
        self.view.addSubview(self.detailsLabel)
        self.view.addSubview(self.chooseNameLabel)
        self.view.addSubview(self.nameField)
        self.view.addSubview(self.underlineView)
        self.view.addSubview(self.noButton)
        self.view.addSubview(self.yesButton)
        self.view.addSubview(self.setPinNowLabel)
        self.view.addSubview(self.dismissKeyboardButton)
    }
    
    func yesButtonPressed() {
        let tpvc = SLTouchPadViewController()
        tpvc.onCanelExit = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        tpvc.onSaveExit = {[weak weakTpvc = tpvc] in
            let lvc = SLLockViewController()
            weakTpvc?.presentViewController(lvc, animated: false, completion: nil)
        }
        self.presentViewController(tpvc, animated: true, completion: nil)
        self.saveNewLockName()
    }
    
    func noButtonPressed() {
        self.saveNewLockName()
        
        let lvc = SLLockViewController()
        self.presentViewController(lvc, animated: false, completion: nil)
    }
    
    func dismissKeyboardButtonPressed() {
        self.nameField.resignFirstResponder()
    }
    
    func saveNewLockName() {
        if let lockName = self.nameField.text where lockName != "" {
            let trimmedString = lockName.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
            let lockManager = SLLockManager.sharedManager() as! SLLockManager
            lockManager.changeCurrentLockGivenNameToName(trimmedString)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.dismissKeyboardButton.hidden = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.dismissKeyboardButton.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
