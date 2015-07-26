//
// Created by Andre Green on 7/25/15.
// Copyright (c) 2015 Andre Green. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func color(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red:CGFloat(red)/255.0, green:CGFloat(green)/255.0, blue:CGFloat(blue)/255.0, alpha:1.0)
    }
}