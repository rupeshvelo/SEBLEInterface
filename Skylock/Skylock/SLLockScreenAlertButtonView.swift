//
//  SLLockScreenAlertButtonView.swift
//  Skylock
//
//  Created by Andre Green on 6/23/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockScreenAlertButton: UIButton {
    let ySpacer:CGFloat = 5
    
    init(activeImageName: String, inactiveImageName:String, titleText: String) {
        
        let activeImage = UIImage(named: activeImageName)!
        let inactiveImage = UIImage(named: inactiveImageName)!
        
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(9)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: titleText,
            maxWidth: CGFloat.max,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: labelSize.width > activeImage.size.width ? labelSize.width : activeImage.size.width,
            height: activeImage.size.height + labelSize.height + self.ySpacer
        )
        
        super.init(frame: frame)

        self.setTitle(titleText, forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        self.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.6), forState: .Normal)
        self.titleLabel?.font = font
        self.contentVerticalAlignment = .Top
        self.contentHorizontalAlignment = .Center
        self.titleLabel?.numberOfLines = 1
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        self.setImage(activeImage, forState: .Selected)
        self.setImage(inactiveImage, forState: .Normal)
        self.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0.5*(self.bounds.size.width - (self.imageView?.bounds.size.width)!),
            bottom: 0,
            right: 0
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: (self.imageView?.bounds.size.height)! + self.ySpacer,
            left: -0.5*frame.size.width - 10.0,
            bottom: 0,
            right: 0
        )
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
