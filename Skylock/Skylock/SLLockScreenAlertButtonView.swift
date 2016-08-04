//
//  SLLockScreenAlertButtonView.swift
//  Skylock
//
//  Created by Andre Green on 6/23/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockScreenAlertButton: UIButton {
    let xSpacer:CGFloat = 5
    
    init(activeImageName: String, inactiveImageName:String, titleText: String, textColor:UIColor) {
        let activeImage = UIImage(named: activeImageName)!
        let inactiveImage = UIImage(named: inactiveImageName)!
        
        let utility = SLUtilities()
        let font = UIFont(name: SLFont.MonserratBold.rawValue, size: 9.0)!
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: titleText,
            maxWidth: CGFloat.max,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: activeImage.size.width + self.xSpacer + labelSize.width,
            height: activeImage.size.height
        )
        
        super.init(frame: frame)

        self.setTitle(titleText, forState: .Normal)
        self.setTitleColor(textColor, forState: .Selected)
        self.setTitleColor(textColor.colorWithAlphaComponent(0.4), forState: .Normal)
        self.titleLabel?.font = font
        self.contentVerticalAlignment = .Center
        self.contentHorizontalAlignment = .Center
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.setImage(activeImage, forState: .Selected)
        self.setImage(inactiveImage, forState: .Normal)
//        self.imageEdgeInsets = UIEdgeInsets(
//            top: 0,
//            left: 0.5*(self.bounds.size.width - (self.imageView?.bounds.size.width)!),
//            bottom: 0,
//            right: 0
//        )
//        self.titleEdgeInsets = UIEdgeInsets(
//            top: (self.imageView?.bounds.size.height)! + self.ySpacer,
//            left: -0.5*frame.size.width - 10.0,
//            bottom: 0,
//            right: 0
//        )
//        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 5.0,
            bottom: 0,
            right: 0
        )
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
