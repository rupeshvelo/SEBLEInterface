//
//  SLLockBarViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/27/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

private enum LockState {
    case Locked
    case Unlocked
    case Disconnected
}

private enum Element {
    case TapActionText
    case LockImageName
    case LockNameText
}

class SLLockBarViewController: UIViewController {
    private var lock:SLLock?
    
    private let xPadding:CGFloat = 10.0
    
    private lazy var lockNameLabel:UILabel = {
        let width = 0.5*self.view.bounds.size.width - self.xPadding
        let height:CGFloat = 20.0
        let font = UIFont.systemFontOfSize(16)
        let frame = CGRectMake(
            self.xPadding,
            0.5*(self.view.bounds.size.height - height),
            width,
            height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = self.lock?.displayName()
        label.textAlignment = NSTextAlignment.Left
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var lockImageView:UIImageView = {
        // TODO: get the unlocked image
        let image:UIImage = UIImage(named: "thin-0632_security_lock")!
        let frame = CGRect(
            x: self.view.bounds.size.width - image.size.width - self.xPadding,
            y: 0.5*(self.view.bounds.size.height - image.size.height),
            width: image.size.width,
            height: image.size.height
        )
        let imageView:UIImageView = UIImageView(frame: frame)
        imageView.image = image
        
        return imageView
    }()
    
    private lazy var tapActionLabel:UILabel = {
        let width = 0.5*self.view.bounds.size.width - self.xPadding - self.lockImageView.bounds.size.width
        let height:CGFloat = 20.0
        let font = UIFont.systemFontOfSize(18)
        let frame = CGRectMake(
            0.5*self.view.bounds.size.width,
            0.5*(self.view.bounds.size.height - height),
            width,
            height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = NSLocalizedString("TAP TO UNLOCK", comment: "")
        label.textAlignment = .Left
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 102, green: 177, blue: 227)
        
        let tgr:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(lockBarTapped))
        tgr.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tgr)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(lockOpened(_:)),
            name: kSLNotificationLockOpened,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(lockLocked(_:)),
            name: kSLNotificationLockClosed,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(lockDisconneted(_:)),
            name: kSLNotificationLockManagerDisconnectedLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockPaired(_:)),
            name: kSLNotificationLockPaired,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockDisconneted(_:)),
            name: kSLNotificationRemoveLockForUser,
            object: nil
        )
    }
    
    func setUpViews() {
        self.lock = SLLockManager.sharedManager().getCurrentLock()
        
        if !self.view.subviews.contains(self.lockNameLabel) {
            self.view.addSubview(self.lockNameLabel)
        }
        
        if !self.view.subviews.contains(self.lockImageView) {
            self.view.addSubview(self.lockImageView)
        }
        
        if !self.view.subviews.contains(self.tapActionLabel) {
            self.view.addSubview(self.tapActionLabel)
        }
        
        if let lock = self.lock {
            if lock.isLocked.boolValue {
                self.setUpForLockedState()
            } else {
                self.setUpForUnlockedState()
            }
        } else {
            self.setUpForDisconnectedState()
        }
    }
    
    private func currentElementState() -> LockState {
        guard let lock = self.lock else {
            return .Disconnected
        }
        
        return lock.isLocked.boolValue ? .Locked : .Unlocked
    }
    
    private func valueForLockState(lockState: LockState, element: Element) -> String {
        let value:String
        switch lockState {
        case .Locked:
            switch element {
            case .TapActionText:
                value = NSLocalizedString("TAP TO UNLOCK", comment: "")
            case .LockImageName:
                value = "thin-0632_security_lock"
            case .LockNameText:
                value = self.lock!.displayName()
            }
        case .Unlocked:
            switch element {
            case .TapActionText:
                value = NSLocalizedString("TAP TO LOCK", comment: "")
            case .LockImageName:
                value = "thin-0632_security_lock"
            case .LockNameText:
                value = self.lock!.displayName()
            }
        case .Disconnected:
            switch element {
            case .TapActionText:
                value = ""
            case .LockImageName:
                value = ""
            case .LockNameText:
                value = NSLocalizedString("No Ellipse connected", comment: "")
            }
        }
        
        return value
    }
    
    private func setUpForDisconnectedState() {
        self.lockImageView.image = UIImage(named: self.valueForLockState(.Disconnected, element: .LockImageName))
        self.lockNameLabel.text = self.valueForLockState(.Disconnected, element: .LockNameText)
        self.tapActionLabel.text = self.valueForLockState(.Disconnected, element: .TapActionText)
    }
    
    private func setUpForLockedState() {
        self.lockImageView.image = UIImage(named: self.valueForLockState(.Locked, element: .LockImageName))
        self.lockNameLabel.text = self.valueForLockState(.Locked, element: .LockNameText)
        self.tapActionLabel.text = self.valueForLockState(.Locked, element: .TapActionText)
    }
    
    private func setUpForUnlockedState() {
        self.lockImageView.image = UIImage(named: self.valueForLockState(.Unlocked, element: .LockImageName))
        self.lockNameLabel.text = self.valueForLockState(.Unlocked, element: .LockNameText)
        self.tapActionLabel.text = self.valueForLockState(.Unlocked, element: .TapActionText)
    }
    
    @objc private func lockBarTapped() {
        guard let lock = self.lock else {
            return
        }
        
        SLLockManager.sharedManager().setLockStateForLock(lock)
    }
    
    @objc private func lockOpened(notification: NSNotification) {
        if self.lock == nil {
            self.setUpForDisconnectedState()
        } else {
            self.setUpForUnlockedState()
        }
    }
    
    @objc private func lockLocked(notification: NSNotification) {
        if self.lock == nil {
            self.setUpForDisconnectedState()
        } else {
            self.setUpForUnlockedState()
        }
    }
    
    @objc private func lockDisconneted(notification: NSNotification) {
        // TODO Set up view to handl when there is no lock
        guard let notificationObject = notification.object as? [String: String] else {
            return
        }
        
        guard let disconnectedAddress = notificationObject["lockName"] else {
            return
        }
        
        if let currentLock = self.lock where disconnectedAddress == currentLock.macAddress {
            self.lock = nil
            self.setUpForDisconnectedState()
        }
    }
    
    @objc private func lockPaired(notification: NSNotification) {
        let lockManager = SLLockManager.sharedManager() as! SLLockManager
        if let lock:SLLock = lockManager.getCurrentLock() {
            self.lock = lock
            lockManager.checkLockOpenOrClosed()
        }
    }
}
