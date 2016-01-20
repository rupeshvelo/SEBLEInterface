//
//  SLWalkthroughCardView.swift
//  Skylock
//
//  Created by Andre Green on 1/3/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLWalkthroughCardView: UIView {
    let shadowColor = UIColor(red: 130, green: 130, blue: 130)
    var scaleFactor: CGFloat
    
    init(frame: CGRect, scaleFactor: CGFloat) {
        self.scaleFactor = scaleFactor
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.shadowColor = self.shadowColor.CGColor
        self.layer.shadowOffset = CGSizeMake(2, 2)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
        self.layer.cornerRadius = 5.0
    }
}
