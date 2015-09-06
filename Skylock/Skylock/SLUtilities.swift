//
//  SLUtilities.swift
//  Skylock
//
//  Created by Andre Green on 9/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

class SLUtilities: NSObject {
    func sizeForLabel(font: UIFont, text: String, maxWidth: CGFloat, maxHeight: CGFloat, numberOfLines: NSInteger) -> CGSize {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, maxWidth, maxHeight))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.bounds.size
    }
}
