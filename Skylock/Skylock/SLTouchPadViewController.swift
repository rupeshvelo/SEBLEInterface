//
//  SLTouchPadViewController.swift
//  Skylock
//
//  Created by Andre Green on 8/30/15.
//  Copyright (c) 2015 Andre Green. All rights reserved.
//

import UIKit

protocol SLTouchPadViewControllerDelegate {
    func touchPadViewControllerWantsExit(touchPadViewController: SLTouchPadViewController)
}

class SLTouchPadViewController: UIViewController, SLTouchPadViewDelegate {
    let xPadding:CGFloat = 25.0
    let minimumCodeNumber:Int = 4
    let maximunCodeNumber: Int = 8
    var delegate: SLTouchPadViewControllerDelegate?
    var letterIndex:Int = 0
    var pushes:[UInt8] = []
    var onExit:(() -> Void)?
    var arrowInputViews:[UIView] = [UIView]()
    var arrowButtonSize:CGSize = CGSizeZero
    
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
    
    lazy var enterPinLabel: UILabel = {
        let font = UIFont.systemFontOfSize(20)
        let text: String = NSLocalizedString("Enter PIN code", comment: "")
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            font,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - size.width),
            CGRectGetMaxY(self.xExitButton.frame) + 25.0,
            size.width,
            size.height
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.font = font
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var subInfoLabel: UILabel = {
        let font = UIFont.systemFontOfSize(10)
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
            CGRectGetMaxY(self.enterPinLabel.frame) + 11.0,
            size.width,
            size.height
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor(red: 146, green: 148, blue: 151)
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var pinEntryView:UIView = {
        let width = CGFloat(self.maximunCodeNumber) * self.arrowButtonSize.width
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - width),
            CGRectGetMaxY(self.subInfoLabel.frame) + 5.0,
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
            y: CGRectGetMinY(self.subInfoLabel.frame) + 0.5*(self.pinEntryView.bounds.size.height - image.size.height),
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
        let disabledImage:UIImage = UIImage(named: "button_save_inactive_Onboarding")!
        let image: UIImage = UIImage(named: "button_save_Onboarding")!
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - image.size.width),
            self.view.bounds.size.height - image.size.height - 20.0,
            image.size.width,
            image.size.height
        )
        
        let button: UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(savePinButtonPressed), forControlEvents: UIControlEvents.TouchDown)
        button.setImage(image, forState: UIControlState.Normal)
        button.setImage(disabledImage, forState: UIControlState.Disabled)
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
        
        self.setArrowButtonSize()

        self.view.addSubview(self.xExitButton)
        self.view.addSubview(self.enterPinLabel)
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
    
    func setArrowButtonSize() {
        guard let upArrowImage:UIImage = UIImage(named: "touch_pad_up_arrow") else {
            return
        }
        
        guard let rightArrowImage:UIImage = UIImage(named: "touch_pad_right_arrow") else {
            return
        }
        
        self.arrowButtonSize = CGSize(
            width: upArrowImage.size.width,
            height: rightArrowImage.size.height
        )
    }
    
    func savePinButtonPressed() {
        let lockManager = SLLockManager.sharedManager()
        let lock = lockManager.getCurrentLock()
        lockManager.writeTouchPadButtonPushes(
            &self.pushes,
            size: Int32(self.pushes.count),
            lock:lock
        )
    }
    
    func numberAndImageNameForTouchPadLocation(location: SLTouchPadLocation) -> [UInt8:String] {
        let imageName: String
        let number: UInt8
        switch location {
        case .Top:
            imageName = "touch_pad_up_arrow"
            number = 0x01
        case .Right:
            imageName = "touch_pad_right_arrow"
            number = 0x02
        case .Bottom:
            imageName = "touch_pad_down_arrow"
            number = 0x04
        case .Left:
            imageName = "touch_pad_left_arrow"
            number = 0x08
        }
        
        return [number:imageName]
    }
    
    func xExitButtonPressed() {
        if let exitClosure = self.onExit {
            exitClosure()
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
        }
    }
    
    func lockCodeWritten() {
        if self.onExit != nil {
            self.onExit!()
        }
    }
    
    func addImageToPinEntryView(imageName: String) {
        guard let image:UIImage = UIImage(named: imageName) else {
            return
        }
        
        let xSpacer:CGFloat = 0.0
        let x0 = self.arrowInputViews.isEmpty ? 0.0 :
            CGFloat(self.arrowInputViews.count) * (self.arrowButtonSize.width + xSpacer)
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
        }
    }
}
