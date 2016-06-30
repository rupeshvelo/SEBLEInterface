//
//  SLCreateAccountViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

enum SLCreateAccountFieldPhase {
    case Create
    case SignIn
}

class SLCreateAccountViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    enum FieldName {
        case FirstName
        case LastName
        case Email
        case Password
        case CountryCode
        case PhoneNumber
    }
    
    var textFieldSize:CGSize = CGSizeZero
    
    let xPadding:CGFloat = 15.0
    
    let textColor = UIColor.whiteColor()
    
    let yFieldSpacer:CGFloat = 25.0
    
    var currentPhase:SLCreateAccountFieldPhase
    
    var fields:[SLUnderlineTextView] = [SLUnderlineTextView]()
    
    var currentField:FieldName?
    
    let passwordLength:Int = 8
    
    var isKeyboardShowing:Bool = false
    
    var fieldValues:[FieldName: String] = [
        .FirstName: "",
        .LastName: "",
        .Email: "",
        .Password: "",
        .CountryCode: "+",
        .PhoneNumber: ""
    ]
    
    lazy var scrollView:UIScrollView = {
        let view:UIScrollView = UIScrollView(frame: self.view.bounds)
        view.scrollEnabled = false
        view.showsVerticalScrollIndicator = false
        
        return view
    }()
    
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
        button.addTarget(
            self,
            action: #selector(exitButtonPressed),
            forControlEvents: .TouchDown
        )
        
        return button
    }()
    
    lazy var topLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 88.0,
            width: self.view.bounds.size.width - self.xPadding,
            height: 34.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = self.currentPhase == .Create ? NSLocalizedString("Create an account", comment: "") :
            NSLocalizedString("Log in", comment: "")
        label.textColor = self.textColor
        label.font = UIFont.systemFontOfSize(32.0)
        
        return label
    }()
    
    lazy var firstNameField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.topLabel.frame) + 2*self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("First name", comment: "")
        )
        field.textField.delegate = self
        
        return field
    }()
    
    lazy var lastNameField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.firstNameField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("Last name", comment: "")
        )
        field.textField.delegate = self
        
        return field
    }()
    
    lazy var emailField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.lastNameField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("Email address", comment: "")
        )
        field.textField.delegate = self
        field.textField.autocapitalizationType = UITextAutocapitalizationType.None
        
        return field
    }()
    
    lazy var passwordField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.emailField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("Password", comment: "")
        )
        field.textField.delegate = self
        field.textField.secureTextEntry = true
        field.textField.autocapitalizationType = UITextAutocapitalizationType.None
        
        return field
    }()
    
    lazy var countryCodeField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            width: 45.0,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("+", comment: "")
        )
        field.textField.text = "+"
        field.textField.delegate = self
        
        return field
    }()
    
    lazy var phoneNumberField:SLUnderlineTextView = {
        let xSpacer:CGFloat = 10.0
        let frame = CGRect(
            x: CGRectGetMaxX(self.countryCodeField.frame) + xSpacer,
            y: CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width - self.countryCodeField.bounds.size.width - xSpacer,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(
            frame: frame,
            color: self.textColor,
            placeHolder: NSLocalizedString("Mobile number", comment: "")
        )
        field.textField.delegate = self
        
        return field
    }()
    
    lazy var infoLabel:UILabel = {
        let padding:CGFloat = 45.0
        let labelWidth = self.view.bounds.size.width - 2*padding
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(10)
        let text = NSLocalizedString(
            "We'll send you a confirmation code via SMS to validate your phone number.",
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
            padding,
            CGRectGetMaxY(self.countryCodeField.frame) + 2*self.yFieldSpacer,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.textColor
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var sendTextButton:UIButton = {
        let image:UIImage = self.currentPhase == .Create ?
            UIImage(named: "button_text_confirmation_code_Onboarding")! :
            UIImage(named: "sign_in_existing_user_login_button")!
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
            action: #selector(sendTextButtonPressed),
            forControlEvents: .TouchDown
        )
        button.hidden = true
        
        return button
    }()
    
    init(phase: SLCreateAccountFieldPhase) {
        self.currentPhase = phase
        super.init(nibName: nil, bundle: nil)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, phase: SLCreateAccountFieldPhase) {
        self.currentPhase = phase
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 102, green: 177, blue: 227)
        
        self.textFieldSize = CGSize(
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 20.0
        )
        
        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.topLabel)

        if self.currentPhase == .Create {
            self.scrollView.addSubview(self.firstNameField)
            self.scrollView.addSubview(self.lastNameField)
            self.scrollView.addSubview(self.emailField)
            self.scrollView.addSubview(self.passwordField)
            self.scrollView.addSubview(self.countryCodeField)
            self.scrollView.addSubview(self.phoneNumberField)
            self.scrollView.addSubview(self.infoLabel)
        } else {
            self.scrollView.addSubview(self.countryCodeField)
            self.scrollView.addSubview(self.phoneNumberField)
            self.scrollView.addSubview(self.passwordField)
        }
        
        self.view.addSubview(self.exitButton)
        self.view.addSubview(self.sendTextButton)
        
        self.setCurrentFields()
        self.setFieldPositions()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    func setCurrentFields() {
        switch self.currentPhase {
        case .Create:
            self.fields = [
                self.firstNameField,
                self.lastNameField,
                self.emailField,
                self.passwordField,
                self.countryCodeField,
                self.phoneNumberField
            ]
        case .SignIn:
            self.fields = [
                self.countryCodeField,
                self.phoneNumberField,
                self.passwordField
            ]
        }
    }
    
    func exitButtonPressed() {
        if (self.isKeyboardShowing) {
            for field in self.fields {
                if field.textField.isFirstResponder() {
                    field.textField.resignFirstResponder()
                    break
                }
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func sendTextButtonPressed() {
        let ud:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
//        guard let pushId = ud.objectForKey(SLUserDefaultsPushNotificationToken) else {
//            // TODO alert the user of this failure
//            return
//        }
        let phoneNumber = self.countryCodeField.textField.text! + self.phoneNumberField.textField.text!
        let userProperties:[NSObject:AnyObject] = [
            "first_name": self.firstNameField.textField.text!,
            "last_name": self.lastNameField.textField.text!,
            "email": self.emailField.textField.text!,
            "user_id": phoneNumber,
            "password": self.passwordField.textField.text!,
            "fb_flag": false,
            "reg_id": "000000000000000000"
        ]
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as SLRestManager
        restManager.postObject(
        userProperties,
        serverKey: .Main,
        pathKey: .Users,
        subRoutes: nil,
        additionalHeaders: nil,
        completion: { (responseDict:[NSObject: AnyObject]!) in
            print("responseDict: \(responseDict))")
            guard let response:[String:AnyObject] = responseDict as? [String:AnyObject] else {
                print("response dictionary is not in the correct format")
                return
            }
            
            guard let userToken:String = response["token"] as? String else {
                print("no rest token in server response")
                return
            }
            
            let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
            dbManager.saveUserWithDictionary(userProperties, isFacebookUser: false)
            
            let currentUser:SLUser = SLDatabaseManager.sharedManager().currentUser
            let keyChainHandler = SLKeychainHandler()
            keyChainHandler.setItemForUsername(
                currentUser.userId!,
                inputValue: userToken,
                additionalSeviceInfo: nil,
                handlerCase: .RestToken
            )
            
            ud.setBool(true, forKey: SLUserDefaultsSignedIn)
            ud.synchronize()
            
            dispatch_async(dispatch_get_main_queue(), { 
                let ctcvc = SLConfirmTextCodeViewController()
                self.presentViewController(ctcvc, animated: true, completion: nil)
            })
            
            let subRoutes:[String] = [
                currentUser.userId!,
                restManager.pathAsString(.PhoneVerificaiton)
            ]
            
            let headers = [
                "Authorization": restManager.basicAuthorizationHeaderValueUsername(userToken, password: "")
            ]
            
            restManager.getRequestWithServerKey(
                .Main,
                pathKey: .Users,
                subRoutes: subRoutes,
                additionalHeaders: headers,
                completion: { (textResponseDict:[NSObject:AnyObject]!) in
                    print("text response: \(textResponseDict)")
            })
        })
    }
    
    func getTextFieldsSectionHeight() -> CGFloat {
        var height:CGFloat = 0.0
        for (index, field) in self.fields.enumerate() {
            height += field.bounds.size.height + (index == self.fields.count ? 0.0 : self.yFieldSpacer)
        }
        
        return height
    }
    
    func firstFieldY0() -> CGFloat {
        return 0.5*(self.view.bounds.size.height - self.getTextFieldsSectionHeight())
    }
    
    func setFieldPositions() {
        var y0 = self.firstFieldY0()
        for (index, field) in self.fields.enumerate() {
            field.frame = CGRect(
                x: field.frame.origin.x,
                y: y0,
                width: field.bounds.size.width,
                height: field.bounds.size.height
            )
            
            // hack to get phone number country code and
            // phone number field on same line
            if self.currentPhase == .Create {
                if index < self.fields.count - 2 {
                    y0 += self.yFieldSpacer + field.bounds.size.height
                }
            } else {
                if index > 0 {
                    y0 += self.yFieldSpacer + field.bounds.size.height
                }
            }
        }
    }
    
    func areFieldsValid() -> Bool {
        for (key, value) in self.fieldValues {
            if value == "" {
                return false
            }
            
            if key == .Email && (!value.containsString("@") || !value.containsString(".")) {
                return false
            }
        }
        
        if let email = self.fieldValues[.Email] where
            (!email.containsString("@") || !email.containsString("."))
        {
            return false
        }
        
        if let password = self.fieldValues[.Password]
            where password.characters.count < self.passwordLength
        {
            return false
        }
        
        return true
    }
    
    func fieldNameFromTextField(textField: UITextField) -> FieldName {
        let fieldName:FieldName
        if textField == self.firstNameField.textField {
            fieldName = .FirstName
        } else if textField == self.lastNameField.textField {
            fieldName = .LastName
        } else if textField == self.emailField.textField {
            fieldName = .Email
        } else if textField == self.passwordField.textField {
            fieldName = .Password
        } else if textField == self.countryCodeField.textField {
            fieldName = .CountryCode
        } else {
            fieldName = .PhoneNumber
        }
        
        return fieldName
    }
    
    func keyboardOffset() -> CGFloat {
        let firstField:SLUnderlineTextView = self.fields.first!
        let offset:CGFloat = CGRectGetMinY(firstField.frame) -
            UIApplication.sharedApplication().statusBarFrame.size.height - 30.0
        
        return offset
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.isKeyboardShowing = true
        let info:[String:AnyObject] = notification.userInfo as! [String:AnyObject]
        guard let duration:NSNumber = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            print("No keyboard animation duration in keyboard will show notification")
            return
        }
        
        guard let curve:NSNumber = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            print("No keyboard animation curve in keyboard will show notification")
            return
        }
        
        UIView.animateWithDuration(
            duration.doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: curve.unsignedIntegerValue),
            animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.keyboardOffset())
                self.topLabel.alpha = 0.0
            },
            completion: nil
        )
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.isKeyboardShowing = false
        let info:[String:AnyObject] = notification.userInfo as! [String:AnyObject]
        guard let duration:NSNumber = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
            print("No keyboard animation duration in keyboard will show notification")
            return
        }
        
        guard let curve:NSNumber = info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber else {
            print("No keyboard animation curve in keyboard will show notification")
            return
        }
        
        self.sendTextButton.hidden = !self.areFieldsValid()
        let firstField = self.fields.first!
        let offset = CGRectGetMinY(firstField.frame) - self.firstFieldY0()
        UIView.animateWithDuration(
            duration.doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: curve.unsignedIntegerValue),
            animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: offset)
                self.topLabel.alpha = 1.0
            },
            completion: nil
        )
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let keyboardType:UIKeyboardType
        if textField == self.countryCodeField.textField || textField == self.phoneNumberField.textField {
            keyboardType = .NumberPad
        } else if textField == self.emailField.textField {
            keyboardType = .EmailAddress
        } else {
            keyboardType = .Default
        }
        
        textField.keyboardType = keyboardType
        textField.returnKeyType = .Done
    }
    
    func textField(
        textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
                                      replacementString string: String
        ) -> Bool
    {
        let fieldName = self.fieldNameFromTextField(textField)
        if let text = self.fieldValues[fieldName] {
            let tempText:NSString = text as NSString
            let newText = tempText.stringByReplacingCharactersInRange(range, withString: string)
            if textField == self.countryCodeField.textField && (newText == "" || newText[newText.startIndex] != "+") {
                return false
            }
           
            self.fieldValues[fieldName] = newText as String
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    
        return true
    }
}
