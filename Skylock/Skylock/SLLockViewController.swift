//
//  SLLockViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

@objc class SLLockViewController:
SLBaseViewController,
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
            y: UIApplication.shared.statusBarFrame.size.height + 20.0,
            width: 2*image.size.width,
            height: 2*image.size.height
        )
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(menuButtonPressed), for: .touchDown)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    lazy var underLineView:UIView = {
        let frame = CGRect(
            x: self.xPadding,
            y: self.view.bounds.size.height - 80.0,
            width: self.view.bounds.size.width - 2.0*self.xPadding,
            height: 1.0
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.white
        view.isHidden = true
        
        return view
    }()
    
    lazy var lockNameLabel:UILabel = {
        let labelWidth = self.underLineView.bounds.size.width
        let font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 18.0)
        let height:CGFloat = 22.0
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - labelWidth),
            y: self.underLineView.frame.minY - height - 7.0,
            width: labelWidth,
            height: height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.text = self.lock?.displayName()
        label.textAlignment = .left
        label.font = font
        label.numberOfLines = 1
        label.isHidden = true
        
        return label
    }()
    
    lazy var crashButton:SLLockScreenAlertButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_crash_detection_on",
            inactiveImageName: "lock_screen_crash_detection_off",
            titleText: NSLocalizedString("Crash\ndetection", comment: ""),
            textColor: UIColor.white,
            textPlacement: .right
        )
        button.frame = CGRect(
            x: self.xPadding,
            y: self.underLineView.frame.maxY + 15.0,
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(crashButtonPressed), for: .touchDown)
        if let user:SLUser = self.databaseManager.getCurrentUser(), let crashAlertsOn = user.areCrashAlertsOn {
            button.isSelected = crashAlertsOn.boolValue
        }
        button.isHidden = true
        
        return button
    }()
    
    lazy var theftButton:UIButton = {
        let button:SLLockScreenAlertButton = SLLockScreenAlertButton(
            activeImageName: "lock_screen_theft_detection_on",
            inactiveImageName: "lock_screen_theft_detection_off",
            titleText: NSLocalizedString("Theft\ndetection", comment: ""),
            textColor: UIColor.white,
            textPlacement: .left
        )
        button.frame = CGRect(
            x: self.view.bounds.size.width - button.bounds.size.width - self.xPadding,
            y: self.crashButton.frame.minY,
            width: button.bounds.size.width,
            height: button.bounds.size.height
        )
        button.addTarget(self, action: #selector(theftButtonPressed), for: .touchDown)
        if let user:SLUser = self.databaseManager.getCurrentUser(), let theftAlertsOn = user.areTheftAlertsOn {
            button.isSelected = theftAlertsOn.boolValue
        }
        button.isHidden = true
        
        return button
    }()
    
    lazy var batteryView:UIImageView = {
        let image:UIImage = UIImage(named: "battery4")!
        let frame = CGRect(
            x: self.underLineView.frame.maxX - image.size.width,
            y: self.lockNameLabel.frame.midY - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(frame: frame)
        view.image = image
        
        return view
    }()
    
    lazy var rssiView:UIImageView = {
        let image:UIImage = UIImage(named: "rssi4")!
        let frame = CGRect(
            x: self.batteryView.frame.minX - image.size.width - 20.0,
            y: self.lockNameLabel.frame.midY - 0.5*image.size.height,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(frame: frame)
        view.image = image
        
        return view
    }()

    lazy var thinkerViewController:SLThinkerViewController = {
        let text:[SLThinkerViewControllerLabelTextState:String] = [
            .clockwiseTopStill: NSLocalizedString("LOCKED", comment: ""),
            .clockwiseBottomStill: NSLocalizedString("Tap to unlock", comment: ""),
            .clockwiseTopMoving: NSLocalizedString("Locking...", comment: ""),
            .counterClockwiseTopStill: NSLocalizedString("UNLOCKED", comment: ""),
            .counterClockwiseBottomStill: NSLocalizedString("Tap to lock", comment: ""),
            .counterClockwiseTopMoving: NSLocalizedString("Unlocking...", comment: ""),
            .inactiveTop: NSLocalizedString("NOT", comment: ""),
            .inactiveBottom: NSLocalizedString("CONNECTED", comment: ""),
            .connectingTop: NSLocalizedString("CONNECTING...", comment: ""),
            .connectingBottom: NSLocalizedString("", comment: "")
        ]
        
        let tvc:SLThinkerViewController = SLThinkerViewController(
            texts: text,
            firstBackgroundColor: UIColor.white,
            secondBackgroundColor: UIColor(red: 102, green: 177, blue: 227),
            foregroundColor: UIColor(red: 60, green: 83, blue: 119),
            inActiveBackgroundColor: UIColor(red: 130, green: 156, blue: 178),
            textColor: UIColor.white
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
        view.backgroundColor = UIColor.clear
        
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
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        view.addSubview(label)
        
        let buttonFrame = CGRect(
            x: 0.0,
            y: 0.5*view.bounds.size.height,
            width: view.bounds.size.width,
            height: 0.5*view.bounds.size.height
        )
        let button:UIButton = UIButton(type: .system)
        button.frame = buttonFrame
        button.setTitle(NSLocalizedString("Find an Ellipse to connect to.", comment: ""), for: .normal)
        button.setTitleColor(UIColor(red: 87, green: 216, blue: 255), for: .normal)
        button.titleLabel?.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 15.0)
        button.addTarget(self, action: #selector(findEllipseButtonPressed), for: .touchDown)
        
        view.addSubview(button)
        
        return view
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.lockManager.checkCurrentLockOpenOrClosed()
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
            self.view.bringSubview(toFront: self.thinkerViewController.view)
            self.thinkerViewController.didMove(toParentViewController: self)
        }
        
        self.thinkerViewController.setState(state: .inactive)
        self.lock = self.lockManager.getCurrentLock()
        self.toggleViewsHiddenOnConnction(isConnected: self.lock != nil)
    }
    
    func registerForNotifications() {
        // TODO: Get UI to handle the case where the lock position is invalid or middle.
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockPositionOpen),
            object: nil,
            queue: nil,
            using: lockOpened
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockPositionLocked),
            object: nil,
            queue: nil,
            using: lockLocked
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerDisconnectedLock),
            object: nil,
            queue: nil,
            using: lockDisconneted
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockPaired),
            object: nil,
            queue: nil,
            using: lockPaired
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationShowLockBar),
            object: nil,
            queue: nil,
            using: showLockBar
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationHideLockBar),
            object: nil,
            queue: nil,
            using: hideLockBar
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationAlertOccured),
            object: nil,
            queue: nil,
            using: theftOrCrashAlert
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerStartedConnectingLock),
            object: nil,
            queue: nil,
            using: startedConnectingLock
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerUpdatedHardwareValues),
            object: nil,
            queue: nil,
            using: hardwareValuesUpdated
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerErrorConnectingLock),
            object: nil,
            queue: nil,
            using: lockConnectionError
        )
    }
    
    func showAcceptNotificaitonViewController() {
        let ud = UserDefaults.standard;
        if !ud.bool(forKey: SLUserDefaultsOnBoardingComplete) {
            self.present(
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
        self.view.bringSubview(toFront: self.slideViewController.view)
        self.slideViewController.didMove(toParentViewController: self)
        
        UIView.animate(withDuration: 0.4, animations: {
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
        guard let user:SLUser = self.databaseManager.getCurrentUser() else {
            return
        }
        
        if self.lock == nil {
            return
        }
        
        user.areCrashAlertsOn = NSNumber(value: false)
        user.areTheftAlertsOn = NSNumber(value: !user.areTheftAlertsOn!.boolValue)
        self.databaseManager.save(user, withCompletion: nil)
        
        self.theftButton.isSelected = user.areTheftAlertsOn!.boolValue
        self.crashButton.isSelected = false
    }
    
    func crashButtonPressed() {
        guard let user:SLUser = self.databaseManager.getCurrentUser() else {
            return
        }
        
        if self.lock == nil {
            return
        }
        
        user.areTheftAlertsOn = NSNumber(value: false)
        user.areCrashAlertsOn = NSNumber(value: !user.areCrashAlertsOn!.boolValue)
        self.databaseManager.save(user, withCompletion: nil)
        
        self.crashButton.isSelected = user.areCrashAlertsOn!.boolValue
        self.theftButton.isSelected = false
    }
    
    func findEllipseButtonPressed() {
        let alvc = SLAvailableLocksViewController()
        alvc.dismissConcentricCirclesViewController = true
        self.presentViewControllerWithNavigationController(viewController: alvc)
    }
    
    func lockOpened(notification: Notification) {
        self.thinkerViewController.setState(state: .counterClockwiseStill)
    }
    
    func lockLocked(notification: Notification) {
        self.thinkerViewController.setState(state: .clockwiseStill)
        if let lock = self.lock, let user:SLUser = self.databaseManager.getCurrentUser() {
            lock.setCurrentLocation(user.location)
            //lock.setCurrentLocation(CLLocationCoordinate2DMake(37.345253, -120.585895))
            self.databaseManager.save(lock)
        }
    }
    
    func lockRemoved(notification: Notification) {
        self.thinkerViewController.setState(state: .inactive)
        self.setLockDisabled()
    }
    
    func lockPaired(notification: Notification) {
        if let lock:SLLock = self.lockManager.getCurrentLock() {
            self.lock = lock
            self.lockNameLabel.text = lock.displayName()
            self.lockNameLabel.setNeedsDisplay()
            self.lockManager.checkCurrentLockOpenOrClosed()
            self.lockNameLabel.textColor = UIColor.white
            self.toggleViewsHiddenOnConnction(isConnected: true)
        }
    }
    
    func lockDisconneted(notification: Notification) {
        guard let disconnectedAddress = notification.object as? String else {
            return
        }
        
        if let currentLock = self.lock, disconnectedAddress == currentLock.macAddress {
            self.setLockDisabled()
        } else if self.lockManager.getCurrentLock() == nil {
            self.setLockDisabled()
        }
    }
    
    func showLockBar(notification: Notification) {
        if let lbvc = self.lockBarViewController {
            self.view.bringSubview(toFront: lbvc.view)
        } else if let presentedVC = self.presentedViewController {
            if let lbvc = self.lockBarViewController {
                presentedVC.view.bringSubview(toFront: lbvc.view)
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
                presentedVC.view.bringSubview(toFront: self.lockBarViewController!.view)
                self.lockBarViewController!.didMove(toParentViewController: presentedVC)
                
                UIView.animate(withDuration: 0.4, animations: {
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
    
    func hideLockBar(notification: Notification) {
        if let lbvc = self.lockBarViewController {
            lbvc.view.removeFromSuperview()
            lbvc.removeFromParentViewController()
            self.lockBarViewController = nil
        }
    }
    
    func hardwareValuesUpdated(notification: Notification) {
        guard let macAddress = notification.object as? String else {
            return
        }
        
        if self.lock != nil && self.lock?.macAddress == macAddress {
            print("\(lock?.batteryVoltage), \(lock?.rssiStrength)")
            DispatchQueue.main.async {
                self.batteryView.image = self.batteryImageForCurrentLock()
                self.rssiView.image = self.rssiImageForCurrentLock()
                self.batteryView.setNeedsDisplay()
                self.rssiView.setNeedsDisplay()
            }
        }
    }
    
    func theftOrCrashAlert(notification: Notification) {
        guard let alertNotification:SLNotification = notification.object as? SLNotification else {
            return
        }
        
        if alertNotification.type == SLNotificationType.crashPre {
            let cnvc:SLCrashNotificationViewController = SLCrashNotificationViewController(
                takeActionButtonTitle: "ALERT MY CONTACTS",
                cancelButtonTitle: "CANCEL, I'M OK",
                titleText: NSLocalizedString("Crash detected!", comment: ""),
                infoText: NSLocalizedString("Your emergency contacts will be alerted in", comment: "")
            )
            cnvc.crashDelegate = self
            cnvc.delegate = self
            
            self.present(cnvc, animated: true, completion: nil)
        } else if alertNotification.type == SLNotificationType.theft {
            let tnvc:SLTheftNotificationViewController = SLTheftNotificationViewController(
                takeActionButtonTitle: "LOCATE MY BIKE",
                cancelButtonTitle: "OK, GOT IT",
                titleText: NSLocalizedString("Theft detected!", comment: ""),
                infoText: NSLocalizedString("We think someone may be tampering with your bike.", comment: "")
            )
            tnvc.delegate = self
            
            self.present(tnvc, animated: true, completion: nil)
        }
    }
    
    func startedConnectingLock(notification: Notification) {
        self.thinkerViewController.setState(state: .connecting)
        self.unconnectedView.isHidden = true
        self.underLineView.isHidden = true
        self.lockNameLabel.isHidden = true
        self.crashButton.isHidden = true
        self.theftButton.isHidden = true
        self.batteryView.isHidden = true
        self.rssiView.isHidden = true
    }
    
    func lockConnectionError(notification: Notification) {
        if self.viewIfLoaded?.window == nil {
            return
        }
        
        guard let notificationObject = notification.object as? [String: Any?] else {
            print("no connection error in notification for method: lockConnectionError")
            return
        }
        
        guard let info = notificationObject["message"] as? String else {
            print("no connection error messsage in notification for method: lockConnectionError")
            return
        }
        
        let texts:[SLWarningViewControllerTextProperty:String?] = [
            .Header: NSLocalizedString("Failed to connect Ellipse", comment: ""),
            .Info: info,
            .CancelButton: NSLocalizedString("OK", comment: ""),
            .ActionButton: nil
        ]
        
        self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
    }
    
    func setLockDisabled() {
        self.lock = nil
        self.thinkerViewController.setState(state: .inactive)
        self.lockNameLabel.text = ""
        self.toggleViewsHiddenOnConnction(isConnected: false)
    }
    
    func toggleViewsHiddenOnConnction(isConnected: Bool) {
        self.unconnectedView.isHidden = isConnected
        self.underLineView.isHidden = !isConnected
        self.lockNameLabel.isHidden = !isConnected
        self.crashButton.isHidden = !isConnected
        self.theftButton.isHidden = !isConnected
        self.batteryView.isHidden = !isConnected
        self.rssiView.isHidden = !isConnected
    }
    
    func removeSlideViewController() {
        self.isMapShowing = false
        UIView.animate(withDuration: 0.4, animations: {
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
            nc.navigationBar.barStyle = UIBarStyle.black
            nc.navigationBar.tintColor = UIColor.white
            nc.navigationBar.barTintColor = UIColor(red: 130, green: 156, blue: 178)
            self.present(nc, animated: true, completion: nil)
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
        let range:SLLockParameterRange = lock.range(for: SLLockParameterType.RSSI)
        switch range {
        case .zero:
            imageName = "rssi0"
        case .one:
            imageName = "rssi1"
        case .two:
            imageName = "rssi2"
        case .three:
            imageName = "rssi3"
        case .four:
            imageName = "rssi4"
        }
        
        return UIImage(named: imageName)
    }
    
    func batteryImageForCurrentLock() -> UIImage? {
        guard let lock = self.lock else {
            return nil
        }
        
        let imageName:String
        let range:SLLockParameterRange = lock.range(for: SLLockParameterType.battery)
        switch range {
        case .zero:
            imageName = "battery0"
        case .one:
            imageName = "battery1"
        case .two:
            imageName = "battery2"
        case .three:
            imageName = "battery3"
        case .four:
            imageName = "battery4"
        }
        
        return UIImage(named: imageName)
    }
    
    // MARK: SLSLideViewControllerDelegate methods
    func handleAction(svc: SLSlideViewController, action: SLSlideViewControllerAction) {
        switch action {
        case .EllipsesPressed:
            let ldvc:SLLockDetailsViewController = SLLockDetailsViewController()
            self.presentViewControllerWithNavigationController(viewController: ldvc)
        case .FindMyEllipsePressed:
            self.isMapShowing = true
            self.presentViewControllerWithNavigationController(viewController: self.mapViewController)
        case .ProfileAndSettingPressed:
            let pvc = SLProfileViewController()
            self.presentViewControllerWithNavigationController(viewController: pvc)
        case .EmergencyContacts:
            let contactHandler = SLContactHandler()
            if contactHandler.authorizedToAccessContacts() {
                let ecvc = SLEmergencyContactsViewController()
                self.presentViewControllerWithNavigationController(viewController: ecvc)
            } else {
                let rcvc = SLRequestContactsAccessViewController()
                self.presentViewControllerWithNavigationController(viewController: rcvc)
            }
        case .HelpPressed:
            let webView = SLWebViewController(baseUrl: .Help)
            self.presentViewControllerWithNavigationController(viewController: webView)
        case .RateTheAppPressed:
            print("rate the app pressed")
        case .InviteFriendsPressed:
            print("Invite friends pressed")
        case .OrderNowPressed:
            let webView = SLWebViewController(baseUrl: .Skylock)
            self.presentViewControllerWithNavigationController(viewController: webView)
        }
    }
    
    // MARK: SLLocationManagerDelegate methods
    func locationManagerUpdatedUserPosition(locationManager: SLLocationManager, userLocation: CLLocation) {
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        guard let user = dbManager.getCurrentUser() else {
            return
        }
        
        user.location = userLocation.coordinate
        dbManager.save(user, withCompletion: nil)
        
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
        let appDelegate:SLAppDelegate = UIApplication.shared.delegate as! SLAppDelegate
        appDelegate.setUpNotficationSettings()
    }
    
    func acceptsNotificationsControllerWantsExit(
        acceptNotiticationViewController: SLAcceptNotificationsViewController,
        animated: Bool
        )
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "SLUserDefaultsOnBoardingComplete")
        userDefaults.synchronize()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: SLThinkerViewControllerDelegate methods
    func thinkerViewTapped(tvc: SLThinkerViewController) {
        guard let lockPosition = self.lock?.lockPosition else {
            print("Error: could not get lock position when thinker view was tapped.")
            return
        }
        
        guard let position = SLLockPosition(rawValue: lockPosition.uintValue) else {
            print(
                "Error: could not get lock position when thinker view was tapped. "
                + "The value is outside SLLockPosition enum values"
            )
            return
        }
        
        self.thinkerViewController.setState(state: position == .locked ? .counterClockwiseMoving : .clockwiseMoving)
        self.lockManager.toggleLockOpenedClosedShouldLock(shouldLock: position != .locked)
    }
    
    // MARK: SLNotificationViewControllerDelegate methods
    func takeActionButtonPressed(nvc: SLNotificationViewController) {
        let notificationManager:SLNotificationManager = SLNotificationManager.sharedManager() as! SLNotificationManager
        var completion:(() -> Void)?
        if let notification:SLNotification = notificationManager.lastNotification() {
            if notification.type == SLNotificationType.crashPre {
                let databaseManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
                guard let user = databaseManager.getCurrentUser() else {
                    print("Error: could not get signed message and public key. No user in database")
                    return
                }
                
                guard let lock:SLLock = self.lock else {
                    print("Error: no current lock. Cannot send emergency text")
                    return
                }
                
                let keychainHandler:SLKeychainHandler = SLKeychainHandler()
                guard let restToken = keychainHandler.getItemForUsername(
                    userName: user.userId!,
                    additionalSeviceInfo: nil,
                    handlerCase: .RestToken
                    ) else
                {
                    print(
                        "Error: could not send crash notification to emergency contact. " +
                        "No rest token for user: \(user.fullName())."
                    )
                    return
                }
                
                guard let contacts = databaseManager.emergencyContactsForCurrentUser() as? [SLEmergencyContact] else {
                    print(
                        "Error: could not send crash notification. " +
                        "The current user does not have any emergency contacts."
                    )
                    return
                }
                
                var formatedContacts = [[String:String]]()
                for contact in contacts {
                    if let phoneNumber = contact.phoneNumber, let firstName = contact.firstName {
                        formatedContacts.append([
                            "phone_number": phoneNumber,
                            "first_name": firstName
                        ])
                    }
                }
                
                let restManager = SLRestManager.sharedManager() as! SLRestManager
                let authValue = restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
                let additionalHeaders = ["Authorization": authValue]
                let postObject:[String:Any?] = [
                    "mac_id": lock.macAddress,
                    "position": ["latitude": user.location.latitude, "longitude": user.location.longitude],
                    "contacts": formatedContacts
                ]
                
                restManager.postObject(
                    postObject,
                    serverKey: .main,
                    pathKey: .keys,
                    subRoutes: [user.userId!, "sendhelp"],
                    additionalHeaders: additionalHeaders
                ) { (status:UInt, response:[AnyHashable : Any]?) in
                    if status != 200 || status != 201 {
                        // TODO: add error handling on the client side. We currently don't have UI For this
                        // This should also set the callback params appropriately.
                        return
                    }
                    
                    print(response)
                }
            } else if notification.type == SLNotificationType.theft {
                completion = {
                    self.isMapShowing = true
                    self.presentViewControllerWithNavigationController(viewController: self.mapViewController)
                }
            }
            
            notificationManager.removeLastNotification()
        }
        
        nvc.dismiss(animated: true, completion: completion)
    }
    
    func cancelButtonPressed(nvc: SLNotificationViewController) {
        let notificationManager:SLNotificationManager = SLNotificationManager.sharedManager() as! SLNotificationManager
        notificationManager.removeLastNotification()
        nvc.dismiss(animated: true, completion: nil)
    }
    
    // MARK: SLCrashNotificationViewControllerDelegate methods
    func timerExpired(cnvc: SLCrashNotificationViewController) {
        (SLNotificationManager.sharedManager() as AnyObject).sendEmergencyText()
        cnvc.dismiss(animated: true, completion: nil)
    }
    
    // MARK: SLLockBarViewControllerDelegate Methods
    func lockBarTapped(lockBar: SLLockBarViewController) {
        self.dismiss(animated: true, completion: {
            self.removeSlideViewController()
        })
    }
}
