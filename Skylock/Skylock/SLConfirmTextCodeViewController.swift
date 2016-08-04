//
//  SLConfirmTextCodeViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/22/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConfirmTextCodeViewController: UIViewController, UITextFieldDelegate {
    let user:SLUser = SLDatabaseManager.sharedManager().currentUser
    
    let ySpacer:CGFloat = 35.0
    
    let xPadding:CGFloat = 25.0
    
    let codeLength:Int = 6
    
    lazy var exitButton:UIButton = {
        let image:UIImage = UIImage(named: "sign_in_close_icon")!
        let frame:CGRect = CGRect(
            x: self.view.bounds.size.width - image.size.width - 10.0,
            y: UIApplication.sharedApplication().statusBarFrame.size.height + 10.0,
            width: image.size.width,
            height: image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: UIControlState.Normal)
        button.hidden = true
        button.addTarget(
            self,
            action: #selector(exitButtonPressed),
            forControlEvents: .TouchDown
        )
        
        return button
    }()
    
    lazy var verificationLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let firstText = NSLocalizedString("A verification code was sent via SMS to ", comment: "")
        let text = self.user.phoneNumber == nil ? firstText : firstText + self.user.phoneNumber!
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            2.0*self.ySpacer,
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
    
    lazy var codeEntryView:UIView = {
        let height:CGFloat = 62.0
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.verificationLabel.frame) + self.ySpacer,
            width: self.view.bounds.size.width - 2.0*self.xPadding,
            height: height
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.whiteColor()
        
        return view
    }()
    
    lazy var codeEntryField:UITextField = {
        let xPadding:CGFloat = 10.0
        let labelWidth = self.codeEntryView.bounds.size.width - 2*xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(28)
        let height:CGFloat = 31.0
        let frame = CGRectMake(
            xPadding,
            0.5*(self.codeEntryView.bounds.size.height - height),
            labelWidth,
            height
        )
        
        let field:UITextField = UITextField(frame: frame)
        field.delegate = self
        field.textColor = UIColor(red: 102, green: 177, blue: 227)
        field.textAlignment = .Center
        field.font = font
        field.keyboardType = .NumberPad
        field.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Enter code", comment: ""),
            attributes: [NSForegroundColorAttributeName : UIColor(red: 102, green: 177, blue: 227)]
        )
        
        return field
    }()
    
    lazy var resendCodeButton:UIButton = {
        let width:CGFloat = 0.8*self.verificationLabel.bounds.size.width
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: CGRectGetMaxY(self.codeEntryView.frame) + self.ySpacer,
            width: width,
            height: 20.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(resendCodeButtonPressed), forControlEvents: .TouchDown)
        button.setTitle(NSLocalizedString("RESEND CODE", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 10.0)
    
        return button
    }()
    
    lazy var signUpButton:UIButton = {
        let padding = 0.5*self.xPadding
        let frame = CGRect(
            x: padding,
            y: CGRectGetMaxY(self.resendCodeButton.frame) + self.ySpacer,
            width: self.view.bounds.size.width - 2.0*padding,
            height: 44.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.backgroundColor = UIColor(red: 102, green: 177, blue: 227)
        button.setTitle(NSLocalizedString("SIGN UP", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 15.0)
        button.addTarget(
            self,
            action: #selector(signUpButtonPressed),
            forControlEvents: .TouchDown
        )
        button.hidden = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.view.addSubview(self.codeEntryView)
        self.codeEntryView.addSubview(self.codeEntryField)
        self.view.addSubview(self.verificationLabel)
        self.view.addSubview(self.resendCodeButton)
        self.view.addSubview(self.signUpButton)
    }
    
    func resendCodeButtonPressed() {
        print("resend code button pressed")
    }
    
    func exitButtonPressed() {
        self.codeEntryField.resignFirstResponder()
    }
    
    func signUpButtonPressed() {
        let user:SLUser = SLDatabaseManager.sharedManager().currentUser
        guard let userId = user.userId else {
            // TODO: present error to user
            return
        }
        
        let keychainHandeler = SLKeychainHandler()
        guard let restToken = keychainHandeler.getItemForUsername(
            userId,
            additionalSeviceInfo: nil,
            handlerCase: SLKeychainHandlerCase.RestToken
        ) else {
            // TODO: present error to user
            return
        }
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as SLRestManager
        let headers = [
            "Authorization": restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        ]
        let subRoutes:[String] = [user.userId!,restManager.pathAsString(.PhoneCodeVerification)]
        let postObject = ["verify_hint": self.codeEntryField.text!]
        
        restManager.postObject(
        postObject,
        serverKey: .Main,
        pathKey: .Users,
        subRoutes: subRoutes,
        additionalHeaders: headers)
        { (status:UInt, payload:[NSObject: AnyObject]!) in
            if status == 201 && payload != nil {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                let lockManager:SLLockManager = SLLockManager.sharedManager() as! SLLockManager
                dispatch_async(dispatch_get_main_queue(), { 
                    if lockManager.hasLocksForCurrentUser() {
                        let lvc = SLLockViewController()
                        self.presentViewController(lvc, animated: true, completion: nil)
                    } else {
                        let clvc = SLConnectLockInfoViewController()
                        let navController:UINavigationController = UINavigationController(rootViewController: clvc)
                        self.presentViewController(navController, animated: true, completion: nil)
                    }
                })
            } else {
                // Handle errors here. Should show a popup
            }
        }
    }
    
    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        self.exitButton.hidden = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.exitButton.hidden = true
    }
    
    func textField(
        textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
                                      replacementString string: String) -> Bool
    {
        if let text = textField.text {
            let tempText:NSString = text as NSString
            let newText = tempText.stringByReplacingCharactersInRange(range, withString: string)
            if newText.characters.count > self.codeLength {
                return false
            }
            self.signUpButton.hidden = newText.characters.count < self.codeLength
        }
        
        return true
    }
}
