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
    
    lazy var pinEntryLabel:UILabel = {
        let xSpacer:CGFloat = 40.0
        let frame = CGRectMake(
            xSpacer,
            CGRectGetMaxY(self.subInfoLabel.frame) + 5.0,
            self.view.bounds.size.width - 2*xSpacer,
            38.0
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = ""
        label.textColor = UIColor(red: 155, green: 155, blue: 155)
        label.font = UIFont.systemFontOfSize(36)
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var deleteButton:UIButton = {
        let image:UIImage = UIImage(named: "button_backspace_Onboarding")!
        let frame = CGRect(
            x: CGRectGetMaxX(self.pinEntryLabel.frame) + 5.0,
            y: CGRectGetMinY(self.pinEntryLabel.frame) + 0.5*(self.pinEntryLabel.bounds.size.height - image.size.height),
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
            x: CGRectGetMinX(self.pinEntryLabel.frame),
            y: CGRectGetMaxY(self.pinEntryLabel.frame) + 3.0,
            width: self.pinEntryLabel.bounds.size.width,
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
        
        self.view.addSubview(self.xExitButton)
        self.view.addSubview(self.enterPinLabel)
        self.view.addSubview(self.deleteButton)
        self.view.addSubview(self.subInfoLabel)
        self.view.addSubview(self.pinEntryLabel)
        self.view.addSubview(self.underlineView)
        self.view.addSubview(self.savePinButton)
        self.view.addSubview(self.touchPadView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockCodeWritten),
            name: "kSLNotificationLockSequenceWritten",
            object: nil
        )
    }
    
    func savePinButtonPressed() {
        print(self.pushes)
        let lockManager = SLLockManager.sharedManager()
        let lock = lockManager.getCurrentLock()
        lockManager.writeTouchPadButtonPushes(&self.pushes, size: Int32(self.pushes.count), lock:lock)
    }
    
    func numberAndLetterForTouchPadLocation(location: SLTouchPadLocation) -> [UInt8:String] {
        let letter: String
        let number: UInt8
        switch location {
        case .Top:
            letter = NSLocalizedString("Y", comment: "")
            number = 0x01
        case .Right:
            letter = NSLocalizedString("B", comment: "")
            number = 0x02
        case .Bottom:
            letter = NSLocalizedString("A", comment: "")
            number = 0x04
        case .Left:
            letter = NSLocalizedString("X", comment: "")
            number = 0x08
        }
        
        return [number: letter]
    }
    
    func xExitButtonPressed() {
        
    }
    
    func deleteButtonPressed() {
        if var text:String = self.pinEntryLabel.text where text.characters.count > 0 {
            text.removeAtIndex(text.endIndex.advancedBy(-1))
            self.pinEntryLabel.text = text
            
            self.pushes.removeLast()
            
            if text.characters.count == 0 {
                self.deleteButton.hidden = true
            }
            
            if self.savePinButton.enabled && text.characters.count < self.minimumCodeNumber {
                self.savePinButton.enabled = false
            }
        }
    }
    
    func lockCodeWritten() {
        let lvc = SLLockViewController()
        self.presentViewController(lvc, animated: false) { 
            lvc.presentMapViewController(false)
        }
    }
    
    // SLTouchPadView delegate methods
    func touchPadViewLocationSelected(touchPadViewController: SLTouchPadView, location: SLTouchPadLocation) {
        if self.pinEntryLabel.text?.characters.count == self.maximunCodeNumber {
            return
        }
        
        let numberAndLetter = self.numberAndLetterForTouchPadLocation(location)
        guard let number = numberAndLetter.keys.first else {
            return
        }
        
        guard let letter = numberAndLetter.values.first else {
            return
        }
        
        if let text = self.pinEntryLabel.text {
            self.pinEntryLabel.text = text + letter
        } else {
            self.pinEntryLabel.text = letter
        }
        
        self.pushes.append(number)
        self.deleteButton.hidden = false
        if !self.savePinButton.enabled  && self.pinEntryLabel.text?.characters.count >= self.minimumCodeNumber {
            self.savePinButton.enabled = true
        }
    }

}
