//
//  SLConcentricCirclesViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLConcentricCirclesViewController: UIViewController {
    enum CircleViewKey {
        case Color
        case View
    }
    
    let maxColor:Int = 216
    let minColor:Int = 50
    var circleIntialDiameter:CGFloat = 0.0
    var circleFinalDiameter:CGFloat = 0.0
    var circleViews:[[String:AnyObject]] = [[String:AnyObject]]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.circleIntialDiameter = 10.0
        self.circleFinalDiameter = 1.5*self.view.bounds.size.height
        
        let circleView = self.createCircleView()
        self.view.addSubview(circleView)
        self.growView(circleView)
    }
    
    func growView(circle: UIView) {
        UIView.animateWithDuration(5.0, animations: {
                circle.transform = CA
                circle.frame = self.circleEndFrame()
                circle.backgroundColor = self.greyForColorValue(self.minColor)
            }) { (finished) in
                self.view.removeFromSuperview()
                circle.backgroundColor = self.greyForColorValue(self.maxColor)
                circle.frame = self.circleStartFrame()
        }
    }
    
    func circleStartFrame() -> CGRect {
        return CGRect(
            x: 0.5*(self.view.bounds.size.width - self.circleIntialDiameter),
            y: 0.5*(self.view.bounds.size.height - self.circleIntialDiameter),
            width: self.circleIntialDiameter,
            height: self.circleIntialDiameter
        )
    }
    
    func circleEndFrame() -> CGRect {
        return CGRect(
            x: 0.5*(self.view.bounds.size.width - self.circleFinalDiameter),
            y: 0.5*(self.view.bounds.size.height - self.circleFinalDiameter),
            width: self.circleFinalDiameter,
            height: self.circleFinalDiameter
        )
    }
    
    func createCircleView() -> UIView {
        let circleView:UIView = UIView(frame: self.circleStartFrame())
        circleView.backgroundColor = self.greyForColorValue(self.maxColor)
        circleView.layer.cornerRadius = 0.5*self.circleIntialDiameter
        circleView.clipsToBounds = true
        
        return circleView
    }
    
    func greyForColorValue(colorValue: Int) -> UIColor {
        return UIColor(red: colorValue, green: colorValue, blue: colorValue)
    }
}
