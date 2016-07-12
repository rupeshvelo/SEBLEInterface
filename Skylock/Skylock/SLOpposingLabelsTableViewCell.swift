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
    
    let labelFont:UIFont = UIFont.systemFontOfSize(12.0)
    
    weak var delegate:SLOpposingLabelsTableViewCellDelegate?
    
    lazy var leftLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 0.5*(self.contentView.bounds.size.height - self.labelHeight),
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = self.labelFont
        label.text = ""
        
        return label
    }()
    
    lazy var rightField:UITextField = {
        let frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.5*(self.bounds.size.height - self.labelHeight),
            width: 0.5*self.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        let field:UITextField = UITextField(frame: frame)
        field.font = self.labelFont
        field.text = ""
        field.textAlignment = .Right
        field.delegate = self
        
        return field
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.leftLabel.frame = CGRect(
            x: self.xPadding,
            y: 0.5*(self.contentView.bounds.size.height - self.labelHeight),
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        self.rightField.frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.5*(self.bounds.size.height - self.labelHeight),
            width: 0.5*self.bounds.size.width - self.xPadding,
            height: self.labelHeight
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
}
