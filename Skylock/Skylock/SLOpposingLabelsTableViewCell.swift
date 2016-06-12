//
//  SLOposingLabelsTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 6/9/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLOpposingLabelsTableViewCell: UITableViewCell {
    let xPadding:CGFloat = 5.0
    let labelHeight:CGFloat = 14.0
    let labelFont:UIFont = UIFont.systemFontOfSize(12.0)
    var leftText:String?
    var rightText:String?
    var leftTextColor:UIColor?
    var rightTextColor:UIColor?
    
    lazy var leftLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 0.5*(self.contentView.bounds.size.height - self.labelHeight),
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = self.labelFont
        label.text = self.leftText
        label.textColor = self.leftTextColor
        
        return label
    }()
    
    lazy var rightLabel:UILabel = {
        let frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.5*(self.bounds.size.height - self.labelHeight),
            width: 0.5*self.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = self.labelFont
        label.text = self.rightText
        label.textColor = self.rightTextColor
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.leftLabel.frame = CGRect(
            x: self.xPadding,
            y: 0.5*(self.contentView.bounds.size.height - self.labelHeight),
            width: 0.5*self.contentView.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        self.rightLabel.frame = CGRect(
            x: 0.5*self.bounds.size.width,
            y: 0.5*(self.bounds.size.height - self.labelHeight),
            width: 0.5*self.bounds.size.width - self.xPadding,
            height: self.labelHeight
        )
        
        self.contentView.addSubview(self.leftLabel)
        self.contentView.addSubview(self.rightLabel)
    }
    
    func setProperties(leftLabelText:String, rightLabelText:String?, leftLabelTextColor:UIColor, rightLabelTextColor:UIColor) {
        
        self.leftLabel.text = leftLabelText
        self.leftLabel.textColor = leftLabelTextColor
        self.rightLabel.text = rightLabelText
        self.rightLabel.textColor = rightLabelTextColor
        
        self.leftLabel.setNeedsDisplay()
        self.rightLabel.setNeedsDisplay()
    }
}
