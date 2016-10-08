//
//  SLTouchPadView.swift
//  Skylock
//
//  Created by Andre Green on 9/3/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

enum SLTouchPadLocation {
    case top
    case right
    case bottom
    case left
}

protocol SLTouchPadViewDelegate:class {
    func touchPadViewLocationSelected(
        _ touchPadViewController: SLTouchPadView,
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
        let frame = CGRect(
            x: 0.5*(self.bounds.size.width - image.size.width),
            y: 0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            for: UIControlEvents.touchDown
        )
        button.setImage(image, for: UIControlState())
        
        return button
    }()
    
    lazy var rightButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_right_Onboarding")!
        let frame = CGRect(
            x: self.bounds.size.width - image.size.width,
            y: self.bounds.midY - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            for: UIControlEvents.touchDown
        )
        button.setImage(image, for: UIControlState())
        
        return button
    }()
    
    lazy var bottomButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_down_Onboarding")!
        let frame = CGRect(
            x: 0.5*(self.bounds.size.width - image.size.width),
            y: self.bounds.size.height - image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame:frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            for: UIControlEvents.touchDown
        )
        button.setImage(image, for: UIControlState())
        
        return button
    }()
    
    lazy var leftButton: UIButton = {
        let image:UIImage = UIImage(named: "button_keypad_left_Onboarding")!
        let frame = CGRect(
            x: 0,
            y: self.bounds.midY - 0.5*image.size.width,
            width: image.size.width,
            height: image.size.width
        )

        let button:UIButton = UIButton(frame: frame)
        button.addTarget(
            self,
            action: #selector(touchPadButtonPressed(_:)),
            for: UIControlEvents.touchDown
        )
        button.setImage(image, for: UIControlState())
        
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.topButton)
        self.addSubview(self.rightButton)
        self.addSubview(self.bottomButton)
        self.addSubview(self.leftButton)        
    }
    
    func touchPadButtonPressed(_ sender: UIButton) {        
        let location: SLTouchPadLocation
        switch sender {
        case self.topButton:
            location = .top
        case self.rightButton:
            location = .right
        case self.bottomButton:
            location = .bottom
        case self.leftButton:
            location = .left
        default:
            location = .top
        }
    
        self.delegate?.touchPadViewLocationSelected(self, location: location)
    }
}
