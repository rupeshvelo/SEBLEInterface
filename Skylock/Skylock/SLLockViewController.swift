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
SLAcceptNotificationsViewControllerDelegate,
SLThinkerViewControllerDelegate,
SLNotificationViewControllerDelegate,
SLCrashNotificationViewControllerDelegate,
SLLockBarViewControllerDelegate
{
    let xPadding:CGFloat = 13.0
    
    var lock:SLLock?
    
    let lockManager:SLLockManager = SLLockManager.sharedManager
    
    let databaseManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
    
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
    
    lazy var underLineView:UIView = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - 80.0,
            width: self.view.bounds.size.width - 2*self.xPadding,
            height: 1.0
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.whiteColor()
        view.hidden = true
        
        return view
    }()
    
    lazy var lockNameLabel:UILabel = {
        let labelWidth = self.underLineView.bounds.size.width
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 18.0)
        let height:CGFloat = 22.0
        let frame = CGRectMake(
            0.5*(self.view.bounds.size.width - labelWidth),
            CGRectGetMinY(self.underLineView.frame) - height - 7.0,
            labelWidth,
            height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.whiteColor()
        label.text = self.lock?.displayName()
        label.textAlignment = .Left
        label.font = font
        label.numberOfLines = 1
        label.hidden = true
        
        return label
    }()
    
    lazy var crashButton:SLLockScreenAlertButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_crash_detection_on",
            inactiveImageName: "lock_screen_crash_detection_off",
            titleText: NSLocalizedString("Crash\ndetection", comment: ""),
            textColor: UIColor.whiteColor()
        )
        button.frame = CGRect(
            x: self.xPadding,
            y: CGRectGetMaxY(self.underLineView.frame) + 15.0,
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(crashButtonPressed), forControlEvents: .TouchDown)
        if let crashAlertsOn = self.databaseManager.currentUser?.areCrashAlertsOn {
            button.selected = crashAlertsOn.boolValue
        }
        button.hidden = true
        
        return button
    }()
    
    lazy var theftButton:UIButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_theft_detection_on",
            inactiveImageName: "lock_screen_theft_detection_off",
            titleText: NSLocalizedString("Theft\ndetection", comment: ""),
            textColor: UIColor.whiteColor()
        )
        button.frame = CGRect(
            x: self.view.bounds.size.width - button.bounds.size.width - self.xPadding,
            y: CGRectGetMinY(self.crashButton.frame),
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(theftButtonPressed), forControlEvents: .TouchDown)
        if let theftAlertsOn = self.databaseManager.currentUser?.areTheftAlertsOn {
            button.selected = theftAlertsOn.boolValue
        }
        button.hidden = true
        
        return button
    }()
    
    lazy var batteryView:UIImageView = {
        let image:UIImage = UIImage(named: "battery0")!
        let frame = CGRect(
            x: CGRectGetMaxX(self.underLineView.frame) - image.size.width,
            y: CGRectGetMidY(self.lockNameLabel.frame) - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(frame: frame)
        view.image = image
        
        return view
    }()
    
    lazy var rssiView:UIImageView = {
        let image:UIImage = UIImage(named: "rssi0")!
        let frame = CGRect(
            x: CGRectGetMinX(self.batteryView.frame) - image.size.width - 20.0,
            y: CGRectGetMidY(self.lockNameLabel.frame) - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(frame: frame)
        view.image = image
        
        return view
    }()

    lazy var thinkerViewController:SLThinkerViewController = {
        let text:[SLThinkerViewControllerLabelTextState:String] = [
            .ClockwiseTopStill: NSLocalizedString("LOCKED", comment: ""),
            .ClockwiseBottomStill: NSLocalizedString("Tap to unlock", comment: ""),
            .ClockwiseTopMoving: NSLocalizedString("Locking...", comment: ""),
            .CounterClockwiseTopStill: NSLocalizedString("UNLOCKED", comment: ""),
            .CounterClockwiseBottomStill: NSLocalizedString("Tap to lock", comment: ""),
            .CounterClockwiseTopMoving: NSLocalizedString("Unlocking...", comment: ""),
            .InactiveTop: NSLocalizedString("NOT", comment: ""),
            .InactiveBottom: NSLocalizedString("CONNECTED", comment: ""),
            .ConnectingTop: NSLocalizedString("CONNECTING...", comment: ""),
            .ConnectingBottom: NSLocalizedString("", comment: "")
        ]
        
        let tvc:SLThinkerViewController = SLThinkerViewController(
            texts: text,
            firstBackgroundColor: UIColor.whiteColor(),
            secondBackgroundColor: UIColor(red: 102, green: 177, blue: 227),
            foregroundColor: UIColor(red: 60, green: 83, blue: 119),
            inActiveBackgroundColor: UIColor(red: 130, green: 156, blue: 178),
            textColor: UIColor.whiteColor()
        )
        tvc.delegate = self
        
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
            action: #selector(removeSlideViewController)
        )
        
        let view:UIView = UIView(frame: self.view.bounds)
        view.addGestureRecognizer(tgr)
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }()
    
    lazy var unconnectedView:UIView = {
        let width = self.view.bounds.size.width - 2.0*self.xPadding
        let height:CGFloat = 60.0
        let viewFrame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - height - 20.0,
            width: width,
            height: height
        )
        
        let view:UIView = UIView(frame: viewFrame)
        
        let labelFrame = CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: 0.5*view.bounds.size.height)
        let label:UILabel = UILabel(frame: labelFrame)
        label.text = NSLocalizedString("You are not connected to any locks.", comment: "")
        label.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 15.0)
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        
        view.addSubview(label)
        
        let buttonFrame = CGRectMake(
            0.0,
            0.5*view.bounds.size.height,
            view.bounds.size.width,
            0.5*view.bounds.size.height
        )
        let button:UIButton = UIButton(type: .System)
        button.frame = buttonFrame
        button.setTitle(NSLocalizedString("Find an Ellipse to connect to.", comment: ""), forState: .Normal)
        button.setTitleColor(UIColor(red: 87, green: 216, blue: 255), forState: .Normal)
        button.titleLabel?.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 15.0)
        button.addTarget(self, action: #selector(findEllipseButtonPressed), forControlEvents: .TouchDown)
        
        view.addSubview(button)
        
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
        self.view.addSubview(self.unconnectedView)
        self.view.addSubview(self.underLineView)
        self.view.addSubview(self.lockNameLabel)
        self.view.addSubview(self.crashButton)
        self.view.addSubview(self.theftButton)
        self.view.addSubview(self.batteryView)
        self.view.addSubview(self.rssiView)
        
        self.registerForNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.lockManager.checkLockOpenOrClosed()
        self.showAcceptNotificaitonViewController()
        
        if !self.view.subviews.contains(self.thinkerViewController.view) {
            let diameter:CGFloat = 245.0
            self.thinkerViewController.view.frame = CGRect(
                x: 0.5*(self.view.bounds.size.width - diameter),
                y: 0.5*(self.view.bounds.size.height - diameter) - 50.0,
                width: diameter,
                height: diameter
            )
            
            self.addChildViewController(self.thinkerViewController)
            self.view.addSubview(self.thinkerViewController.view)
            self.view.bringSubviewToFront(self.thinkerViewController.view)
            self.thinkerViewController.didMoveToParentViewController(self)
        }
        
        self.thinkerViewController.setState(.Inactive)
        self.toggleViewsHiddenOnConnction(self.lock != nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func registerForNotifications() {
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
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(theftOrCrashAlert(_:)),
            name: kSLNotificationAlertOccured,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(startedConnectingLock(_:)),
            name: kSLNotificationLockManagerStartedConnectingLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(hardwareValuesUpdated(_:)),
            name: kSLNotificationLockManagerUpdatedHardwareValues,
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
        guard let user:SLUser = self.databaseManager.currentUser as SLUser else {
            return
        }
        
        if self.lock == nil {
            return
        }
        
        if let crashAlertsOn = user.areCrashAlertsOn where crashAlertsOn.boolValue {
            return
        }
        
        if user.areTheftAlertsOn == nil {
             user.areTheftAlertsOn = NSNumber(bool: false)
        }
        
        user.areTheftAlertsOn = NSNumber(bool: !user.areTheftAlertsOn!.boolValue)
        self.databaseManager.saveUser(user, withCompletion: nil)
        self.theftButton.selected = user.areTheftAlertsOn!.boolValue
    }
    
    func crashButtonPressed() {
        guard let user:SLUser = self.databaseManager.currentUser as SLUser else {
            return
        }
        
        if self.lock == nil {
            return
        }
        
        if let theftAlertsOn = user.areTheftAlertsOn where theftAlertsOn.boolValue {
            return
        }
        
        if user.areCrashAlertsOn == nil {
            user.areCrashAlertsOn = NSNumber(bool: false)
        }
        
        user.areCrashAlertsOn = NSNumber(bool: !user.areCrashAlertsOn!.boolValue)
        self.databaseManager.saveUser(user, withCompletion: nil)
        self.crashButton.selected = user.areCrashAlertsOn!.boolValue
    }
    
    func findEllipseButtonPressed() {
        let alvc = SLAvailableLocksViewController()
        self.presentViewControllerWithNavigationController(alvc)
    }
    
    func lockOpened(notification: NSNotification) {
        self.thinkerViewController.setState(.CounterClockwiseStill)
        if let lock = self.lock {
            lock.isLocked = NSNumber(bool: false)
        }
    }
    
    func lockLocked(notification: NSNotification) {
        self.thinkerViewController.setState(.ClockwiseStill)
        if let lock = self.lock {
            let user:SLUser = self.databaseManager.currentUser
            lock.isLocked = NSNumber(bool: true)
            lock.setCurrentLocation(user.location)
            //lock.setCurrentLocation(CLLocationCoordinate2DMake(37.345253, -120.585895))
            self.databaseManager.saveLock(lock)
        }
    }
    
    func lockRemoved(notification: NSNotification) {
        self.thinkerViewController.setState(.Inactive)
        self.setLockDisabled()
    }
    
    func lockPaired(notification: NSNotification) {
        if let lock:SLLock = self.lockManager.getCurrentLock() {
            self.lock = lock
            self.lockNameLabel.text = lock.displayName()
            self.lockNameLabel.setNeedsDisplay()
            self.lockManager.checkLockOpenOrClosed()
            self.lockNameLabel.textColor = UIColor.whiteColor()
            self.toggleViewsHiddenOnConnction(true)
        }
    }
    
    func lockDisconneted(notification: NSNotification) {
        guard let disconnectedAddress = notification.object as? String else {
            return
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
                let height:CGFloat = 66.0
                self.lockBarViewController = SLLockBarViewController()
                self.lockBarViewController?.delegate = self
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
                        if let lbvc = self.lockBarViewController {
                            lbvc.setUpViews()
                        }
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
    
    func hardwareValuesUpdated(notification: NSNotification) {
        guard let macAddress = notification.object as? String else {
            return
        }
        
        if self.lock != nil && self.lock?.macAddress == macAddress {
            print("\(lock?.batteryVoltage), \(lock?.rssiStrength)")
            dispatch_async(dispatch_get_main_queue(), { 
                self.batteryView.image = self.batteryImageForCurrentLock()
                self.rssiView.image = self.rssiImageForCurrentLock()
            })
        }
    }
    
    func theftOrCrashAlert(notification: NSNotification) {
        guard let alertNotification:SLNotification = notification.object as? SLNotification else {
            return
        }
        
        if alertNotification.type == SLNotificationType.CrashPre {
            let cnvc:SLCrashNotificationViewController = SLCrashNotificationViewController(
                takeActionButtonTitle: "ALERT MY CONTACTS",
                cancelButtonTitle: "CANCEL, I'M OK",
                titleText: NSLocalizedString("Crash detected!", comment: ""),
                infoText: NSLocalizedString("Your emergency contacts will be alerted in", comment: "")
            )
            cnvc.crashDelegate = self
            cnvc.delegate = self
            
            self.presentViewController(cnvc, animated: true, completion: nil)
        } else if alertNotification.type == SLNotificationType.Theft {
            let tnvc:SLTheftNotificationViewController = SLTheftNotificationViewController(
                takeActionButtonTitle: "LOCATE MY BIKE",
                cancelButtonTitle: "OK, GOT IT",
                titleText: NSLocalizedString("Theft detected!", comment: ""),
                infoText: NSLocalizedString("We think someone may be tampering with your bike.", comment: "")
            )
            tnvc.delegate = self
            
            self.presentViewController(tnvc, animated: true, completion: nil)
        }
    }
    
    func startedConnectingLock(notification: NSNotification) {
        self.thinkerViewController.setState(.Connecting)
        self.unconnectedView.hidden = true
        self.underLineView.hidden = true
        self.lockNameLabel.hidden = true
        self.crashButton.hidden = true
        self.theftButton.hidden = true
        self.batteryView.hidden = true
        self.rssiView.hidden = true
    }
    
    func setLockDisabled() {
        self.lock = nil
        self.thinkerViewController.setState(.Inactive)
        self.lockNameLabel.text = ""
        self.toggleViewsHiddenOnConnction(false)
    }
    
    func toggleViewsHiddenOnConnction(isConnected: Bool) {
        self.unconnectedView.hidden = isConnected
        self.underLineView.hidden = !isConnected
        self.lockNameLabel.hidden = !isConnected
        self.crashButton.hidden = !isConnected
        self.theftButton.hidden = !isConnected
        self.batteryView.hidden = !isConnected
        self.rssiView.hidden = !isConnected
    }
    
    func removeSlideViewController() {
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
        if let navController = self.navigationController {
            navController.pushViewController(viewController, animated: true)
        } else {
            let nc:UINavigationController = UINavigationController(rootViewController: viewController)
            nc.navigationBar.barStyle = UIBarStyle.Black
            nc.navigationBar.tintColor = UIColor.whiteColor()
            nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
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
    
    func rssiImageForCurrentLock() -> UIImage? {
        guard let lock = self.lock else {
            return nil
        }
        
        let imageName:String
        let range:SLLockParameterRange = lock.rangeForParameterType(SLLockParameterType.RSSI)
        switch range {
        case .Zero:
            imageName = "rssi0"
        case .One:
            imageName = "rssi1"
        case .Two:
            imageName = "rssi2"
        case .Three:
            imageName = "rssi3"
        case .Four:
            imageName = "rssi4"
        }
        
        return UIImage(named: imageName)
    }
    
    func batteryImageForCurrentLock() -> UIImage? {
        guard let lock = self.lock else {
            return nil
        }
        
        let imageName:String
        let range:SLLockParameterRange = lock.rangeForParameterType(SLLockParameterType.Battery)
        switch range {
        case .Zero:
            imageName = "battery0"
        case .One:
            imageName = "battery1"
        case .Two:
            imageName = "battery2"
        case .Three:
            imageName = "battery3"
        case .Four:
            imageName = "battery4"
        }
        
        return UIImage(named: imageName)
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
        case .InviteFriendsPressed:
            print("Invite friends pressed")
        case .OrderNowPressed:
            print("order now pressed")
        }
    }
    
    // MARK: SLLocationManagerDelegate methods
    func locationManagerUpdatedUserPosition(locationManager: SLLocationManager, userLocation: CLLocation) {
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        guard let user = dbManager.currentUser else {
            return
        }
        
        user.location = userLocation.coordinate
        dbManager.saveUser(user, withCompletion: nil)
        
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
    
    func acceptsNotificationsControllerWantsExit(
        acceptNotiticationViewController: SLAcceptNotificationsViewController,
        animated: Bool
        )
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setBool(true, forKey: "SLUserDefaultsOnBoardingComplete")
        userDefaults.synchronize()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: SLThinkerViewControllerDelegate methods
    func thinkerViewTapped(tvc: SLThinkerViewController) {
        guard let lock = self.lock else {
            return
        }
        
        self.thinkerViewController.setState(
            lock.isLocked.boolValue ? .CounterClockwiseMoving : .ClockwiseMoving
        )
        
        self.lockManager.setCurrentLockLockedOrUnlocked(!lock.isLocked.boolValue)
    }
    
    // MARK: SLNotificationViewControllerDelegate methods
    func takeActionButtonPressed(nvc: SLNotificationViewController) {
        let notificationManager:SLNotificationManager = SLNotificationManager.sharedManager() as! SLNotificationManager
        var completion:(() -> Void)?
        if let notification:SLNotification = notificationManager.lastNotification() as SLNotification {
            if notification.type == SLNotificationType.CrashPre {
                // this is where the emergency contacts should be contacted, 
                // and any associated UI should be presented.
            } else if notification.type == SLNotificationType.Theft {
                completion = {
                    self.isMapShowing = true
                    self.presentViewControllerWithNavigationController(self.mapViewController)
                }
            }
            
            notificationManager.removeLastNotification()
        }
        
        
        nvc.dismissViewControllerAnimated(true, completion: completion)
    }
    
    func cancelButtonPressed(nvc: SLNotificationViewController) {
        let notificationManager:SLNotificationManager = SLNotificationManager.sharedManager() as! SLNotificationManager
        notificationManager.removeLastNotification()
        nvc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: SLCrashNotificationViewControllerDelegate methods
    func timerExpired(cnvc: SLCrashNotificationViewController) {
        SLNotificationManager.sharedManager().sendEmergencyText()
        cnvc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: SLLockBarViewControllerDelegate Methods
    func lockBarTapped(lockBar: SLLockBarViewController) {
        self.dismissViewControllerAnimated(true, completion: {
            self.removeSlideViewController()
        })
    }
}
