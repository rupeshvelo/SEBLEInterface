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
    case OpenSansSemiBold = "OpenSans-SemiBold"
    case OpenSansBold = "OpenSans-Bold"
    case MontserratRegular = "Montserrat-Regular"
    case MonserratBold = "Montserrat-Bold"
    case YosemiteRegular = "System-San-Francisco-Display-Regular"
}

enum SLColor {
    case Color0_0_0
    case Color60_83_119
    case Color76_79_97
    case Color87_216_255
    case Color102_177_227
    case Color109_194_223
    case Color130_156_178
    case Color140_140_140
    case Color155_155_155
    case Color160_200_224
    case Color188_187_187
    case Color231_231_233
    case Color239_239_239
    case Color247_247_248
    case Color255_255_255
}

class SLUtilities: NSObject {
    func sizeForLabel(
        font: UIFont,
        text: String,
        maxWidth: CGFloat,
        maxHeight: CGFloat,
        numberOfLines: NSInteger
        ) -> CGSize
    {
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
        case .Color130_156_178:
            color = UIColor.color(130, green: 156, blue: 178)
        case .Color140_140_140:
            color = UIColor.color(140, green: 140, blue: 140)
        case .Color155_155_155:
            color = UIColor.color(155, green: 155, blue: 155)
        case .Color160_200_224:
            color = UIColor.color(160, green: 200, blue: 224)
        case .Color188_187_187:
            color = UIColor.color(188, green: 187, blue: 187)
        case .Color231_231_233:
            color = UIColor.color(231, green: 231, blue: 233)
        case .Color239_239_239:
            color = UIColor.color(239, green: 239, blue: 239)
        case .Color247_247_248:
            color = UIColor.color(247, green: 247, blue: 248)
        case .Color255_255_255:
            color = UIColor.whiteColor()
        }
        
        return color
    }
    
    func statusBarAndNavControllerHeight(viewController: UIViewController) -> CGFloat {
        return UIApplication.sharedApplication().statusBarFrame.height +
            (viewController.navigationController == nil ? 0.0 :
                viewController.navigationController!.navigationBar.frame.size.height)
    }
}
