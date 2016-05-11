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
    let labelFont = UIFont(name: "HelveticaNeue", size: 17)
    let titleColor = UIColor.color(97, green: 100, blue: 100)
    let infoColor = UIColor.color(128, green: 128, blue: 128)
    var underlineViews: [SLUnderlinedCharacterView] = []
    let minimumCodeNumber:Int = 4
    let maximunCodeNumber: Int = 8
    let spacingBetweenUnderLineViews:CGFloat = 5.0
    var delegate: SLTouchPadViewControllerDelegate?
    var letterIndex:Int = 0
    var pushes:[UInt8] = []
    lazy var infoLabel: UILabel = {
        let text: String = NSLocalizedString("Change Pin Code", comment: "")
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            self.labelFont!,
            text:text,
            maxWidth:self.view.bounds.size.width,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let y0 = self.navigationController == nil ? 20.0 :
                self.navigationController!.navigationBar.bounds.size.height +
                    UIApplication.sharedApplication().statusBarFrame.size.height + 20.0
        let label: UILabel = UILabel(frame: CGRectMake(
            0,
            y0,
            self.view.bounds.size.width,
            size.height
            )
        )
        label.text = text
        label.textColor = self.titleColor
        label.font = self.labelFont
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }()
    
    lazy var subInfoLabel: UILabel = {
        let text: String = NSLocalizedString(
            "Enter a new sequence of letters.\n" +
            "Between 4-8 taps required*\n" +
            "*4 is weak, 6 is moderate and 8 is safe",
            comment: ""
        )
        let font = UIFont(name: "HelveticaNeue", size: 15)!
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            font,
            text:text,
            maxWidth:self.view.bounds.size.width,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let label: UILabel = UILabel(frame: CGRectMake(
            0.5*(self.view.bounds.size.width - size.width),
            CGRectGetMaxY(self.infoLabel.frame) + 10.0,
            size.width,
            size.height
            )
        )
        label.text = text
        label.textColor = self.titleColor
        label.font = font
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var savePinButton: UIButton = {
        let image: UIImage = UIImage(named: "btn_savepin")!
        let y0:CGFloat
        if let underlineView = self.underlineViews.first {
            y0 = CGRectGetMaxY(underlineView.frame) + 30.0
        } else {
            y0 = self.self.view.bounds.size.height - image.size.height - 30.0
        }
        
        let underlineView = self.underlineViews[0]
        let button: UIButton = UIButton(frame: CGRectMake(
            0.5*(self.view.bounds.size.width - image.size.width),
            y0,
            image.size.width,
            image.size.height
            )
        )
        button.addTarget(self, action: #selector(savePinButtonPressed), forControlEvents: UIControlEvents.TouchDown)
        button.setImage(image, forState: UIControlState.Normal)
        button.enabled = false
        
        return button
    }()
    
    lazy var touchPadView: SLTouchPadView = {
        let height: CGFloat = 0.3*self.view.bounds.size.height;
        let padView: SLTouchPadView = SLTouchPadView(frame: CGRectMake(
            CGRectGetMidX(self.view.bounds) - 0.5*height,
            0.5*(self.view.bounds.size.height - height),
            height,
            height
            )
        )
        padView.delegate = self
        return padView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.addSubview(self.infoLabel)
        self.view.addSubview(self.subInfoLabel)
        self.view.addSubview(self.touchPadView)
        
        self.createUnderlineViews()
        
        for underlineView in self.underlineViews {
            self.view.addSubview(underlineView)
        }
        
        self.view.addSubview(self.savePinButton)
    }
    
    func createUnderlineViews() {
        let underLineViewWidth:CGFloat = 25.0
        var xPosition:CGFloat = 0.5*(self.view.bounds.size.width - CGFloat(self.maximunCodeNumber)*underLineViewWidth -
            CGFloat(self.maximunCodeNumber - 1)*self.spacingBetweenUnderLineViews)
        var index = 0
        while index < self.maximunCodeNumber {
            let frame:CGRect = CGRect(
                x: xPosition,
                y: CGRectGetMaxY(self.touchPadView.frame) + 35.0,
                width: underLineViewWidth,
                height: 30.0
            )
            let underlineView:SLUnderlinedCharacterView = SLUnderlinedCharacterView(frame: frame, letter: "")
            self.underlineViews.append(underlineView)
            
            xPosition += underLineViewWidth + self.spacingBetweenUnderLineViews
            index += 1
        }
    }
    
    func savePinButtonPressed() {
        print(self.pushes)
        let lockManager = SLLockManager.sharedManager()
        let lock = lockManager.getCurrentLock()
        lockManager.writeTouchPadButtonPushes(&self.pushes, size: Int32(self.pushes.count), lock:lock)
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func numberAndLetterForTouchPadLocation(location: SLTouchPadLocation) -> [UInt8:String] {
        let letter: String
        let number: UInt8
        switch location {
        case .Top:
            letter = NSLocalizedString("B", comment: "")
            number = 0x01
        case .Right:
            letter = NSLocalizedString("Y", comment: "")
            number = 0x02
        case .Bottom:
            letter = NSLocalizedString("X", comment: "")
            number = 0x04
        case .Left:
            letter = NSLocalizedString("A", comment: "")
            number = 0x08
        }
        
        return [number: letter]
    }
    
    // SLTouchPadView delegate methods
    func touchPadViewLocationSelected(touchPadViewController: SLTouchPadView, location: SLTouchPadLocation) {
        if self.letterIndex == self.maximunCodeNumber {
            return
        }
        
        let numberAndLetter = self.numberAndLetterForTouchPadLocation(location)
        guard let number = numberAndLetter.keys.first else {
            return
        }
        
        guard let letter = numberAndLetter.values.first else {
            return
        }
        
        self.pushes.append(number)
        let underlineView = self.underlineViews[self.letterIndex]
        underlineView.updateLetterLabel(letter)
        self.letterIndex += 1
        if letterIndex >= self.minimumCodeNumber && !self.savePinButton.enabled {
            self.savePinButton.enabled = true
        }
    }
}
