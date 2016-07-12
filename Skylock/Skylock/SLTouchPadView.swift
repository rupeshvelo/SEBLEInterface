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

protocol SLTouchPadViewDelegate:class {
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
    weak var delegate: SLTouchPadViewDelegate?
    
    lazy var topButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_up_Onboarding")!
        let frame = CGRectMake(
            0.5*(self.bounds.size.width - image.size.width),
            0,
            image.size.width,
            image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_right_Onboarding")!
        let frame = CGRectMake(
            self.bounds.size.width - image.size.width,
            CGRectGetMidY(self.bounds) - 0.5*image.size.height,
            image.size.width,
            image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var bottomButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_down_Onboarding")!
        let frame = CGRectMake(
            0.5*(self.bounds.size.width - image.size.width),
            self.bounds.size.height - image.size.height,
            image.size.width,
            image.size.height
        )
        
        let button:UIButton = UIButton(frame:frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var leftButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_left_Onboarding")!
        let frame = CGRectMake(
            0,
            CGRectGetMidY(self.bounds) - 0.5*image.size.width,
            image.size.width,
            image.size.width
        )

        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            forControlEvents: UIControlEvents.TouchDown
        )
        button.setImage(image, forState: .Normal)
        
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
            location = .Top
        case self.rightButton:
            location = .Right
        case self.bottomButton:
            location = .Bottom
        case self.leftButton:
            location = .Left
        default:
            location = .Top
        }
    
        self.delegate?.touchPadViewLocationSelected(self, location: location)
    }
}
