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
    
    private enum ResponseError {
        case InternalServer
        case SignInFailure
    }
    
    var textFieldSize:CGSize = CGSize.zero
    
    let xPadding:CGFloat = 15.0
    
    let textColor = UIColor.white
    
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
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        
        return view
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
            y: self.topLabel.frame.maxY + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextField = SLBoxTextField(
            frame: frame,
            placeHolder: NSLocalizedString("Email address", comment: "")
        )
        field.delegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.none
        field.inputAccessoryView = nil
        
        return field
    }()
    
    lazy var passwordField:SLBoxTextFieldWithButton = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.emailField.frame.maxY + self.yFieldSpacer,
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
        field.secureTextEntry = true
        
        return field
    }()
    
    lazy var phoneNumberField:SLBoxTextField = {
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
        
        let xSpacer:CGFloat = 10.0
        let frame = CGRect(
            x: self.xPadding,
            y: self.passwordField.frame.maxY + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLBoxTextField = SLBoxTextField(
            frame: frame,
            placeHolder: NSLocalizedString("Mobile number", comment: "")
        )
        field.delegate = self
        field.autocapitalizationType = UITextAutocapitalizationType.none
        field.inputAccessoryView = numberToolbar
        return field
    }()
    
    lazy var infoLabel:UILabel = {
        let padding:CGFloat = 45.0
        let labelWidth = self.view.bounds.size.width - 2*padding
        let utility = SLUtilities()
        let font = UIFont.systemFont(ofSize: 10)
        let text = NSLocalizedString(
            "We'll send you a confirmation code via SMS to validate your phone number.",
            comment: ""
        )
        let labelSize:CGSize = utility.sizeForLabel(
            font: font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.greatestFiniteMagnitude,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: padding,
            y: self.passwordField.frame.maxY + self.yFieldSpacer,
            width: labelSize.width,
            height: labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = self.textColor
        label.text = text
        label.textAlignment = .center
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
        
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(NSLocalizedString("SEND VERIFICATION CODE", comment: ""), for: .normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(startLoginProcedure),
            for: .touchDown
        )
        button.isHidden = true
        
        return button
    }()
    
    lazy var loginButton:UIButton = {
        let width = self.passwordField.bounds.size.width
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: self.passwordField.frame.maxY + self.yFieldSpacer,
            width: width,
            height: self.phoneNumberField.bounds.size.height
        )
        
        let title = self.currentPhase == .Create ?  NSLocalizedString("SIGN UP", comment: "") :
            NSLocalizedString("LOG IN", comment: "")
        let button:UIButton = UIButton(type: .system)
        button.frame = frame
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(
            self,
            action: #selector(startLoginProcedure),
            for: .touchDown
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
        button.addTarget(self, action: #selector(facebookButtonPressed), for: .touchDown)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    init(phase: SLCreateAccountFieldPhase) {
        self.currentPhase = phase
        super.init(nibName: nil, bundle: nil)
    }
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, phase: SLCreateAccountFieldPhase) {
        self.currentPhase = phase
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillShow,
            object: self,
            queue: nil,
            using: keyboardWillShow
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide,
            object: self,
            queue: nil,
            using: keyboardWillHide
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
                if field.isFirstResponder {
                    field.resignFirstResponder()
                    break
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func startLoginProcedure() {
        let ud:UserDefaults = UserDefaults.standard
        
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
        
        let userProperties:[String:Any] = [
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
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as! SLRestManager
        restManager.postObject(
        userProperties,
        serverKey: .main,
        pathKey: .users,
        subRoutes: nil,
        additionalHeaders: nil,
        completion: { (status: UInt, responseDict:[AnyHashable: Any]?) in
            print("Response from server after login request: \(responseDict))")
            guard let response:[String:AnyObject] = responseDict as? [String:AnyObject] else {
                print("response dictionary is not in the correct format")
                self.presentWarningController(errorType: .InternalServer)
                return
            }
            
            guard let userToken:String = response["token"] as? String else {
                print("no rest token in server response")
                self.presentWarningController(errorType: .InternalServer)
                return
            }
            
            let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
            dbManager.saveUser(with: userProperties, isFacebookUser: false)
            
            let currentUser:SLUser = (SLDatabaseManager.sharedManager() as! SLDatabaseManager).getCurrentUser()!
            let keyChainHandler = SLKeychainHandler()
            keyChainHandler.setItemForUsername(
                userName: currentUser.userId!,
                inputValue: userToken,
                additionalSeviceInfo: nil,
                handlerCase: .RestToken
            )
            
            if self.currentPhase == .SignIn {
                if status == 200 || status == 201 {
                    ud.set(true, forKey: "SLUserDefaultsSignedIn")
                    ud.synchronize()
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
                    self.presentWarningController(errorType: .SignInFailure)
                }
            } else {
                let subRoutes:[String] = [
                    currentUser.userId!,
                    restManager.path(asString: .phoneVerificaiton)
                ]
                
                let headers = [
                    "Authorization": restManager.basicAuthorizationHeaderValueUsername(userToken, password: "")
                ]
                
                restManager.getRequestWith(
                    .main,
                    pathKey: .users,
                    subRoutes: subRoutes,
                    additionalHeaders: headers,
                    completion: { (status: UInt, textResponseDict:[AnyHashable:Any]?) in
                        DispatchQueue.main.async {
                            let ctvc = SLConfirmTextCodeViewController()
                            self.present(ctvc, animated: true, completion: nil)
                        }
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
        return self.topLabel.frame.maxY + self.yFieldSpacer
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
    
    private func presentWarningController(errorType: ResponseError) {
        let info:String
        switch errorType {
        case .InternalServer:
            info = NSLocalizedString(
                "Sorry. We couldn't log you in right now. It looks like we're having problems on " +
                "our servers at the moment. Please try again later. You can also sign up using your Facebook account.",
                comment: ""
            )
        case .SignInFailure:
            info = NSLocalizedString(
                "Sorry. We couldn't log you in right now. Please check your info and try again. "
                    + "You can also sign up using your Facebook account.",
                comment: ""
            )
        }
        
        let texts:[SLWarningViewControllerTextProperty:String?] = [
            .Header: NSLocalizedString("Login Failed", comment: ""),
            .Info: info,
            .CancelButton: NSLocalizedString("OK", comment: ""),
            .ActionButton: nil
        ]
        
        self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
    }
    
    func setFieldErrorState(fieldName: FieldName, enterErrorMode: Bool) {
        let field:SLBoxTextField = self.fieldFromFieldName(fieldName: fieldName)
        if field.isInErrorMode() && !enterErrorMode {
            field.exitErrorMode()
        } else if !field.isInErrorMode() && enterErrorMode {
            if let text = self.errorText[fieldName] {
                field.enterErrorModeWithMessage(message: text)
            }
        }
    }
    
    func areFieldsValid() -> Bool {
        var allFieldsValid = true
        for (key, value) in self.fieldValues {
            // We don't need to validate email on sign in since there in no email field.
            if self.currentPhase == .SignIn && key == .Email {
                continue
            }
            
            var isValid = true
            if value == "" {
                isValid = false
                allFieldsValid = false
            } else if key == .Email && (!value.contains("@") || !value.contains(".")) {
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
            
            self.setFieldErrorState(fieldName: key, enterErrorMode: !isValid)
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
        let offset:CGFloat = firstField.frame.minY - self.exitButton.frame.maxY - 20.0
        
        return offset
    }
    
    func toolbarDoneButtonPressed() {
        self.phoneNumberField.resignFirstResponder()
    }
    
    func facebookButtonPressed() {
        let facebookManager:SLFacebookManger = SLFacebookManger.sharedManager() as! SLFacebookManger
        facebookManager.login(from: self) { (success) in
            if success {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "SLUserDefaultsSignedIn")
                userDefaults.synchronize()
                
                if SLLockManager.sharedManager.hasLocksForCurrentUser() {
                    let lvc = SLLockViewController()
                    self.present(lvc, animated: true, completion: nil)
                } else {
                    let clvc = SLConnectLockInfoViewController()
                    let navController:UINavigationController = UINavigationController(rootViewController: clvc)
                    self.present(navController, animated: true, completion: nil)
                }
            } else {
                let texts:[SLWarningViewControllerTextProperty:String?] = [
                    .Header: NSLocalizedString("Hmmm...Login Failed", comment: ""),
                    .Info: NSLocalizedString(
                        "Sorry. We couldn't log you in through Facebook right now. " +
                        "Please try again later, or you can sign in using your phone number and email.",
                        comment: ""
                    ),
                    .CancelButton: NSLocalizedString("OK", comment: ""),
                    .ActionButton: nil
                ]
                
                self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
            }
        }
    }
    
    func keyboardWillShow(notification: Notification) {
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
            self.keyboardFrame = endFrame.cgRectValue
        }
        
        UIView.animate(
            withDuration: duration.doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: curve.uintValue),
            animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: self.keyboardOffset())
                self.topLabel.alpha = 0.0
            },
            completion: nil
        )
    }
    
    func keyboardWillHide(notification: Notification) {
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
        self.sendTextButton.isHidden = !fieldsValidated
        
        let firstField = self.fields.first!
        let offset = firstField.frame.minY - self.firstFieldY0()
        UIView.animate(
            withDuration: duration.doubleValue,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: curve.uintValue),
            animations: {
                self.scrollView.contentOffset = CGPoint(x: 0, y: offset)
                self.topLabel.alpha = 1.0
            },
            completion: nil
        )
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let keyboardType:UIKeyboardType
        if textField == self.emailField {
            keyboardType = .emailAddress
        } else if textField == self.phoneNumberField {
            keyboardType = .numberPad
        } else {
            keyboardType = .default
        }
        
        if textField == self.passwordField {
            // Adding this line since the secure entry option erases all text in the field when
            // on the user's first keystroke
            self.fieldValues[.Password] = ""
            self.passwordField.text = ""
        }
        
        textField.keyboardType = keyboardType
        textField.returnKeyType = .done
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        
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
            let newText = tempText.replacingCharacters(in: range, with: string)
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
