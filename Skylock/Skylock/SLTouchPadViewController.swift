//
//  SLTouchPadViewController.swift
//  Skylock
//
//  Created by Andre Green on 8/30/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

protocol SLTouchPadViewControllerDelegate:class {
    func touchPadViewControllerWantsExit(touchPadViewController: SLTouchPadViewController)
}

class SLTouchPadViewController: UIViewController, SLTouchPadViewDelegate {
    let xPadding:CGFloat = 25.0
    
    let minimumCodeNumber:Int = 4
    
    let maximunCodeNumber: Int = 8
    
    weak var delegate: SLTouchPadViewControllerDelegate?
    
    var letterIndex:Int = 0
    
    var pushes:[UInt8] = []
    
    var onSaveExit:(() -> Void)?
    
    var onCanelExit:(() -> Void)?
    
    var arrowInputViews:[UIView] = [UIView]()
    
    var arrowButtonSize:CGSize = CGSizeZero
    
    let arrowViewSpacer:CGFloat = 3.0
    
    lazy var xExitButton:UIButton = {
        let image:UIImage = UIImage(named: "button_close_window_large_Onboarding")!
        let frame:CGRect = CGRect(
            x: self.view.bounds.size.width - image.size.width - 10.0,
            y: UIApplication.sharedApplication().statusBarFrame.size.height + 10.0,
            width: image.size.width,
            height: image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(
            self,
            action: #selector(xExitButtonPressed),
            forControlEvents: .TouchDown
        )
        
        return button
    }()
    
    lazy var subInfoLabel: UILabel = {
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)!
        let text: String = NSLocalizedString(
            "Enter a new sequence of letters between 4-8 taps. " +
            "*4 is weak, 6 is moderate,and 8 is safe.",
            comment: ""
        )
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            font,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let frame = CGRectMake(
            self.xPadding,
            utility.statusBarAndNavControllerHeight(self) + 40.0,
            size.width,
            size.height
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor(red: 160, green: 200, blue: 224)
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .Center
        
        return label
    }()
    
    lazy var pinEntryView:UIView = {
        let width = CGFloat(self.maximunCodeNumber) * (self.arrowButtonSize.width + self.arrowViewSpacer)
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - width),
            CGRectGetMaxY(self.subInfoLabel.frame) + 15.0,
            width,
            38.0
        )
        
        let view: UIView = UIView(frame: frame)
        
        return view
    }()
    
    lazy var deleteButton:UIButton = {
        let image:UIImage = UIImage(named: "button_backspace_Onboarding")!
        let frame = CGRect(
            x: CGRectGetMaxX(self.pinEntryView.frame) + 5.0,
            y: CGRectGetMidY(self.pinEntryView.frame) - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(deleteButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        button.hidden = true
        
        return button
    }()
    
    lazy var underlineView:UIView = {
        let frame = CGRect(
            x: CGRectGetMinX(self.pinEntryView.frame),
            y: CGRectGetMaxY(self.pinEntryView.frame) + 3.0,
            width: self.pinEntryView.bounds.size.width,
            height: 1
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(red: 151, green: 151, blue: 151)
        
        return view
    }()
    
    lazy var savePinButton: UIButton = {
        let padding:CGFloat = 15.0
        let height:CGFloat = 44.0
        let frame = CGRectMake(
            padding,
            self.view.bounds.size.height - height - 10.0,
            self.view.bounds.size.width - 2.0*padding,
            height
        )
        
        let button: UIButton = UIButton(type: .System)
        button.frame = frame
        button.addTarget(self, action: #selector(savePinButtonPressed), forControlEvents: UIControlEvents.TouchDown)
        button.setTitle(NSLocalizedString("SAVE PIN", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor.color(188, green: 187, blue: 187), forState: .Disabled)
        button.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        button.enabled = false
        
        return button
    }()
    
    lazy var touchPadView: SLTouchPadView = {
        let height:CGFloat = 250.0;
        let y0:CGFloat = CGRectGetMaxY(self.underlineView.frame) +
            0.5*(CGRectGetMinY(self.savePinButton.frame) - CGRectGetMaxY(self.underlineView.frame) - height)
        let frame = CGRectMake(
            CGRectGetMidX(self.view.bounds) - 0.5*height,
            y0,
            height,
            height
        )
        
        let padView: SLTouchPadView = SLTouchPadView(frame: frame)
        padView.delegate = self
        
        return padView
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = NSLocalizedString("ENTER A PIN CODE", comment: "")
        
        let arrowImage = UIImage(named: "button_keypad_up")!
        self.arrowButtonSize = arrowImage.size
        
        self.view.addSubview(self.xExitButton)
        self.view.addSubview(self.deleteButton)
        self.view.addSubview(self.subInfoLabel)
        self.view.addSubview(self.pinEntryView)
        self.view.addSubview(self.underlineView)
        self.view.addSubview(self.savePinButton)
        self.view.addSubview(self.touchPadView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockCodeWritten),
            name: kSLNotificationLockSequenceWritten,
            object: nil
        )
    }
    
    func savePinButtonPressed() {
        SLLockManager.sharedManager.writeTouchPadButtonPushes(self.pushes)
    }
    
    func numberAndImageNameForTouchPadLocation(location: SLTouchPadLocation) -> [UInt8:String] {
        let imageName: String
        let number: UInt8
        switch location {
        case .Top:
            imageName = "button_keypad_up"
            number = 0x01
        case .Right:
            imageName = "button_keypad_right"
            number = 0x02
        case .Bottom:
            imageName = "button_keypad_down"
            number = 0x04
        case .Left:
            imageName = "button_keypad_left"
            number = 0x08
        }
        
        return [number:imageName]
    }
    
    func xExitButtonPressed() {
        if self.onCanelExit != nil {
            self.onCanelExit!()
        }
    }
    
    func deleteButtonPressed() {
        if self.arrowInputViews.isEmpty {
            return
        }
        
        let lastView = self.arrowInputViews.popLast()!
        lastView.removeFromSuperview()
        
        self.pushes.removeLast()
        
        if self.pushes.count == 0 {
            self.deleteButton.hidden = true
        }
        
        if self.savePinButton.enabled && self.pushes.count < self.minimumCodeNumber {
            self.savePinButton.enabled = false
            self.savePinButton.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        }
    }
    
    func lockCodeWritten() {
        if self.onSaveExit != nil {
            self.onSaveExit!()
        }
    }
    
    func addImageToPinEntryView(imageName: String) {
        guard let image:UIImage = UIImage(named: imageName) else {
            return
        }
        
        let x0 = self.arrowInputViews.isEmpty ? 0.0 :
            CGFloat(self.arrowInputViews.count) * (arrowButtonSize.width + self.arrowViewSpacer)
        let frame = CGRect(
            x: x0,
            y: 0.5*(self.pinEntryView.bounds.size.height - self.arrowButtonSize.height),
            width: arrowButtonSize.width,
            height: arrowButtonSize.height
        )
        
        let view:UIView = UIView(frame: frame)
        
        let imageFrame = CGRect(
            x: 0.5*(view.bounds.size.width - image.size.width),
            y: 0.5*(view.bounds.size.height - image.size.height),
            width: image.size.width,
            height: image.size.height
        )
        
        let imageView:UIImageView = UIImageView(frame: imageFrame)
        imageView.image = image
        
        view.addSubview(imageView)
        self.pinEntryView.addSubview(view)
        
        self.arrowInputViews.append(view)
    }
    
    //MARK: SLTouchPadViewDelegate methods
    func touchPadViewLocationSelected(touchPadViewController: SLTouchPadView, location: SLTouchPadLocation) {
        if self.pushes.count == self.maximunCodeNumber {
            return
        }
        
        let numberAndImageName = self.numberAndImageNameForTouchPadLocation(location)
        guard let number = numberAndImageName.keys.first else {
            return
        }
        
        guard let imageName = numberAndImageName.values.first else {
            return
        }
        
        self.addImageToPinEntryView(imageName)
        self.pushes.append(number)
        self.deleteButton.hidden = false
        if !self.savePinButton.enabled  && self.arrowInputViews.count >= self.minimumCodeNumber {
            self.savePinButton.enabled = true
            self.savePinButton.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        }
    }
}
