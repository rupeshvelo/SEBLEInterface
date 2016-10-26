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
    
    var resetFlag = false
    
    var userToken:String = ""
    
    var error:UInt = 0
    
    var phoneNumber:String = ""
    
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
        button.addTarget(
            self,
            action: #selector(exitButtonPressed),
            for: .touchDown
        )
        
        return button
    }()
    
    lazy var verificationLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let firstText = self.resetFlag ? NSLocalizedString("We’ve sent a 6 digit reset code to ", comment:"") : NSLocalizedString("A verification code was sent via SMS to ", comment: "")
        let text = self.resetFlag ? firstText + self.phoneNumber + "  .Please enter it now" : firstText + self.phoneNumber
        
        let frame = CGRect(
            x: self.xPadding + 2.0,
            y: 2.0*self.ySpacer,
            width: labelWidth,
            height: 2
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.text = text
        label.font = UIFont(name: SLFont.YosemiteRegular.rawValue, size: 30)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }()
    
    lazy var submitCodeButton:UIButton = {
        let height:CGFloat = 55.0
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - height - 200,
            width: self.view.bounds.size.width,
            height: height
        )
        
        let title = NSLocalizedString("SUBMIT CODE", comment: "")
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(title, for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(submitCodeButtonPressed),
            for: .touchDown
        )
        button.isHidden = true
        return button
    }()
    
    func submitCodeButtonPressed(){
        
        SLVerifyTextCode().verifyTextCode(phoneNumber: self.phoneNumber, verifyHint: self.codeEntryField.text!, userToken: "", completion: {(status, response) in
            
            if((status == 200 || status == 201) && response != nil)
            {
                
                DispatchQueue.main.async {
                    let spvc = SLSavePasswordViewController(phoneNumber: self.phoneNumber)
                    self.present(spvc, animated: true, completion: nil)
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Code Verification Error", message: "Sorry: The Code you entered is not Valid. please try again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Error", comment: ""),style: .default, handler: nil))
                    self.resendCodeButton.isHidden = false
                    self.verificationLabel.isHidden = true
                    self.submitCodeButton.isHidden = true
                    self.codeEntryField.text = ""
                self.present(alertController, animated: true, completion: nil)
            }
          }
            
      })
    }
    
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
        let toolBarFrame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 45.0)
        let numberToolbar:UIToolbar = UIToolbar(frame: toolBarFrame)
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: #selector(toolbarDoneButtonPressed)
            )
        ]
        numberToolbar.sizeToFit()
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
        field.returnKeyType = .done
        field.inputAccessoryView = numberToolbar
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
        let color = self.resetFlag ? UIColor(red: 87, green: 216, blue: 255) : UIColor.white
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 18.0)
        button.isHidden = true
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
    
    func toolbarDoneButtonPressed() {
        self.codeEntryField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.view.addSubview(self.codeEntryView)
        self.codeEntryView.addSubview(self.codeEntryField)
        self.view.addSubview(self.submitCodeButton)
        self.view.addSubview(self.verificationLabel)
        self.view.addSubview(self.resendCodeButton)
        self.view.addSubview(self.signUpButton)
        self.view.addSubview(self.exitButton)

        let widthConstraint = NSLayoutConstraint(item:         self.verificationLabel, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)
        self.view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item:         self.verificationLabel, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        self.view.addConstraint(heightConstraint)
        
        let xConstraint = NSLayoutConstraint(item:         self.verificationLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item:         self.verificationLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(xConstraint)
        
        self.view.addConstraint(yConstraint)
        
        
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        if(error == 1){
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Generation of Verification Code Failed", message: "Sorry: Unable to send Verification Code. please try again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            self.resendCodeButton.isHidden = false
            self.verificationLabel.isHidden = true
        } else {
            
            self.resendCodeButton.isHidden = true
            self.verificationLabel.isHidden = false
        }
        
    }
    
    func resendCodeButtonPressed() {
        
        let userToken = (self.resetFlag) ? "" : self.userToken
        self.codeEntryField.text = ""
        SLSendTextCode().sendTextCode(phoneNumber: self.phoneNumber, userToken: userToken){(status: UInt?, response: [AnyHashable:Any]?) in
            
            if(status == 200 || status == 201 && response != nil){
                DispatchQueue.main.async {
                self.resendCodeButton.isHidden = true
                self.verificationLabel.isHidden = false
              }
                
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Generation of Verification Code Failed", message: "Sorry: Unable to send Verification Code. please try again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .default, handler: nil ))
                    self.present(alertController, animated: true, completion: nil)
                    self.resendCodeButton.isHidden = false
                    self.verificationLabel.isHidden = true
                    self.codeEntryField.text = ""
                }
                
            }
            
            
        }

    }
    
    func exitButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func signUpButtonPressed() {
        let userToken = (self.resetFlag) ? "" : self.userToken
        
        SLVerifyTextCode().verifyTextCode(phoneNumber: self.phoneNumber, verifyHint: self.codeEntryField.text!, userToken: userToken, completion: {(status, response) in
            
            if((status == 200 || status == 201) && response != nil)
            {
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
                DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Code Verification Failed", message: "Sorry: The Code you entered is not Valid. please try again", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.resendCodeButton.isHidden = false
                if(!self.resetFlag){
                    self.signUpButton.isHidden = true
                }
                if(self.resetFlag){
                    self.submitCodeButton.isHidden = true
                }
                self.verificationLabel.isHidden = true
              }
            }
            
        })
        
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
            self.signUpButton.isHidden = !(resetFlag) ? newText.characters.count < self.codeLength : true
            
            self.submitCodeButton.isHidden = (resetFlag) ? newText.characters.count < self.codeLength : true
            
            if(!self.submitCodeButton.isHidden){
                self.resendCodeButton.isHidden = (newText.characters.count == self.codeLength) ? true : false
            }

        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      self.codeEntryField.text = ""
        if(self.resetFlag){
            self.submitCodeButton.isHidden = true
        } else {
            self.signUpButton.isHidden = true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if(self.resetFlag){
            self.submitCodeButton.isHidden =  !((self.codeEntryField.text?.characters.count)! > 0)
        } else {
            self.signUpButton.isHidden = !((self.codeEntryField.text?.characters.count)! > 0)

        }
    }
    
    init(phoneNumber:String, resetFlag:Bool, error:UInt, token:String) {
        self.phoneNumber = phoneNumber
        self.resetFlag = resetFlag
        self.error = error
        self.userToken = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
