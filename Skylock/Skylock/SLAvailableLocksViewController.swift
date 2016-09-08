//
//  SLAvailableLocksViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

@objc class SLAvailableLocksViewController: SLBaseViewController, UITableViewDelegate, UITableViewDataSource {
    var locks:[SLLock] = [SLLock]()
    
    let buttonTagShift:Int = 1000
    
    var tempButtons:[UIButton] = [UIButton]()
    
    var hideBackButton:Bool = false
    
    var dismissConcentricCirclesViewController:Bool = false
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Plain)
        table.rowHeight = 110.0
        table.backgroundColor = UIColor.clearColor()
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
    
    lazy var headerLabel:UILabel = {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: self.tableView.bounds.size.width,
            height: self.tableView(self.tableView, heightForHeaderInSection: 0)
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textAlignment = .Center
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 18.0)
        label.textColor = UIColor(red: 130, green: 156, blue: 178)
        label.numberOfLines = 2

        return label
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("SELECT AN ELLIPSE", comment: "")
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.tableView)
        
        let backButton = UIBarButtonItem(
            image: UIImage(named: "lock_screen_close_icon"),
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: #selector(backButtonPressed)
        )

        self.navigationItem.leftBarButtonItem = backButton
        
        let lockManager = SLLockManager.sharedManager
        if lockManager.isBlePoweredOn() && !lockManager.isInActiveSearch() {
            lockManager.startActiveSearch()
        }
        
        self.setHeaderTextForNumberOfLocks(self.locks.count)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(foundLock(_:)),
            name: kSLNotificationLockManagerDiscoverdLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockShallowlyConntected(_:)),
            name: kSLNotificationLockManagerShallowlyConnectedLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(bleHardwarePoweredOn(_:)),
            name: kSLNotificationLockManagerBlePoweredOn,
            object: nil
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        for lock in SLLockManager.sharedManager.locksInActiveSearch() {
            self.addLock(lock)
        }
        
        self.tableView.reloadData()
    }
    
    func addLock(lock: SLLock) {
        var addLock = true
        for listedLock in self.locks {
            if lock.macAddress == listedLock.macAddress {
                addLock = false
                break
            }
        }
        
        if addLock {
            self.locks.append(lock)
        }
    }
    func foundLock(notification: NSNotification) {
        guard let lock = notification.object as? SLLock else {
            print("Error: found lock but it was not included in notification")
            return
        }
        
        var addLock = true
        for knownLock in self.locks where knownLock.macAddress == lock.macAddress {
            addLock = false
            break
        }
        
        if addLock {
            self.locks.append(lock)
            // If this is the first lock found, we need to update the header text.
            self.setHeaderTextForNumberOfLocks(self.locks.count)
            
            let indexPath:NSIndexPath = NSIndexPath(forRow: self.locks.count - 1, inSection: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            self.tableView.endUpdates()
        }
    }
    
    func lockShallowlyConntected(notificaiton: NSNotification) {
        guard let connectedLock = notificaiton.object as? SLLock else {
            return
        }
        
        for (index, lock) in self.locks.enumerate() {
            if lock.macAddress == connectedLock.macAddress {
                self.enableButtonAtIndex(index)
                break
            }
        }
    }
    
    func bleHardwarePoweredOn(notificaiton: NSNotification) {
        let lockManager = SLLockManager.sharedManager
        lockManager.startActiveSearch()
    }
    
    func blinkLockButtonPressed(button: UIButton) {
//        for (i, lock) in self.locks.enumerate() {
//            let indexPath:NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
//            let cell:UITableViewCell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
//            print("\(cell.textLabel?.text!)")
//            
//            if let accessoryButton:UIButton = cell.accessoryView as? UIButton {
//                let accessoryButtonTag = accessoryButton.tag
//                let buttonTag = button.tag
//                if accessoryButtonTag == buttonTag {
//                    SLLockManager.sharedManager.flashLEDsForLock(lock)
//                    break
//                }
//            }
//        }
    }
    
    func connectButtonPressed(button: UIButton) {
        for (i, lock) in self.locks.enumerate() {
            let indexPath:NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell:UITableViewCell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
            
            if let accessoryButton:UIButton = cell.accessoryView as? UIButton {
                let accessoryButtonTag = accessoryButton.tag
                let buttonTag = button.tag
                if accessoryButtonTag == buttonTag {
                    let ccvc = SLConcentricCirclesViewController()
                    ccvc.shouldDismiss = self.dismissConcentricCirclesViewController

                    self.navigationController?.pushViewController(ccvc, animated: true)
                    let lockManager = SLLockManager.sharedManager
                    lockManager.connectToLockWithMacAddress(lock.macAddress!)
                    break
                }
            }
        }
    }
    
    func backButtonPressed() {
        if self.navigationController?.viewControllers.first == self {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        let lockManager = SLLockManager.sharedManager
        lockManager.endActiveSearch()
        lockManager.deleteAllNeverConnectedAndNotConnectingLocks()
    }
    
    func enableButtonAtIndex(index: Int) {
        if index < tempButtons.count {
            let button:UIButton = self.tempButtons[index]
            button.enabled = true
        }
    }
    
    func skipDatShit() {
        if self.hideBackButton || self.navigationController?.viewControllers.first! == self {
            let lvc = SLLockViewController()
            self.presentViewController(lvc, animated: true, completion: nil)
        }
    }
    
    func setHeaderTextForNumberOfLocks(numberOfLocks: Int) {
        self.headerLabel.text = numberOfLocks == 0 ? NSLocalizedString("Searching...", comment: "")
            : NSLocalizedString("We've found the following Ellipses", comment: "")
    }
    
    // MARK: UITableView delegate and datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "SLAvaliableLocksViewControllerCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellId)
        }
        
        let lock = self.locks[indexPath.row]
        let image:UIImage = UIImage(named: "lock_onboarding_connect_button")!
        let button:UIButton = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height)
        )
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(connectButtonPressed(_:)), forControlEvents: .TouchDown)
        button.tag = indexPath.row + self.buttonTagShift
        
        self.tempButtons.append(button)
        
        cell?.textLabel?.text = lock.displayName()
        cell?.textLabel?.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        cell?.textLabel?.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 17.0)
        cell?.accessoryView = button
        cell?.selectionStyle = .None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewFrame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: viewFrame)
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(self.headerLabel)
        
        let inset:UIEdgeInsets = tableView.separatorInset
        let lineViewFrame = CGRect(
            x: inset.left,
            y: view.bounds.size.height - 1.0,
            width: view.bounds.size.width - inset.left - inset.right,
            height: 1.0
        )
        
        let lineView = UIView(frame: lineViewFrame)
        lineView.backgroundColor = tableView.separatorColor
        
        view.addSubview(lineView)
        
        let tgr:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(skipDatShit))
        tgr.numberOfTapsRequired = 5
        view.addGestureRecognizer(tgr)
        view.userInteractionEnabled = true
        
        return view
    }
}
