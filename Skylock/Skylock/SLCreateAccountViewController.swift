//
//  SLCreateAccountViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import CoreTelephony

enum SLCreateAccountFieldPhase {
    case Create
    case SignIn
}

class SLCreateAccountViewController:
SLBaseViewController,
UIScrollViewDelegate,
UITextFieldDelegate,
SLBoxTextFieldWithButtonDelegate
{
    enum FieldName {
        case Email
        case Password
        case PhoneNumber
    }
    
    var textFieldSize:CGSize = CGSizeZero
    
    let xPadding:CGFloat = 15.0
    
    let textColor = UIColor.whiteColor()
    
    let yFieldSpacer:CGFloat = 25.0
    
    var hasSentTextMessage:Bool = false
    
    var currentPhase:SLCreateAccountFieldPhase
    
    var fields:[SLBoxTextField] = [SLBoxTextField]()
    
    var currentField:FieldName?
    
    let passwordMinLength:Int = 8
    
    let passwordMaxLength:Int = 16
    
    let minimumPhoneNumberLength = 4
    
    var isKeyboardShowing:Bool = false
    
    var fieldValues:[FieldName: String] = [
        .Email: "",
        .Password: "",
        .PhoneNumber: ""
    ]
    
    var keyboardFrame:CGRect?
    
    var errorText:[FieldName: String] = [
        .Email: NSLocalizedString("Enter valid address", comment: ""),
        .Password: NSLocalizedString("Must be 8-16 characters", comment: ""),
        .PhoneNumber: NSLocalizedString("Enter phone number", comment: "")
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
        label.text = self.currentPhase == .Create ? NSLocalizedString("Sign up", comment: "") :
            NSLocalizedString("Log in", comment: "")
        label.textColor = UIColor(red: 87, green: 216, blue: 255)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 23.0)
        
        return label
    }()
    
    lazy var emailField:SLBoxTextField = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.topLabel.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextField = SLBoxTextField(
            frame: frame,
            placeHolder: NSLocalizedString("Email address", comment: "")
        )
        field.delegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.None
        field.inputAccessoryView = nil
        
        return field
    }()
    
    lazy var passwordField:SLBoxTextFieldWithButton = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.emailField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextFieldWithButton = SLBoxTextFieldWithButton(
            frame: frame,
            placeHolder: NSLocalizedString("Password", comment: "")
        )
        field.delegate = self
        field.textBoxDelegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.None
        field.secureTextEntry = true
        
        return field
    }()
    
    lazy var phoneNumberField:SLBoxTextField = {
        let numberToolbar:UIToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.bounds.size.width, 45.0))
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items = [
            UIBarButtonItem(
                title: NSLocalizedString("Done", comment: ""),
                style: UIBarButtonItemStyle.Plain,
                target: self,
                action: #selector(toolbarDoneButtonPressed)
            )
        ]
        numberToolbar.sizeToFit()
        
        let xSpacer:CGFloat = 10.0
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextField = SLBoxTextField(
            frame: frame,
            placeHolder: NSLocalizedString("Mobile number", comment: "")
        )
        field.delegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.None
        field.inputAccessoryView = numberToolbar
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
            CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.textColor
        label.text = text
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var sendTextButton:UIButton = {
        let frame = CGRect(
            x: 0.0,
            y: self.view.bounds.size.height - self.emailField.bounds.size.height,
            width: self.view.bounds.size.width,
            height: self.emailField.bounds.size.height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("SEND VERIFICATION CODE", comment: ""), forState: .Normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(
            self,
            action: #selector(startLoginProcedure),
            forControlEvents: .TouchDown
        )
        button.hidden = true
        
        return button
    }()
    
    lazy var loginButton:UIButton = {
        let width = self.passwordField.bounds.size.width
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            width: width,
            height: self.phoneNumberField.bounds.size.height
        )
        
        let title = self.currentPhase == .Create ?  NSLocalizedString("SIGN UP", comment: "") :
            NSLocalizedString("LOG IN", comment: "")
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(title, forState: .Normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(
            self,
            action: #selector(startLoginProcedure),
            forControlEvents: .TouchDown
        )
        
        return button
    }()
    
    lazy var facebookButton:UIButton = {
        let image:UIImage = UIImage(named: "button_sign_up_facebook_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - image.size.width),
            y: self.view.bounds.size.height - image.size.height - self.yFieldSpacer,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(facebookButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
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
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.textFieldSize = CGSize(
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 45.0
        )
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.topLabel)

        if self.currentPhase == .Create {
            self.scrollView.addSubview(self.emailField)
            self.scrollView.addSubview(self.passwordField)
            self.scrollView.addSubview(self.phoneNumberField)
        } else {
            self.scrollView.addSubview(self.phoneNumberField)
            self.scrollView.addSubview(self.passwordField)
            self.view.addSubview(self.facebookButton)
        }
        
        self.view.addSubview(self.exitButton)
        
        self.setCurrentFields()
        self.setFieldPositions()
        
        if self.currentPhase == .Create {
            self.scrollView.addSubview(self.infoLabel)
        }
        
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
                self.emailField,
                self.phoneNumberField,
                self.passwordField
            ]
        case .SignIn:
            self.fields = [
                self.phoneNumberField,
                self.passwordField
            ]
        }
    }
    
    func exitButtonPressed() {
        if (self.isKeyboardShowing) {
            for field in self.fields {
                if field.isFirstResponder() {
                    field.resignFirstResponder()
                    break
                }
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func startLoginProcedure() {
        let ud:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
//        guard let pushId = ud.objectForKey(SLUserDefaultsPushNotificationToken) else {
//            // TODO alert the user of this failure
//            return
//        }
        
        let networkInfo:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        var countryCode:String?
        if let providerInfo:CTCarrier = networkInfo.subscriberCellularProvider,
            let cc = providerInfo.isoCountryCode
        {
            countryCode = cc
        }
        
        let userProperties:[NSObject:AnyObject] = [
            "first_name": NSNull(),
            "last_name": NSNull(),
            "email": self.emailField.text == nil ? NSNull() : self.emailField.text!,
            "user_id": self.phoneNumberField.text == nil ? NSNull() : self.phoneNumberField.text!,
            "password": self.passwordField.text == nil ? NSNull() : self.passwordField.text!,
            "user_type": kSLUserTypeEllipse,
            "reg_id": "000000000000000000",
            "country_code": countryCode == nil ? NSNull() : countryCode!
        ]
        print(userProperties.description)
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as SLRestManager
        restManager.postObject(
        userProperties,
        serverKey: .Main,
        pathKey: .Users,
        subRoutes: nil,
        additionalHeaders: nil,
        completion: { (status: UInt, responseDict:[NSObject: AnyObject]!) in
            print("Response from server after login request: \(responseDict))")
            guard let response:[String:AnyObject] = responseDict as? [String:AnyObject] else {
                print("response dictionary is not in the correct format")
                self.presentWarningController()
                return
            }
            
            guard let userToken:String = response["token"] as? String else {
                print("no rest token in server response")
                self.presentWarningController()
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
            
            if self.currentPhase == .SignIn {
                if status == 200 {
                    ud.setBool(true, forKey: "SLUserDefaultsSignedIn")
                    ud.synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if SLLockManager.sharedManager.hasLocksForCurrentUser() {
                            let lvc = SLLockViewController()
                            self.presentViewController(lvc, animated: true, completion: nil)
                        } else {
                            let clvc = SLConnectLockInfoViewController()
                            let nc:UINavigationController = UINavigationController(rootViewController: clvc)
                            nc.navigationBar.barStyle = UIBarStyle.Black
                            nc.navigationBar.tintColor = UIColor.whiteColor()
                            nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
                            self.presentViewController(nc, animated: true, completion: nil)
                        }
                    })
                } else {
                    self.presentWarningController()
                }
            } else {
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
                    completion: { (status: UInt, textResponseDict:[NSObject:AnyObject]!) in
                        dispatch_async(dispatch_get_main_queue(), { 
                            let ctvc = SLConfirmTextCodeViewController()
                            self.presentViewController(ctvc, animated: true, completion: nil)
                        })
                    }
                )
            }
        })
    }
    
    func loginButtonPressed() {
        self.startLoginProcedure()
    }
    
    func getTextFieldsSectionHeight() -> CGFloat {
        var height:CGFloat = 0.0
        for field in self.fields {
            height += field.bounds.size.height + self.yFieldSpacer
        }
        
        return height
    }
    
    func firstFieldY0() -> CGFloat {
        return CGRectGetMaxY(self.topLabel.frame) + self.yFieldSpacer
    }
    
    func setFieldPositions() {
        var y0 = self.firstFieldY0()
        for field in self.fields {
            field.frame = CGRect(
                x: field.frame.origin.x,
                y: y0,
                width: field.bounds.size.width,
                height: field.bounds.size.height
            )
            
            y0 += self.yFieldSpacer + field.bounds.size.height
        }
    }
    
    func presentWarningController() {
        let texts:[SLWarningViewControllerTextProperty:String?] = [
            .Header: NSLocalizedString("Login Failed", comment: ""),
            .Info: NSLocalizedString(
                "Sorry. We couln't log you in right now. Please check you info and try again, or you can try using Facebook.",
                comment: ""
            ),
            .CancelButton: NSLocalizedString("OK", comment: ""),
            .ActionButton: nil
        ]
        
        self.presentWarningViewControllerWithTexts(texts, cancelClosure: nil)
    }
    
    func setFieldErrorState(fieldName: FieldName, enterErrorMode: Bool) {
        let field:SLBoxTextField = self.fieldFromFieldName(fieldName)
        if field.isInErrorMode() && !enterErrorMode {
            field.exitErrorMode()
        } else if !field.isInErrorMode() && enterErrorMode {
            if let text = self.errorText[fieldName] {
                field.enterErrorModeWithMessage(text)
            }
        }
    }
    
    func areFieldsValid() -> Bool {
        var allFieldsValid = true
        for (key, value) in self.fieldValues {
            // Don't need to validate email on sign in since there in no email field
            if self.currentPhase == .SignIn && key == .Email {
                continue
            }
            
            var isValid = true
            if value == "" {
                isValid = false
                allFieldsValid = false
            } else if key == .Email && (!value.containsString("@") || !value.containsString(".")) {
                isValid = false
                allFieldsValid = false
            } else if key == .Password && (value.characters.count < self.passwordMinLength ||
                value.characters.count > self.passwordMaxLength)
            {
                isValid = false
                allFieldsValid = false
            } else if key == .PhoneNumber && value.characters.count < self.minimumPhoneNumberLength {
                isValid = false
                allFieldsValid = false
            }
            
            self.setFieldErrorState(key, enterErrorMode: !isValid)
        }
        
        return allFieldsValid
    }
    
    func fieldNameFromTextField(textField: UITextField) -> FieldName {
        let fieldName:FieldName
        if textField == self.emailField {
            fieldName = .Email
        } else if textField == self.passwordField {
            fieldName = .Password
        } else {
            fieldName = .PhoneNumber
        }
        
        return fieldName
    }
    
    func fieldFromFieldName(fieldName: FieldName) -> SLBoxTextField {
        let field:SLBoxTextField
        switch fieldName {
        case .Email:
            field = self.emailField
        case .Password:
            field = self.passwordField
        case .PhoneNumber:
            field = self.phoneNumberField
        }
        
        return field
    }
    
    func keyboardOffset() -> CGFloat {
        let firstField:SLBoxTextField = self.fields.first!
        let offset:CGFloat = CGRectGetMinY(firstField.frame) - CGRectGetMaxY(self.exitButton.frame) - 20.0
        
        return offset
    }
    
    func toolbarDoneButtonPressed() {
        self.phoneNumberField.resignFirstResponder()
    }
    
    func facebookButtonPressed() {
        let facebookManager:SLFacebookManger = SLFacebookManger.sharedManager() as! SLFacebookManger
        facebookManager.loginFromViewController(self) { (success) in
            if success {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setBool(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                if SLLockManager.sharedManager.hasLocksForCurrentUser() {
                    let lvc = SLLockViewController()
                    self.presentViewController(lvc, animated: true, completion: nil)
                } else {
                    let clvc = SLConnectLockInfoViewController()
                    let navController:UINavigationController = UINavigationController(rootViewController: clvc)
                    self.presentViewController(navController, animated: true, completion: nil)
                }
            } else {
                // TODO: Handle error in UI
            }
        }
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
        
        if let endFrame:NSValue = info[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboardFrame = endFrame.CGRectValue()
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
        
        let fieldsValidated = self.areFieldsValid()
        self.sendTextButton.hidden = !fieldsValidated
        
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
        if textField == self.emailField {
            keyboardType = .EmailAddress
        } else if textField == self.phoneNumberField {
            keyboardType = .NumberPad
        } else {
            keyboardType = .Default
        }
        
        if textField == self.passwordField {
            // Adding this line since the secure entry option erases all text in the field when 
            // on the user's first keystroke
            self.fieldValues[.Password] = ""
            self.passwordField.text = ""
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
            self.fieldValues[fieldName] = newText as String
            if self.areFieldsValid() {
                if self.currentPhase == .Create {
                    if self.hasSentTextMessage {
                        if !self.view.subviews.contains(self.loginButton) {
                            self.view.addSubview(self.loginButton)
                        }
                    } else {
                        if !self.view.subviews.contains(self.sendTextButton) {
                            self.view.addSubview(self.sendTextButton)
                        }
                    }
                } else {
                    if !self.view.subviews.contains(self.loginButton) {
                        self.view.addSubview(self.loginButton)
                    }
                }
            } else {
                if self.currentPhase == .Create {
                    if self.view.subviews.contains(self.sendTextButton) {
                        self.sendTextButton.removeFromSuperview()
                    }
                    
                    if self.view.subviews.contains(self.loginButton) {
                        self.loginButton.removeFromSuperview()
                    }
                } else {
                    if self.view.subviews.contains(self.loginButton) {
                        self.loginButton.removeFromSuperview()
                    }
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: SLBoxtTextFieldWithButtonDelegate methods
    func showButtonToggledToShow(textField: SLBoxTextFieldWithButton, shouldShow: Bool) {
        textField.secureTextEntry = !shouldShow
    }
}
