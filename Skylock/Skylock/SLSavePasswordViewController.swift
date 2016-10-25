//
//  SLSavePasswordViewController.swift
//  Ellipse
//
//  Created by S Rupesh Kumar on 21/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Foundation

class SLSavePasswordViewController: UIViewController, UITextFieldDelegate, SLBoxTextFieldWithButtonDelegate {

    let xPadding:CGFloat = 15.0
    
    var textFieldSize:CGSize = CGSize.zero
    
    let yFieldSpacer:CGFloat = 25.0
    
    var phoneNumber:String = ""
    
    let minPasswordLength = 8
    
    let maxPasswordLength = 16
    lazy var informationLabel:UILabel = {
        
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let utility = SLUtilities()
        let text = "Now create a new password for your account:"
        
        let frame = CGRect(
            x: self.passwordField.frame.minX,
            y: 2.0*self.yFieldSpacer + 8,
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
    
    lazy var savePasswordButton:UIButton = {
        let height:CGFloat = 55.0
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - height - 200,
            width: self.view.bounds.size.width,
            height: height
        )
        
        let title = NSLocalizedString("SAVE PASSWORD", comment: "")
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(title, for: .normal)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(savePasswordButtonPressed),
            for: .touchDown
        )
        button.isHidden = true
        return button
    }()
    
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

    func exitButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePasswordButtonPressed(){
        SLSavePassword().savePassword(phoneNumber: self.phoneNumber, password: self.passwordField.text!, completion: {(status, response) in
            if(status == 200 || status == 201 && response != nil){
            
            DispatchQueue.main.async {
                
                let alertController = UIAlertController(title: "Password Creation Message", message: "Password Successfully Changed. Please login with your password", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .default, handler: { action in
                    let svc = SLSignInViewController()
                    self.present(svc, animated: true, completion: nil)
                }))
                self.present(alertController, animated: true, completion: nil)
                
                
            }
            
            } else {
                
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Password Creation Failed", message: "Sorry: Unable to reset password for your account. please try again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    self.passwordField.text = ""
                }

                
            }
            
        })
        
    }
    
    lazy var passwordField:SLBoxTextFieldWithButton = {
        let frame = CGRect(
            x: self.xPadding - 2,
            y: 85 + self.yFieldSpacer + 8,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextFieldWithButton = SLBoxTextFieldWithButton(
            frame: frame,
            placeHolder: NSLocalizedString("Password", comment: "")
        )
        field.delegate = self
        field.textBoxDelegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.none
        field.isSecureTextEntry = true
        return field
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.textFieldSize = CGSize(
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 45.0
        )
        self.view.addSubview(self.passwordField)
        self.view.addSubview(self.informationLabel)
        self.view.addSubview(self.savePasswordButton)
        self.view.addSubview(self.exitButton)
        
        let widthConstraint = NSLayoutConstraint(item:         self.informationLabel, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)
        self.view.addConstraint(widthConstraint)
        
        let heightConstraint = NSLayoutConstraint(item:         self.informationLabel, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        self.view.addConstraint(heightConstraint)
        
        let xConstraint = NSLayoutConstraint(item:         self.informationLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item:         self.informationLabel, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(xConstraint)
        
        self.view.addConstraint(yConstraint)
        
        let widthConstraint1 = NSLayoutConstraint(item:         self.passwordField, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)
        self.view.addConstraint(widthConstraint1)
        
        let heightConstraint1 = NSLayoutConstraint(item:         self.passwordField, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        self.view.addConstraint(heightConstraint1)
        
        let xConstraint1 = NSLayoutConstraint(item:         self.passwordField, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint1 = NSLayoutConstraint(item:         self.passwordField, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraint(xConstraint1)
        
        self.view.addConstraint(yConstraint1)
    }
    
    init(phoneNumber:String) {
        self.phoneNumber = phoneNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool
    {
        if let text = textField.text {
            let tempText:NSString = text as NSString
            let newText = tempText.replacingCharacters(in: range, with: string)
            if newText.characters.count > self.maxPasswordLength {
                return false
            }
            self.savePasswordButton.isHidden = !(newText.characters.count >= self.minPasswordLength && newText.characters.count <= self.maxPasswordLength)
            
            self.setFieldErrorState(fieldName: self.passwordField , enterErrorMode: self.savePasswordButton.isHidden)
        }
        
        return true
    }

    func setFieldErrorState(fieldName: SLBoxTextField, enterErrorMode: Bool) {
        let field:SLBoxTextField = fieldName
        if field.isInErrorMode() && !enterErrorMode {
            field.exitErrorMode()
        } else if !field.isInErrorMode() && enterErrorMode {
            let text = "Must be 8-16 Characters"
            field.enterErrorModeWithMessage(message: text)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.passwordField.text = ""
        self.savePasswordButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: SLBoxtTextFieldWithButtonDelegate methods
   func showButtonToggledToShow(textField: SLBoxTextFieldWithButton, shouldShow: Bool){
        textField.isSecureTextEntry = !shouldShow
    }

}
