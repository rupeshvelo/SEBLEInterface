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

class SLCreateAccountViewController: UIViewController {
    var textFieldSize:CGSize = CGSizeZero
    let xPadding:CGFloat = 15.0
    let textColor = UIColor(red: 102, green: 177, blue: 227)
    let yFieldSpacer:CGFloat = 20.0
    var currentPhase:SLCreateAccountFieldPhase
    
    lazy var createAccountLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 88.0,
            width: self.view.bounds.size.width - self.xPadding,
            height: 32.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = NSLocalizedString("Create an account", comment: "")
        label.textColor = self.textColor
        label.font = UIFont.systemFontOfSize(32.0)
        
        return label
    }()
    
    lazy var firstNameField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.createAccountLabel.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("First Name", comment: "")
        
        return field
    }()
    
    lazy var lastNameField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.firstNameField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("Last Name", comment: "")
        
        return field
    }()
    
    lazy var emailField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.lastNameField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("Email", comment: "")
        
        return field
    }()
    
    lazy var passwordField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.emailField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("Password", comment: "")
        
        return field
    }()
    
    lazy var confirmPasswordField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.passwordField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        
        return field
    }()
    
    lazy var phoneNumberPrefixField:SLUnderlineTextView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.confirmPasswordField.frame) + self.yFieldSpacer,
            width: 45.0,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("+", comment: "")
        
        return field
    }()
    
    lazy var phoneNumberField:SLUnderlineTextView = {
        let xSpacer:CGFloat = 10.0
        let frame = CGRect(
            x: CGRectGetMaxX(self.phoneNumberPrefixField.frame) + xSpacer,
            y: CGRectGetMaxY(self.confirmPasswordField.frame) + self.yFieldSpacer,
            width: self.textFieldSize.width - self.phoneNumberPrefixField.bounds.size.width - xSpacer,
            height: self.textFieldSize.height
        )
        
        let field:SLUnderlineTextView = SLUnderlineTextView(frame: frame, color: self.textColor)
        field.textField.placeholder = NSLocalizedString("Phone Number", comment: "")
        
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
            CGRectGetMaxY(self.phoneNumberField.frame) + 2*self.yFieldSpacer,
            labelWidth,
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
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, phase: SLCreateAccountFieldPhase) {
        self.currentPhase = phase
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.textFieldSize = CGSize(
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 20.0
        )
        
        self.view.addSubview(self.createAccountLabel)
        self.view.addSubview(self.firstNameField)
        self.view.addSubview(self.lastNameField)
        self.view.addSubview(self.emailField)
        self.view.addSubview(self.passwordField)
        self.view.addSubview(self.confirmPasswordField)
        self.view.addSubview(self.phoneNumberPrefixField)
        self.view.addSubview(self.phoneNumberField)
        self.view.addSubview(self.infoLabel)
    }
    
    func getFields() -> [SLUnderlineTextView] {
        let currentViews:[SLUnderlineTextView]
        switch self.currentPhase {
        case .Create:
            currentViews = [
                self.firstNameField,
                self.lastNameField,
                self.emailField,
                self.passwordField,
                self.confirmPasswordField,
                self.phoneNumberPrefixField,
                self.phoneNumberField
            ]
        case .SignIn:
            currentViews = [
                self.emailField,
                self.passwordField,
                self.phoneNumberPrefixField,
                self.phoneNumberField
            ]
        }
        
        return currentViews
    }
    
    func getTextFieldsSectionHeight() -> CGFloat {
        let currentFields = self.getFields()
        var height:CGFloat = 0.0
        for (index, field) in currentFields.enumerate() {
            height += field.bounds.size.height + (index == currentFields.count ? 0.0 : self.yFieldSpacer)
        }
        
        return height
    }
    
    
}
