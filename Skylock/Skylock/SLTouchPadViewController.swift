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
    
    var arrowButtonSize:CGSize = CGSize.zero
    
    let arrowViewSpacer:CGFloat = 3.0
    
    lazy var xExitButton:UIButton = {
        let image:UIImage = UIImage(named: "button_close_window_large_Onboarding")!
        let frame:CGRect = CGRect(
            x: self.view.bounds.size.width - image.size.width - 10.0,
            y: UIApplication.shared.statusBarFrame.size.height + 10.0,
            width: image.size.width,
            height: image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.setImage(image, for: UIControlState.normal)
        button.addTarget(
            self,
            action: #selector(xExitButtonPressed),
            for: .touchDown
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
            font: font,
            text:text,
            maxWidth:self.view.bounds.size.width - 2*self.xPadding,
            maxHeight: CGFloat.greatestFiniteMagnitude,
            numberOfLines: 0
        )
        
        let frame = CGRect(
            x: self.xPadding,
            y: utility.statusBarAndNavControllerHeight(viewController: self) + 40.0,
            width: size.width,
            height: size.height
        )
        
        let label: UILabel = UILabel(frame: frame)
        label.text = text
        label.textColor = UIColor(red: 160, green: 200, blue: 224)
        label.font = font
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var pinEntryView:UIView = {
        let width = CGFloat(self.maximunCodeNumber) * (self.arrowButtonSize.width + self.arrowViewSpacer)
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: self.subInfoLabel.frame.maxY + 15.0,
            width: width,
            height: 38.0
        )
        
        let view: UIView = UIView(frame: frame)
        
        return view
    }()
    
    lazy var deleteButton:UIButton = {
        let image:UIImage = UIImage(named: "button_backspace_Onboarding")!
        let frame = CGRect(
            x: self.pinEntryView.frame.maxX + 5.0,
            y: self.pinEntryView.frame.midY - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(deleteButtonPressed), for: .touchDown)
        button.setImage(image, for: .normal)
        button.isHidden = true
        
        return button
    }()
    
    lazy var underlineView:UIView = {
        let frame = CGRect(
            x: self.pinEntryView.frame.minX,
            y: self.pinEntryView.frame.maxY + 3.0,
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
        let frame = CGRect(
            x: padding,
            y: self.view.bounds.size.height - height - 10.0,
            width: self.view.bounds.size.width - 2.0*padding,
            height: height
        )
        
        let button: UIButton = UIButton(type: .system)
        button.frame = frame
        button.addTarget(self, action: #selector(savePinButtonPressed), for: UIControlEvents.touchDown)
        button.setTitle(NSLocalizedString("SAVE PIN", comment: ""), for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.color(188, green: 187, blue: 187), for: .disabled)
        button.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        button.isEnabled = false
        
        return button
    }()
    
    lazy var touchPadView: SLTouchPadView = {
        let height:CGFloat = 250.0;
        let y0:CGFloat = self.underlineView.frame.maxY +
            0.5*(self.savePinButton.frame.minY - self.underlineView.frame.maxY - height)
        let frame = CGRect(
            x: self.view.bounds.midX - 0.5*height,
            y: y0,
            width: height,
            height: height
        )
        
        let padView: SLTouchPadView = SLTouchPadView(frame: frame)
        padView.delegate = self
        
        return padView
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(lockCodeWritten),
            name: NSNotification.Name(rawValue: kSLNotificationLockSequenceWritten),
            object: nil
        )
    }
    
    func savePinButtonPressed() {
        SLLockManager.sharedManager.writeTouchPadButtonPushes(touches: self.pushes)
    }
    
    func numberAndImageNameForTouchPadLocation(location: SLTouchPadLocation) -> [UInt8:String] {
        let imageName: String
        let number: UInt8
        switch location {
        case .top:
            imageName = "button_keypad_up"
            number = 0x01
        case .right:
            imageName = "button_keypad_right"
            number = 0x02
        case .bottom:
            imageName = "button_keypad_down"
            number = 0x04
        case .left:
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
            self.deleteButton.isHidden = true
        }
        
        if self.savePinButton.isEnabled && self.pushes.count < self.minimumCodeNumber {
            self.savePinButton.isEnabled = false
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
    func touchPadViewLocationSelected(_ touchPadViewController: SLTouchPadView, location: SLTouchPadLocation) {
        if self.pushes.count == self.maximunCodeNumber {
            return
        }
        
        let numberAndImageName = self.numberAndImageNameForTouchPadLocation(location: location)
        guard let number = numberAndImageName.keys.first else {
            return
        }
        
        guard let imageName = numberAndImageName.values.first else {
            return
        }
        
        self.addImageToPinEntryView(imageName: imageName)
        self.pushes.append(number)
        self.deleteButton.isHidden = false
        if !self.savePinButton.isEnabled  && self.arrowInputViews.count >= self.minimumCodeNumber {
            self.savePinButton.isEnabled = true
            self.savePinButton.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        }
    }
}
