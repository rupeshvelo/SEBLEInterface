//
//  SLFirmwareUpdateViewController.swift
//  Ellipse
//
//  Created by Andre Green on 8/8/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
enum SLFirmwareUpdateStage {
    case Available
    case InProgress
    case Finished
}

class SLFirmwareUpdateViewController: UIViewController, SLWarningViewControllerDelegate {
    let xPadding:CGFloat = 25.0
    
    let buttonHeight:CGFloat = 55.0
    
    let backgroundViewTag:Int = 1056
    
    var stage:SLFirmwareUpdateStage = .Available
    
    let updateText:[SLFirmwareUpdateStage:String] = [
        .Available: NSLocalizedString("Frimware update available", comment: ""),
        .InProgress: NSLocalizedString("Firmware update in progress", comment: ""),
        .Finished: NSLocalizedString("All Done! Restarting your Ellipse...", comment: "")
    ]
    
    // This should be passed in in the initialzer once it is implemnted on the server
    let newFeatures:[String] = [String]()
    
    lazy var updateLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: 100.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 17.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.text = self.updateText[self.stage]
        label.textColor = UIColor.whiteColor()
        
        return label
    }()
    
    lazy var progressLabel:UILabel = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.updateLabel.frame) + 20.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 17.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 11.0)
        label.text = NSLocalizedString("Progress", comment: "") + "..."
        label.textColor = UIColor.whiteColor()
        label.hidden = self.stage == .Available
        
        return label
    }()
    
    lazy var progressBar:SLFirmwareUpdateProgressBarView = {
        let frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.progressLabel.frame) + 5.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 10.0
        )
        
        let bar:SLFirmwareUpdateProgressBarView = SLFirmwareUpdateProgressBarView(frame: frame)
        bar.hidden = true
        
        return bar
    }()
    
    lazy var updateLaterButton:UIButton = {
        let frame = CGRectMake(
            0.0,
            self.view.bounds.size.height - self.buttonHeight,
            0.5*self.view.bounds.size.width,
            self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("LATER", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor(red: 188, green: 187, blue: 187), forState: .Normal)
        button.backgroundColor = UIColor(red: 231, green: 231, blue: 233)
        button.addTarget(self, action: #selector(updateLaterButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var updateNowButton:UIButton = {
        let frame = CGRectMake(
            0.5*self.view.bounds.size.width,
            self.view.bounds.size.height - self.buttonHeight,
            0.5*self.view.bounds.size.width,
            self.buttonHeight
        )
        
        let button:UIButton = UIButton(type: .System)
        button.frame = frame
        button.setTitle(NSLocalizedString("UPDATE NOW", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.backgroundColor = UIColor(red: 87, green: 216, blue: 255)
        button.addTarget(self, action: #selector(updateNowButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.view.addSubview(self.updateLabel)
        self.view.addSubview(self.progressLabel)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.updateLaterButton)
        self.view.addSubview(self.updateNowButton)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(updateFirmware(_:)),
            name: kSLNotificationLockManagerFirmwareUpdateState,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(firmwareUpdateComplete(_:)),
            name: kSLNotificationLockManagerEndedFirmwareUpdate,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(disconnectedLock(_:)),
            name: kSLNotificationLockManagerDisconnectedLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(lockPaired(_:)),
            name: kSLNotificationLockPaired,
            object: nil
        )
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setFirmwareStage(stage: SLFirmwareUpdateStage) {
        self.stage = stage
        self.updateViewsForStage()
    }
    
    func updateViewsForStage() {
        self.progressBar.hidden = self.stage == .Available
    }
    
    func updateLaterButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateNowButtonPressed() {
        self.stage = .InProgress
        self.updateLabel.text = self.updateText[self.stage]
        self.progressLabel.hidden = false
        self.progressBar.hidden = false
        self.updateNowButton.hidden = true
        self.updateLaterButton.hidden = true
        SLLockManager.sharedManager.updateFirmwareForCurrentLock()
    }
    
    func updateFirmware(notification: NSNotification) {
        guard let progress = notification.object as? NSNumber else {
            return
        }
        
        self.progressBar.updateBarWithRatio(progress.doubleValue)
    }
    
    func firmwareUpdateComplete(notification: NSNotification) {
        self.updateLabel.text = self.updateText[.Finished]
    }
    
    func disconnectedLock(notification: NSNotification) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func lockPaired(notification: NSNotification) {
        let backgroundView:UIView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor(white: 0.2, alpha: 0.75)
        backgroundView.tag = self.backgroundViewTag
        
        self.view.addSubview(backgroundView)
        
        let width:CGFloat = 268.0
        let height:CGFloat = 211.0
        
        let wvc:SLWarningViewController = SLWarningViewController(
            headerText: NSLocalizedString("Firmware updated", comment: ""),
            infoText: NSLocalizedString("The firmware on your ellipse has been updated.", comment: ""),
            cancelButtonTitle: NSLocalizedString("OK", comment: ""),
            actionButtonTitle: nil
        )
        
        wvc.view.frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - width),
            y: 0.5*(self.view.bounds.size.height - height),
            width: width,
            height: height
        )
        wvc.delegate = self
        
        self.addChildViewController(wvc)
        self.view.addSubview(wvc.view)
        self.view.bringSubviewToFront(wvc.view)
        wvc.didMoveToParentViewController(wvc)
    }
    
    // MARK: SLWarningViewControllerDelegate Methods
    func warningVCTakeActionButtonPressed(wvc: SLWarningViewController) {
        // This method should not be used as we only have a cancel button in the
        // warning view contoller
    }
    
    func warningVCCancelActionButtonPressed(wvc: SLWarningViewController) {
        var backgroundView:UIView?
        for view in self.view.subviews {
            if view.tag == self.backgroundViewTag {
                backgroundView = view
                break
            }
        }
        
        if let background = backgroundView {
            UIView.animateWithDuration(0.2, animations: {
                wvc.view.alpha = 0.0
                background.alpha = 0.0
            }) { (finished) in
                wvc.view.removeFromSuperview()
                wvc.removeFromParentViewController()
                wvc.view.removeFromSuperview()
                background.removeFromSuperview()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            print("Error: could not find background view while removing warning view controller")
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
