//
//  SLConfirmTextCodeViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/22/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConfirmTextCodeViewController: UIViewController, UITextFieldDelegate {
    let ySpacer:CGFloat = 35.0
    
    let xPadding:CGFloat = 25.0
    
    let codeLength:Int = 6
    
    lazy var exitButton:UIButton = {
        let image:UIImage = UIImage(named: "sign_in_close_icon")!
        let frame:CGRect = CGRect(
            x: self.view.bounds.size.width - image.size.width - 10.0,
            y: UIApplication.shared.statusBarFrame.size.height + 10.0,
            width: image.size.width,
            height: image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, for: UIControlState.normal)
        button.isHidden = true
        button.addTarget(
            self,
            action: #selector(exitButtonPressed),
            for: .touchDown
        )
        
        return button
    }()
    
    lazy var verificationLabel:UILabel = {
        let user:SLUser = (SLDatabaseManager.sharedManager() as! SLDatabaseManager).getCurrentUser()!
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFont(ofSize: 14)
        let firstText = NSLocalizedString("A verification code was sent via SMS to ", comment: "")
        let text = user.phoneNumber == nil ? firstText : firstText + user.phoneNumber!
        let labelSize:CGSize = utility.sizeForLabel(
            font:font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.greatestFiniteMagnitude,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: self.xPadding,
            y: 2.0*self.ySpacer,
            width: labelWidth,
            height: labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = .center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var codeEntryView:UIView = {
        let height:CGFloat = 62.0
        let frame = CGRect(
            x: self.xPadding,
            y: self.verificationLabel.frame.maxY + self.ySpacer,
            width: self.view.bounds.size.width - 2.0*self.xPadding,
            height: height
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        
        return view
    }()
    
    lazy var codeEntryField:UITextField = {
        let xPadding:CGFloat = 10.0
        let labelWidth = self.codeEntryView.bounds.size.width - 2*xPadding
        let utility = SLUtilities()
        let font = UIFont.systemFont(ofSize: 28)
        let height:CGFloat = 31.0
        let frame = CGRect(
            x: xPadding,
            y: 0.5*(self.codeEntryView.bounds.size.height - height),
            width: labelWidth,
            height: height
        )
        
        let field:UITextField = UITextField(frame: frame)
        field.delegate = self
        field.textColor = UIColor(red: 102, green: 177, blue: 227)
        field.textAlignment = .center
        field.font = font
        field.keyboardType = .numberPad
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
            y: self.codeEntryView.frame.maxY + self.ySpacer,
            width: width,
            height: 20.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(resendCodeButtonPressed), for: .touchDown)
        button.setTitle(NSLocalizedString("RESEND CODE", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 10.0)
    
        return button
    }()
    
    lazy var signUpButton:UIButton = {
        let padding = 0.5*self.xPadding
        let frame = CGRect(
            x: padding,
            y: self.resendCodeButton.frame.maxY + self.ySpacer,
            width: self.view.bounds.size.width - 2.0*padding,
            height: 44.0
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.backgroundColor = UIColor(red: 102, green: 177, blue: 227)
        button.setTitle(NSLocalizedString("SIGN UP", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 15.0)
        button.addTarget(
            self,
            action: #selector(signUpButtonPressed),
            for: .touchDown
        )
        button.isHidden = true
        
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
        guard let user:SLUser = (SLDatabaseManager.sharedManager() as! SLDatabaseManager).getCurrentUser() else {
            // TODO: present error to user
            return
        }
        
        guard let userId = user.userId else {
            // TODO: present error to user
            return
        }
        
        let keychainHandeler = SLKeychainHandler()
        guard let restToken = keychainHandeler.getItemForUsername(
            userName: userId,
            additionalSeviceInfo: nil,
            handlerCase: SLKeychainHandlerCase.RestToken
        ) else {
            // TODO: present error to user
            return
        }
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as! SLRestManager
        let headers = [
            "Authorization": restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        ]
        let subRoutes:[String] = [user.userId!,restManager.path(asString: .phoneCodeVerification)]
        let postObject = ["verify_hint": self.codeEntryField.text!]
        
        restManager.postObject(
        postObject,
        serverKey: .main,
        pathKey: .users,
        subRoutes: subRoutes,
        additionalHeaders: headers)
        { (status:UInt, payload:[AnyHashable: Any]?) -> Void in
            if status == 201 && payload != nil {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                DispatchQueue.main.async {
                    if SLLockManager.sharedManager.hasLocksForCurrentUser() {
                        let lvc = SLLockViewController()
                        self.present(lvc, animated: true, completion: nil)
                    } else {
                        let clvc = SLConnectLockInfoViewController()
                        let nc:UINavigationController = UINavigationController(rootViewController: clvc)
                        nc.navigationBar.barStyle = UIBarStyle.black
                        nc.navigationBar.tintColor = UIColor.white
                        nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
                        self.present(nc, animated: true, completion: nil)
                    }
                }
            } else {
                // Handle errors here. Should show a popup
            }
        }
    }
    
    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.exitButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.exitButton.isHidden = true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool
    {
        if let text = textField.text {
            let tempText:NSString = text as NSString
            let newText = tempText.replacingCharacters(in: range, with: string)
            if newText.characters.count > self.codeLength {
                return false
            }
            self.signUpButton.isHidden = newText.characters.count < self.codeLength
        }
        
        return true
    }
}
