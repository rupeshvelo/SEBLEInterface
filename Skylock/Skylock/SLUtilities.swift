//
//  SLUtilities.swift
//  Skylock
//
//  Created by Andre Green on 9/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

enum SLFont:String {
    case OpenSansRegular = "OpenSans"
    case MontserratRegular = "Montserrat-Regular"
}

enum SLColor {
    case Color0_0_0
    case Color60_83_119
    case Color76_79_97
    case Color87_216_255
    case Color102_177_227
    case Color109_194_223
    case Color155_155_155
    case Color231_231_233
    case Color239_239_239
    case Color255_255_255
}

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
    
    func color(colorCode: SLColor) -> UIColor {
        let color:UIColor
        switch colorCode {
        case .Color0_0_0:
            color = UIColor.blackColor()
        case .Color60_83_119:
            color = UIColor.color(60, green: 83, blue: 119)
        case .Color76_79_97:
            color = UIColor.color(76, green: 79, blue: 97)
        case .Color87_216_255:
            color = UIColor.color(87, green: 216, blue: 255)
        case .Color102_177_227:
            color = UIColor.color(102, green: 177, blue: 227)
        case .Color109_194_223:
            color = UIColor.color(109, green: 194, blue: 223)
        case .Color155_155_155:
            color = UIColor.color(155, green: 155, blue: 155)
        case .Color231_231_233:
            color = UIColor.color(231, green: 231, blue: 233)
        case .Color239_239_239:
            color = UIColor.color(239, green: 239, blue: 239)
        case .Color255_255_255:
            color = UIColor.whiteColor()
        }
        
        return color
    }
}
