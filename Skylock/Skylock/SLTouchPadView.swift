//
//  SLTouchPadView.swift
//  Skylock
//
//  Created by Andre Green on 9/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

enum SLTouchPadLocation {
    case None
    case Top
    case Right
    case Bottom
    case Left
    case Center
}

protocol SLTouchPadViewDelegate {
    func touchPadViewLocationSelected(touchPadViewController: SLTouchPadView, location:SLTouchPadLocation)
}

class SLTouchPadView: UIView {
    let buttonDiameter: CGFloat = 40.0
    let largeButtonDiameter: CGFloat = 80.0
    let buttonGreenColor = UIColor.color(110, green: 223, blue: 158)
    let buttonGreyColor = UIColor.color(216, green: 216, blue: 216)
    var delegate: SLTouchPadViewDelegate?
    
    lazy var topButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            0.5*(self.bounds.size.width - self.buttonDiameter),
            0,
            self.buttonDiameter,
            self.buttonDiameter
            )
        )
        button.addTarget(self, action: "touchPadButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
        button.backgroundColor = self.buttonGreyColor
        button.layer.cornerRadius = 0.5*self.buttonDiameter;
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            self.bounds.size.width - self.buttonDiameter,
            CGRectGetMidY(self.bounds) - 0.5*self.buttonDiameter,
            self.buttonDiameter,
            self.buttonDiameter
            )
        )
        //button.setBackgroundColor(self.buttonGreenColor, controlState: UIControlState.Normal)
        button.addTarget(self, action: "touchPadButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
        button.backgroundColor = self.buttonGreenColor
        button.layer.cornerRadius = 0.5*self.buttonDiameter;
        return button
    }()
    
    lazy var bottomButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            0.5*(self.bounds.size.width - self.buttonDiameter),
            self.bounds.size.height - self.buttonDiameter,
            self.buttonDiameter,
            self.buttonDiameter
            )
        )
        button.addTarget(self, action: "touchPadButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
        button.backgroundColor = self.buttonGreyColor
        button.layer.cornerRadius = 0.5*self.buttonDiameter;
        return button
    }()
    
    lazy var leftButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            0,
            CGRectGetMidY(self.bounds) - 0.5*self.buttonDiameter,
            self.buttonDiameter,
            self.buttonDiameter
            )
        )
        button.addTarget(self, action: "touchPadButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
        button.backgroundColor = self.buttonGreenColor
        button.layer.cornerRadius = 0.5*self.buttonDiameter;
        return button
    }()
    
    lazy var middleButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            CGRectGetMidX(self.bounds) - 0.5*self.largeButtonDiameter,
            CGRectGetMidY(self.bounds) - 0.5*self.largeButtonDiameter,
            self.largeButtonDiameter,
            self.largeButtonDiameter
            )
        )
        button.addTarget(self, action: "touchPadButtonPressed:", forControlEvents: UIControlEvents.TouchDown)
        button.backgroundColor = self.buttonGreyColor
        button.layer.cornerRadius = 0.5*self.largeButtonDiameter;
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.topButton)
        self.addSubview(self.rightButton)
        self.addSubview(self.bottomButton)
        self.addSubview(self.leftButton)
        self.addSubview(self.middleButton)
    }
    
    func touchPadButtonPressed(sender: UIButton) {
        println("touch pad button pressed")
        
        var location: SLTouchPadLocation?
        switch sender {
        case self.topButton:
            location = SLTouchPadLocation.Top
        case self.rightButton:
            location = SLTouchPadLocation.Right
        case self.bottomButton:
            location = SLTouchPadLocation.Bottom
        case self.rightButton:
            location = SLTouchPadLocation.Left
        case self.middleButton:
            location = SLTouchPadLocation.Center
        default:
            location = SLTouchPadLocation.None
        }
        
        self.delegate?.touchPadViewLocationSelected(self, location: location!)
    }
}
