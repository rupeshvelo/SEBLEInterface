//
//  SLLockViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

@objc class SLLockViewController:
UIViewController,
SLSlideViewControllerDelegate,
SLLocationManagerDelegate,
SLAcceptNotificationsViewControllerDelegate
{
    let xPadding:CGFloat = 13.0
    
    var lock:SLLock?
    
    let lockManager:SLLockManager = SLLockManager.sharedManager() as! SLLockManager
    
    var isMapShowing:Bool = false
    
    var lockBarViewController:SLLockBarViewController?
    
    lazy var acceptNotificationViewController:SLAcceptNotificationsViewController = {
        let anvc:SLAcceptNotificationsViewController = SLAcceptNotificationsViewController()
        anvc.delegate = self
        
        return anvc
    }()
    
    lazy var locationManager:SLLocationManager = {
        let locManager:SLLocationManager = SLLocationManager()
        locManager.delegate = self
        
        return locManager
    }()
    
    lazy var menuButton:UIButton = {
        let image:UIImage = UIImage(named: "lock_screen_hamburger_menu")!
        let frame = CGRect(
            x: self.xPadding,
            y: UIApplication.sharedApplication().statusBarFrame.size.height + 20.0,
            width: 2*image.size.width,
            height: 2*image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(menuButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
    lazy var lockNameLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let font = UIFont.systemFontOfSize(18)
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelWidth),
            CGRectGetMaxY(self.menuButton.frame) + 45.0,
            labelWidth,
            20.0
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = self.lock?.displayName()
        label.textAlignment = .Left
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var underLineView:UIView = {
        let frame = CGRect(
            x: CGRectGetMinX(self.lockNameLabel.frame),
            y: CGRectGetMaxY(self.lockNameLabel.frame) + 4.0,
            width: self.lockNameLabel.bounds.size.width,
            height: 1.0
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.whiteColor()
        
        return view
    }()
    
    lazy var crashButton:SLLockScreenAlertButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_crash_detection_button",
            inactiveImageName: "lock_screen_crash_detection_button_inactive",
            titleText: NSLocalizedString("Crash detection", comment: ""),
            textColor: UIColor.whiteColor()
        )
        button.frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.underLineView.frame) + 15.0,
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(crashButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var theftButton:UIButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_theft_detection_button",
            inactiveImageName: "lock_screen_theft_detection_button_inactive",
            titleText: NSLocalizedString("Theft detection", comment: ""),
            textColor: UIColor.whiteColor()
        )
        button.frame = CGRect(
            x: CGRectGetMaxX(self.crashButton.frame) + 30.0,
            y: CGRectGetMinY(self.crashButton.frame),
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(theftButtonPressed), forControlEvents: .TouchDown)
        
        return button
    }()
    
    lazy var tempStatsView:UIImageView = {
        let image:UIImage = UIImage(named: "temp_phone_info")!
        let frame = CGRectMake(
            self.view.bounds.size.width - image.size.width - self.xPadding,
            CGRectGetMidY(self.theftButton.frame) - 0.5*image.size.height,
            image.size.width,
            image.size.height
        )
        
        let imageView:UIImageView = UIImageView(image: image)
        imageView.frame = frame
        
        return imageView
    }()
    
    lazy var lockStateLabel:UILabel = {
        let labelWidth = self.view.bounds.size.width - 2*self.xPadding
        let font = UIFont.systemFontOfSize(34)
        let height:CGFloat = 36.0
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelWidth),
            self.view.bounds.size.height - 40.0 - height,
            labelWidth,
            height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = NSLocalizedString("NOT CONNECTED", comment: "")
        label.textAlignment = .Center
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var lockButton:UIButton = {
        let lockedImage:UIImage = UIImage(named: "lock_unlocked_button")!
        let unlockImage:UIImage = UIImage(named: "lock_locked_button")!
        let disabledImage:UIImage = UIImage(named: "lock_disconnected_button")!
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - lockedImage.size.width),
            CGRectGetMinY(self.lockStateLabel.frame) - lockedImage.size.height - 14.0,
            lockedImage.size.width,
            lockedImage.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(lockButtonPressed), forControlEvents: .TouchDown)
        button.setImage(lockedImage, forState: .Normal)
        button.setImage(unlockImage, forState: .Selected)
        button.setImage(disabledImage, forState: .Disabled)
        button.enabled = false

        return button
    }()
    
    lazy var thinkerViewController:SLThinkerViewController = {
        let tvc:SLThinkerViewController = SLThinkerViewController(
            topText: "Top Text",
            bottomText: "Bottom Text",
            firstBackgroundColor: UIColor.whiteColor(),
            secondBackgroundColor: UIColor(red: 102, green: 177, blue: 227),
            foregroundColor: UIColor(red: 60, green: 83, blue: 119),
            inActiveBackgroundColor: UIColor(red: 130, green: 156, blue: 178)
        )
        
        return tvc
    }()
    
    lazy var mapViewController:SLMapViewController = {
        let mvc:SLMapViewController = SLMapViewController()
        return mvc
    }()
    
    lazy var slideViewController:SLSlideViewController = {
        let slvc = SLSlideViewController()
        slvc.delegate = self
        
        return slvc
    }()
    
    lazy var touchCatcherView:UIView = {
        let tgr:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(touchCatcherViewTapped)
        )
        
        let view:UIView = UIView(frame: self.view.bounds)
        view.addGestureRecognizer(tgr)
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 60, green: 83, blue: 119)
        
        self.lock = self.lockManager.getCurrentLock()
        self.locationManager.beginUpdatingLocation()
        
        self.view.addSubview(self.menuButton)
        self.view.addSubview(self.lockNameLabel)
        self.view.addSubview(self.underLineView)
        self.view.addSubview(self.crashButton)
        self.view.addSubview(self.theftButton)
        self.view.addSubview(self.tempStatsView)
        self.view.addSubview(self.lockStateLabel)
        self.view.addSubview(self.lockButton)
        
        self.registerForNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lockManager.checkLockOpenOrClosed()
        self.showAcceptNotificaitonViewController()
        
        if !self.view.subviews.contains(self.thinkerViewController.view) {
            let diameter:CGFloat = 223.0
            self.thinkerViewController.view.frame = CGRect(
                x: 0,
                y: 0,
                width: diameter,
                height: diameter
            )
            self.thinkerViewController.view.center = self.lockButton.center
            
            self.addChildViewController(self.thinkerViewController)
            self.view.addSubview(self.thinkerViewController.view)
            self.view.bringSubviewToFront(self.thinkerViewController.view)
            self.thinkerViewController.didMoveToParentViewController(self)
        }
        
        self.thinkerViewController.setState(.ClockwiseMoving)
    }
    
    func registerForNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(crashTurnedOn(_:)),
            name: "kSLNotificationLedTurnedOn",
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(crashTurnedOff(_:)),
            name: kSLNotificationLedTurnedOff,
            object: nil
        )
        
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
            #selector(showLockBar(_:)),
            name: kSLNotificationShowLockBar,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(hideLockBar(_:)),
            name: kSLNotificationHideLockBar,
            object: nil
        )
    }
    
    func showAcceptNotificaitonViewController() {
        let ud = NSUserDefaults.standardUserDefaults();
        if let isComplete:Bool = ud.boolForKey(SLUserDefaultsOnBoardingComplete) {
            if !isComplete {
                self.presentViewController(
                    self.acceptNotificationViewController,
                    animated: true,
                    completion: nil
                )
            }
        } else {
            self.presentViewController(
                self.acceptNotificationViewController,
                animated: true,
                completion: nil
            )
        }
    }
    
    func menuButtonPressed() {
        let width:CGFloat = self.view.bounds.size.width - 80.0
        self.slideViewController.view.frame = CGRect(
            x: -width,
            y: 0.0,
            width: width,
            height: self.view.bounds.size.height
        )
        
        self.addChildViewController(self.slideViewController)
        self.view.addSubview(self.slideViewController.view)
        self.view.bringSubviewToFront(self.slideViewController.view)
        self.slideViewController.didMoveToParentViewController(self)
        
        UIView.animateWithDuration(0.4, animations: {
            self.slideViewController.view.frame = CGRect(
                x: 0.0,
                y: 0.0,
                width: width,
                height: self.view.bounds.size.height
            )
        }) { (finished) in
            self.view.insertSubview(
                self.touchCatcherView,
                belowSubview: self.slideViewController.view
            )
        }
    }
    
    func theftButtonPressed() {
        if self.lock != nil && !self.crashButton.selected {
            // remove the following line of code. The crash state of the lock 
            // should be set in the callback not here. Just using for testing/demo purpose
            self.lock?.isSecurityOn = NSNumber(bool: !(self.lock?.isSecurityOn.boolValue)!)
            self.lockManager.toggleSecurityForLock(self.lock)
        }
    }
    
    func crashButtonPressed() {
        if self.lock != nil && !self.theftButton.selected {
            self.lockManager.toggleCrashForLock(self.lock)
        }
    }
    
    func lockButtonPressed() {
        if let lock:SLLock = self.lock {
            self.lockManager.setLockStateForLock(lock)
        }
    }
    
    func lockOpened(notification: NSNotification) {
        self.lockButton.enabled = true
        self.lockButton.selected = false
        if let lock = self.lock {
            lock.isLocked = NSNumber(bool: false)
        }
        
        self.lockStateLabel.text = self.lockStateText()
    }
    
    func lockLocked(notification: NSNotification) {
        self.lockButton.enabled = true
        self.lockButton.selected = true
        if let lock = self.lock {
            lock.isLocked = NSNumber(bool: true)
        }
        
        self.lockStateLabel.text = self.lockStateText()
    }
    
    func lockRemoved(notification: NSNotification) {
        self.setLockDisabled()
    }
    
    func crashTurnedOn(notification: NSNotification) {
        self.crashButton.selected = true
        self.lock?.isCrashOn = NSNumber(bool: true)
    }
    
    func crashTurnedOff(notification: NSNotification) {
        self.crashButton.selected = false
        self.lock?.isCrashOn = NSNumber(bool: false)
    }
    
    func lockPaired(notification: NSNotification) {
        if let lock:SLLock = self.lockManager.getCurrentLock() {
            self.lock = lock
            self.lockNameLabel.setNeedsDisplay()
            self.lockManager.checkLockOpenOrClosed()
            self.lockButton.enabled = true
            self.lockStateLabel.text = self.lockStateText()
            self.lockNameLabel.textColor = UIColor.whiteColor()
        }
    }
    
    func lockDisconneted(notification: NSNotification) {
        // TODO Set up view to handl when there is no lock
        guard let notificationObject = notification.object as? [String: String] else {
            return
        }
        
        guard let disconnectedAddress = notificationObject["lockName"] else {
            return
        }
    
        if self.lock == nil {
            print("lock is nil")
        } else {
            print("lock address is: \(self.lock!.macAddress)")
        }
        
        if let currentLock = self.lock where disconnectedAddress == currentLock.macAddress {
            self.setLockDisabled()
        } else if self.lockManager.getCurrentLock() == nil {
            self.setLockDisabled()
        }
    }
    
    func showLockBar(notification: NSNotification) {
        if let lbvc = self.lockBarViewController {
            self.view.bringSubviewToFront(lbvc.view)
        } else if let presentedVC = self.presentedViewController {
            if let lbvc = self.lockBarViewController {
                presentedVC.view.bringSubviewToFront(lbvc.view)
            } else {
                let height:CGFloat = 48.0
                self.lockBarViewController = SLLockBarViewController()
                self.lockBarViewController!.view.frame = CGRect(
                    x: 0.0,
                    y: self.view.bounds.size.height,
                    width: self.view.bounds.size.width,
                    height: height
                )
                presentedVC.addChildViewController(self.lockBarViewController!)
                presentedVC.view.addSubview(self.lockBarViewController!.view)
                presentedVC.view.bringSubviewToFront(self.lockBarViewController!.view)
                self.lockBarViewController!.didMoveToParentViewController(presentedVC)
                
                UIView.animateWithDuration(0.4, animations: {
                    self.lockBarViewController!.view.frame = CGRect(
                        x: 0.0,
                        y: self.view.bounds.size.height - height,
                        width: self.view.bounds.size.width,
                        height: height
                    )}, completion:{(success) in
                        self.lockBarViewController!.setUpViews()
                    }
                )
            }
        }
    }
    
    func hideLockBar(notification: NSNotification) {
        if let lbvc = self.lockBarViewController {
            lbvc.view.removeFromSuperview()
            lbvc.removeFromParentViewController()
            lbvc.view.removeFromSuperview()
            self.lockBarViewController = nil
        }
    }
    
    func setLockDisabled() {
        self.lock = nil
        self.lockButton.enabled = false
        self.lockButton.selected = false
        self.lockStateLabel.text = self.lockStateText()
        self.lockNameLabel.text = ""
        // Insert move views to disabled mode here
    }
    
    func lockStateText() -> String {
        let text:String
        if let lock = self.lock {
            if lock.isLocked.boolValue {
                text = NSLocalizedString("Tap to unlock", comment: "")
            } else {
                text = NSLocalizedString("Tap to lock", comment: "")
            }
        } else {
            text = NSLocalizedString("NOT CONNECTED", comment: "")
        }
        
        return text
    }
    
    func touchCatcherViewTapped() {
        self.isMapShowing = false
        UIView.animateWithDuration(0.4, animations: {
            self.slideViewController.view.frame = CGRect(
                x: -self.slideViewController.view.bounds.size.width,
                y: 0.0,
                width: self.slideViewController.view.bounds.size.width,
                height: self.slideViewController.view.bounds.size.height
            )
        }) { (finished) in
            self.slideViewController.view.removeFromSuperview()
            self.slideViewController.removeFromParentViewController()
            self.touchCatcherView.removeFromSuperview()
        }
    }
    
    func presentViewControllerWithNavigationController(viewController: UIViewController) {
        //let transitionHandler = SLViewControllerTransitionHandler()
        let nc:UINavigationController
        if let navController = self.navigationController {
            navController.pushViewController(viewController, animated: true)
        } else {
            nc = UINavigationController(rootViewController: viewController)
            self.presentViewController(nc, animated: true, completion: nil)
        }

        //nc.modalPresentationStyle = .Custom
        //nc.transitioningDelegate = transitionHandler
        
    }
    
    func lockBarHeight() -> CGFloat {
        if self.lockBarViewController == nil {
            return 0.0
        }
        
        return self.lockBarViewController!.view.bounds.size.height
    }
    
    // MARK: SLSLideViewControllerDelegate methods
    func handleAction(svc: SLSlideViewController, action: SLSlideViewControllerAction) {
        switch action {
        case .EllipsesPressed:
            let ldvc:SLLockDetailsViewController = SLLockDetailsViewController()
            self.presentViewControllerWithNavigationController(ldvc)
        case .FindMyEllipsePressed:
            self.isMapShowing = true
            self.presentViewControllerWithNavigationController(self.mapViewController)
        case .ProfileAndSettingPressed:
            let pvc = SLProfileViewController()
            self.presentViewControllerWithNavigationController(pvc)
        case .EmergencyContacts:
            let contactHandler = SLContactHandler()
            if contactHandler.authorizedToAccessContacts() {
                let ecvc = SLEmergencyContactsViewController()
                self.presentViewControllerWithNavigationController(ecvc)
            } else {
                let rcvc = SLRequestContactsAccessViewController()
                self.presentViewControllerWithNavigationController(rcvc)
            }
        case .HelpPressed:
            print("help pressed")
        case .RateTheAppPressed:
            print("rate the app pressed")
        }
    }
    
    // MARK: SLLocationManagerDelegate methods
    func locationManagerUpdatedUserPosition(locationManager: SLLocationManager, userLocation: CLLocation) {
        if self.isMapShowing {
            self.mapViewController.updateUserPosition(userLocation.coordinate)
        }
    }
    
    func locationManagerDidAcceptedLocationAuthorization(locationManager: SLLocationManager, didAccept: Bool) {
       self.acceptNotificationViewController.setBackgroundImageForCurrentStep()
    }
    
    // MARK: SLAcceptNotificationViewControllerDelegate Methods
    func userWantsToAcceptLocationUse(acceptNotificationsVC: SLAcceptNotificationsViewController) {
        self.locationManager.requestAuthorization()
    }
    
    func userWantsToAcceptsNotifications(acceptNotificationsVC: SLAcceptNotificationsViewController) {
        let appDelegate:SLAppDelegate = UIApplication.sharedApplication().delegate as! SLAppDelegate
        appDelegate.setUpNotficationSettings()
    }
    
    func acceptsNotificationsControllerWantsExit(acceptNotiticationViewController: SLAcceptNotificationsViewController, animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "SLUserDefaultsOnBoardingComplete")
        userDefaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
