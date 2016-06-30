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
    
    lazy var codeEntryView:UIView = {
        let width:CGFloat = 164.0
        let height:CGFloat = 66.0
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: 0.5*(self.view.bounds.size.height - height),
            width: width,
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
        let font = UIFont.systemFontOfSize(22)
        let height:CGFloat = 22.0
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
    
    lazy var verificationLabel:UILabel = {
        let xPadding:CGFloat = 70.0
        let labelWidth = self.view.bounds.size.width - 2*xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(14)
        let firstText = NSLocalizedString("A verification code was sent\nvia SMS to ", comment: "")
        let text = self.user.phoneNumber == nil ? firstText : firstText + self.user.phoneNumber!
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            xPadding,
            CGRectGetMinY(self.codeEntryView.frame) - labelSize.height - 40.0 ,
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
    
    lazy var resendCodeButton:UIButton = {
        let width:CGFloat = 0.8*self.verificationLabel.bounds.size.width
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: CGRectGetMaxY(self.codeEntryView.frame) + 40.0,
            width: width,
            height: 20.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(resendCodeButtonPressed), forControlEvents: .TouchDown)
        button.setTitle(NSLocalizedString("RESEND CODE", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        return button
    }()
    
    lazy var confirmCodeButton:UIButton = {
        let image:UIImage = UIImage(named: "confirm_text_code_button")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: .Normal)
        button.addTarget(
            self,
            action: #selector(confirmCodeButtonPressed),
            forControlEvents: .TouchDown
        )
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 102, green: 177, blue: 227)
        
        self.view.addSubview(self.codeEntryView)
        self.codeEntryView.addSubview(self.codeEntryField)
        self.view.addSubview(self.verificationLabel)
        self.view.addSubview(self.resendCodeButton)
        self.view.addSubview(self.confirmCodeButton)
    }
    
    func resendCodeButtonPressed() {
        print("resend code button pressed")
    }
    
    func exitButtonPressed() {
        self.codeEntryField.resignFirstResponder()
    }
    
    func confirmCodeButtonPressed() {
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
        { (responseDict:[NSObject: AnyObject]!) in
            print(responseDict)
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
            self.confirmCodeButton.hidden = newText.characters.count < 4
        }
        
        return true
    }
}
