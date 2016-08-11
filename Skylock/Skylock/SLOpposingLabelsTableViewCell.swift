//
//  SLOposingLabelsTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 6/9/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

protocol SLOpposingLabelsTableViewCellDelegate:class {
    func opposingLabelsCellTextFieldBecameFirstResponder(cell: SLOpposingLabelsTableViewCell)
}

class SLOpposingLabelsTableViewCell: UITableViewCell, UITextFieldDelegate {
    let xPadding:CGFloat = 5.0
    
    let labelHeight:CGFloat = 14.0
    
    let labelFont:UIFont = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
    
    weak var delegate:SLOpposingLabelsTableViewCellDelegate?
    
    var isEditable:Bool = true
    
    var showArrow:Bool = false
    
    lazy var leftLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 0.0,
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.contentView.bounds.size.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.OpenSansSemiBold.rawValue, size: 14)
        label.text = ""
        
        return label
    }()
    
    lazy var rightField:UITextField = {
        let frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.0,
            width: 0.5*self.bounds.size.width - self.xPadding,
            height: self.contentView.bounds.size.height
        )
        
        let field:UITextField = UITextField(frame: frame)
        field.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14)
        field.text = ""
        field.textAlignment = .Right
        field.delegate = self
        
        return field
    }()
    
    lazy var arrowView:UIImageView = {
        let image:UIImage = UIImage(named: "lock_settings_right_arrow")!
        let imageView = UIImageView(image: image)
        
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.showArrow {
            self.accessoryView = self.arrowView
        }
        
        self.leftLabel.frame = CGRect(
            x: self.xPadding,
            y: 0.0,
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.contentView.bounds.size.height
        )
        
        let width = self.showArrow ?
            0.5*self.bounds.size.width - self.arrowView.bounds.size.width - self.xPadding - 20.0 :
            0.5*self.bounds.size.width - self.xPadding
        self.rightField.frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.0,
            width: width,
            height: self.contentView.bounds.size.height
        )
        
        self.contentView.addSubview(self.leftLabel)
        self.contentView.addSubview(self.rightField)
    }
    
//    override func setSelected(selected: Bool, animated: Bool) {
//        let view:UIView = UIView(frame: self.bounds)
//        //view.backgroundColor = UIColor.clearColor()
//        view.backgroundColor = UIColor.redColor()
//        self.selectedBackgroundView = view
//    }
    
    func setProperties(
        leftLabelText:String,
        rightLabelText:String?,
        leftLabelTextColor:UIColor,
        rightLabelTextColor:UIColor,
        shouldEnableTextField: Bool
        )
    {
        self.leftLabel.text = leftLabelText
        self.leftLabel.textColor = leftLabelTextColor
        self.rightField.text = rightLabelText
        self.rightField.textColor = rightLabelTextColor
        self.rightField.enabled = shouldEnableTextField
    }
    
    func haveFieldResignFirstReponder() {
        self.rightField.resignFirstResponder()
    }
    
    func isTextFieldFirstResponder() -> Bool {
        return self.rightField.isFirstResponder()
    }
    
    func setTextFieldEnabled(shouldEnable: Bool) {
        self.rightField.enabled = shouldEnable
    }
    
    func haveFieldBecomeFirstResponder() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.rightField.becomeFirstResponder()
        }
    }
    
    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        self.delegate?.opposingLabelsCellTextFieldBecameFirstResponder(self)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
       textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return self.isEditable
    }
}
