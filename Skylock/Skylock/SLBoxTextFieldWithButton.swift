//
//  SLTextBoxFieldWithButton.swift
//  Skylock
//
//  Created by Andre Green on 7/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

protocol SLBoxTextFieldWithButtonDelegate:class {
    func showButtonToggledToShow(textField: SLBoxTextFieldWithButton, shouldShow: Bool)
}

class SLBoxTextFieldWithButton: SLBoxTextField {
    weak var textBoxDelegate: SLBoxTextFieldWithButtonDelegate?
    
    
    lazy var showButton:UIButton = {
        let width:CGFloat = 40.0
        let height:CGFloat = 30.0
        let frame = CGRect(
            x: self.bounds.size.width - width - 10.0,
            y: 0.5*(self.bounds.size.height - height),
            width: width,
            height: height
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.backgroundColor = UIColor.clearColor()
        button.setTitle(NSLocalizedString("SHOW", comment: ""), forState: .Normal)
        button.setTitle(NSLocalizedString("HIDE", comment: ""), forState: .Selected)
        button.setTitleColor(UIColor(red: 87, green: 216, blue: 255), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 10.0)
        button.addTarget(self, action: #selector(showButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.rightViewMode = UITextFieldViewMode.Always
        self.rightView = self.showButton
        self.rightView?.frame = CGRectOffset(self.rightView!.frame, -5.0, 0.0)
    }
    
    func showButtonPressed() {
        self.showButton.selected = !self.showButton.selected
        self.textBoxDelegate?.showButtonToggledToShow(self, shouldShow: self.showButton.selected)
    }
    
    override func exitErrorMode() {
        super.exitErrorMode()
        self.showButton.selected = self.secureTextEntry
        self.rightView = self.showButton
    }
}
