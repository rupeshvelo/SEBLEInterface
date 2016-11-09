//
//  SLModifySensitiveDataViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/4/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import CoreTelephony

enum SLModifySensitiveDataViewControllerType {
    case Password
    case PhoneNumber
}

class SLModifySensitiveDataViewController: SLBaseViewController, UITextFieldDelegate {
    
    private enum ResponseError {
        case InternalServer
    }
    
    let type:SLModifySensitiveDataViewControllerType
    
    let xPadding:CGFloat = 20.0
    
    let user:SLUser = (SLDatabaseManager.sharedManager() as! SLDatabaseManager).getCurrentUser()!
    
    let passwordLength = 8
    
    let phoneNumberLength = 12
    
    lazy var infoLabel:UILabel = {
        let font = UIFont.systemFont(ofSize: 9)
        let text = self.infoText()
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            font: font,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.greatestFiniteMagnitude,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - size.width),
            y: (self.navigationController == nil ? 0.0 : self.navigationController!.navigationBar.frame.maxY)
                + 30.0,
            width: size.width,
            height: size.height
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.font = font
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var textField:SLInsetTextField = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.infoLabel.frame.maxY + 50.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 50.0
        )
        
        let text:String
        let placeHolder:String
        var keyboardType:UIKeyboardType = .default
        switch self.type {
        case .PhoneNumber:
            text = self.user.phoneNumber == nil ? "" : self.user.phoneNumber!
            placeHolder = NSLocalizedString("Enter phone number", comment: "")
            keyboardType = .numberPad
        case .Password:
            text = NSLocalizedString("Password", comment: "")
            placeHolder = NSLocalizedString("Password", comment: "")
        }
        
        let field:SLInsetTextField = SLInsetTextField(frame: frame)
        field.text = text
        field.placeholder = placeHolder
        field.font = UIFont.systemFont(ofSize: 24)
        field.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        field.keyboardType = keyboardType
        field.borderStyle = .line
        field.isSecureTextEntry = self.type == .Password
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor(white: 151.0/255.0, alpha: 1.0).cgColor
        field.delegate = self
    
        return field
    }()
    
    lazy var saveButton:UIButton = {
        let height:CGFloat = 40.0
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - height - 20.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(saveButtonPressed), for: .touchDown)
        button.backgroundColor = UIColor.color(102, green: 177, blue: 227)
        button.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        
        return button
    }()
    
    init(type: SLModifySensitiveDataViewControllerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.textField)
        self.view.addSubview(self.saveButton)
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillShow,
            object: nil,
            queue: nil,
            using: keyboardWillShow
        )
    }

    private func presentWarningController(errorType: ResponseError) {
        let info:String
        switch errorType {
        case .InternalServer:
            info = NSLocalizedString(
                "Sorry. Error in Response",
                comment: ""
            )
            let texts:[SLWarningViewControllerTextProperty:String?] = [
                .Header: NSLocalizedString("Server Error", comment: ""),
                .Info: info,
                .CancelButton: NSLocalizedString("OK", comment: ""),
                .ActionButton: nil
            ]
            
            self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
        }
    }

    
    func infoText() -> String {
        let text:String
        switch self.type {
        case .Password:
            text = NSLocalizedString("Enter a new password", comment: "")
        case .PhoneNumber:
            text = NSLocalizedString(
                "You can change your phone number but we’ll need to send you an SMS " +
                "to verify your new number. You cannot undo this.",
                comment: ""
            )
        }
        
        return text
    }
    
    func doneButtonPressed() {
        self.textField.resignFirstResponder()
    }
    
    func saveButtonPressed() {
        var shouldSave = false
        if self.type == .Password && (self.textField.text?.characters.count)! >= self.passwordLength {
            // TODO: Handle the password case
            print("User has changed password")
            shouldSave = true
        } else if self.type == .PhoneNumber && (self.textField.text?.characters.count)! >= self.phoneNumberLength {
            self.user.phoneNumber = self.textField.text
            shouldSave = true
        }
        if shouldSave {
            self.updateProfileSettings(password: self.type == .Password ? self.textField.text! : "", phoneNumber: self.type == .PhoneNumber ? self.textField.text! : "")
        }
    }
    
    func keyboardWillShow(notification: Notification) {
        let doneButton:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    // MARK: UITextFieldDelegate methods
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
                                      replacementString string: String) -> Bool
    {
        if let text = textField.text {
            let tempText:NSString = text as NSString
            let newText = tempText.replacingCharacters(in: range, with: string)
            if self.type == .PhoneNumber {
                self.saveButton.isHidden = newText.characters.count < self.phoneNumberLength
                if newText == "" || newText[newText.startIndex] != "+" {
                    return false
                }
            } else if self.type == .Password {
                self.saveButton.isHidden = newText.characters.count > self.passwordLength
            }
        }
        
        return true
    }
    
    func updateProfileSettings(password: String, phoneNumber:String){
        let networkInfo:CTTelephonyNetworkInfo = CTTelephonyNetworkInfo()
        var countryCode:String? = ""
        if let providerInfo:CTCarrier = networkInfo.subscriberCellularProvider,
            let cc = providerInfo.isoCountryCode
        {
            countryCode = cc
        }
        let userProperties: [String: Any] = [
            "first_name" : "",
            "last_name" : "",
            "email":"",
            "password": password,
            "phone_number":phoneNumber,
            "country_code" : countryCode!
        ]
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        let restManager:SLRestManager = SLRestManager.sharedManager() as! SLRestManager
        let currentUser:SLUser = dbManager.getCurrentUser()!
        let subRoutes:[String] = [
            currentUser.userId!,
            restManager.path(asString: .profile)
        ]
        let keyChainHandler = SLKeychainHandler()
        let restToken = keyChainHandler.getItemForUsername(
            userName: currentUser.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .RestToken
        );
        let headers = [
            "Authorization": restManager.basicAuthorizationHeaderValueUsername(restToken!, password: "")
        ]
        restManager.postObject(
            userProperties,
            serverKey: SLRestManagerServerKey.main,
            pathKey: SLRestManagerPathKey.users,
            subRoutes: subRoutes,
            additionalHeaders: headers,
            completion: { (status: UInt, textResponseDict:[AnyHashable : Any]?) in
                DispatchQueue.main.async{
                    if status != 200 && status != 201 {
                        self.presentWarningController(errorType: .InternalServer)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        )
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        }
        
        return true
    }
}
