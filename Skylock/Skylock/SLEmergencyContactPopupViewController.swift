//
//  SLEmergencyContactPopupViewController.swift
//  Skylock
//
//  Created by Andre Green on 4/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLEmergencyContactPopupViewController: UIViewController {
    let xPadding:CGFloat = 15.0
    let yPadding:CGFloat = 15.0
    
    lazy var emergencyContactsHeaderLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString("Emergency Contacts", comment: "")
        let font = UIFont(name:"Helvetica", size:18)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            self.xPadding,
            self.yPadding,
            size.width,
            size.height
        )
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 97, green: 100, blue: 100)
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var emergencyContactsHeaderSubLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString("Strongly Recomended", comment: "")
        let font = UIFont(name:"Helvetica", size:12)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.emergencyContactsHeaderLabel.frame) + 10,
            size.width,
            size.height
        )
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 146, green: 148, blue: 151)
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var topDividerView:UIView = {
        let frame = CGRectMake(
            0,
            CGRectGetMaxY(self.emergencyContactsHeaderSubLabel.frame) + 10,
            self.view.bounds.size.width,
            1
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 236, green: 236, blue: 236)
        
        return view
    }()
    
    lazy var topMainLabel: UILabel = {
        let utility: SLUtilities = SLUtilities()
        
        let text = NSLocalizedString(
            "Select up to 3 loved ones an Automatic agent should call " +
            "if you’re in a crash. You can edit them any time.",
            comment: ""
        )
        let font = UIFont(name:"Helvetica", size:12)
        let size = utility.sizeForLabel(
            font!,
            text: text,
            maxWidth: self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMaxY(self.topDividerView.frame) + 10,
            size.width,
            size.height
        )
        let label:UILabel = UILabel(frame: frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(red: 97, green: 100, blue: 100)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
}
