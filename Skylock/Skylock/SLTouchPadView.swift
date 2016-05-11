//
//  SLTouchPadView.swift
//  Skylock
//
//  Created by Andre Green on 9/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

enum SLTouchPadLocation {
    case Top
    case Right
    case Bottom
    case Left
}

protocol SLTouchPadViewDelegate {
    func touchPadViewLocationSelected(
        touchPadViewController: SLTouchPadView,
        location:SLTouchPadLocation
    )
}

class SLTouchPadView: UIView {
    let buttonDiameter: CGFloat = 40.0
    let largeButtonDiameter: CGFloat = 80.0
    let buttonGreenColor = UIColor.color(110, green: 223, blue: 158)
    let buttonGreyColor = UIColor.color(216, green: 216, blue: 216)
    let font = UIFont(name: "Helvetica Neue", size: 28)
    var delegate: SLTouchPadViewDelegate?
    
    lazy var topButton: UIButton = {
        let button:UIButton = UIButton(frame: CGRectMake(
            0.5*(self.bounds.size.width - self.buttonDiameter),
            0,
            self.buttonDiameter,
            self.buttonDiameter
            )
        )
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setTitle(NSLocalizedString("B", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(self.buttonGreenColor, forState: UIControlState.Normal)
        button.titleLabel?.font = self.font
        
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
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setTitle(NSLocalizedString("Y", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(self.buttonGreenColor, forState: UIControlState.Normal)
        button.titleLabel?.font = self.font
        
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
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setTitle(NSLocalizedString("X", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(self.buttonGreenColor, forState: UIControlState.Normal)
        button.titleLabel?.font = self.font
        
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
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setTitle(NSLocalizedString("A", comment: ""), forState: UIControlState.Normal)
        button.setTitleColor(self.buttonGreenColor, forState: UIControlState.Normal)
        button.titleLabel?.font = self.font
        
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.topButton)
        self.addSubview(self.rightButton)
        self.addSubview(self.bottomButton)
        self.addSubview(self.leftButton)
    }
    
    func touchPadButtonPressed(sender: UIButton) {
        print("touch pad button pressed")
        
        let location: SLTouchPadLocation
        switch sender {
        case self.topButton:
            location = SLTouchPadLocation.Top
        case self.rightButton:
            location = SLTouchPadLocation.Right
        case self.bottomButton:
            location = SLTouchPadLocation.Bottom
        case self.leftButton:
            location = SLTouchPadLocation.Left
        default:
            print("Error: Button did not map to SLTouchPadLocation")
            return;
        }
    
        self.delegate?.touchPadViewLocationSelected(self, location: location)
    }
}
