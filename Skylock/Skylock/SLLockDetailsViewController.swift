//
//  SLLockDetailsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit



class SLLockDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var connectedLock:SLLock?
    
    let utilities:SLUtilities = SLUtilities()
    
    let lockManager:SLLockManager = SLLockManager.sharedManager
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        table.backgroundColor = UIColor.white
        table.rowHeight = 92.0
        table.isScrollEnabled = false
        table.register(
            SLLockDetailsTableViewCell.self,
            forCellReuseIdentifier: String(describing: SLLockDetailsTableViewCell.self)
        )
        
        return table
    }()
    
    lazy var unconnectedLocks:[SLLock] = {
        return self.lockManager.allPreviouslyConnectedLocksForCurrentUser()
    }()
    
    lazy var dataFormatter:DateFormatter = {
        let df:DateFormatter = DateFormatter()
        df.dateFormat = "MMM d, H:mm a"
        
        return df
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let addLockButton:UIBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("ADD NEW", comment: ""),
            style: .plain,
            target: self,
            action: #selector(addLock)
        )
        self.navigationItem.rightBarButtonItem = addLockButton
        
        self.connectedLock = self.lockManager.getCurrentLock()
        
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("ELLIPSES", comment: "")
        
        self.view.addSubview(self.tableView)
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerDisconnectedLock),
            object: self,
            queue: nil,
            using: lockDisconnected
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerDisconnectedLock),
            object: self,
            queue: nil,
            using: lockConnected
        )
    }
    
    func menuButtonPressed() {
        if let navController = self.navigationController {
            navController.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
//        let transitionHandler = SLViewControllerTransitionHandler()
//        self.navigationController?.modalPresentationStyle = .Custom
//        self.navigationController?.transitioningDelegate = transitionHandler
//        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addLock() {
        self.lockManager.startActiveSearch()
        
        let alvc = SLAvailableLocksViewController()
        alvc.dismissConcentricCirclesViewController = false
        self.navigationController?.pushViewController(alvc, animated: true)
    }
    
    func rowActionTextForIndexPath(indexPath: IndexPath) -> String {
        return "             "
    }
    
    func lockConnected(notification: Notification) {
        self.unconnectedLocks = self.lockManager.allPreviouslyConnectedLocksForCurrentUser()
        self.connectedLock = self.lockManager.getCurrentLock()
        
        self.tableView.reloadData()
    }
    
    func lockDisconnected(notification: Notification) {
        guard let disconnectedAddress = notification.object as? String else {
            return
        }
        
        self.unconnectedLocks = self.lockManager.allPreviouslyConnectedLocksForCurrentUser()
        if disconnectedAddress == self.connectedLock?.macAddress {
            self.connectedLock = nil
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: UITableView Delegate & Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : self.unconnectedLocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = String(describing: SLLockDetailsTableViewCell.self)
        let optionsDotsImage:UIImage = UIImage(named: "icon_more_dots_gray_horizontal_Ellipses")!
        let optionsDotsView:UIImageView = UIImageView(image: optionsDotsImage)
        var mainText:String?
        var detailText:String?
        var isConnected = false
        var cellEnabled = true
        
        if let lock = self.connectedLock , indexPath.section == 0 {
            mainText = lock.displayName()
            detailText = NSLocalizedString("Connected", comment: "")
            isConnected = true
        } else if indexPath.section == 0 {
            cellEnabled = false
        } else {
            let unconnectedLock = self.unconnectedLocks[indexPath.row]
            mainText = unconnectedLock.displayName()
            if let lastConnectedDate = unconnectedLock.lastConnected {
                detailText = NSLocalizedString("Last connected on", comment: "") + " "
                    + self.dataFormatter.string(from: lastConnectedDate)
            }
        }
        
        let cell:SLLockDetailsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: cellId
            ) as! SLLockDetailsTableViewCell
        
        cell.setProperties(isConnected: isConnected, mainText: mainText, detailText: detailText)
        cell.accessoryView = mainText == nil ? nil : optionsDotsView
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = cellEnabled
        
        return cell
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text:String
        let backgroundColor:UIColor
        let textColor:UIColor
        
        if section == 0 {
            text = NSLocalizedString("CURRENTLY CONNECTED", comment: "")
            backgroundColor = self.utilities.color(colorCode: .Color60_83_119)
            textColor = self.utilities.color(colorCode: .Color239_239_239)
        } else {
            text = NSLocalizedString("PREVIOUS CONNECTIONS", comment: "")
            backgroundColor = self.utilities.color(colorCode: .Color247_247_248)
            textColor = self.utilities.color(colorCode: .Color140_140_140)
        }
        
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = backgroundColor
        
        let height:CGFloat = 14.0
        let labelFrame = CGRect(
            x: 0,
            y: 0.5*(view.bounds.height - height),
            width: view.bounds.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.textColor = textColor
        label.text = text
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions:[UITableViewRowAction] = [UITableViewRowAction]()
        let deleteImage = UIImage(named: "locks_delete_lock_button")!
        let deleteAction = UITableViewRowAction(
            style: .normal,
            title: self.rowActionTextForIndexPath(indexPath: indexPath))
        { (rowAction, index) in
            var lock:SLLock?
            if indexPath.section == 0 && self.connectedLock != nil {
                lock = self.connectedLock
            } else if indexPath.section == 1 {
                lock = self.unconnectedLocks[indexPath.row]
            }
            
            if lock == nil {
                return
            }
            
            let lrodvc = SLLockResetOrDeleteViewController(
                type: SLLockResetOrDeleteViewControllerType.Delete,
                lock: lock!
            )
            self.navigationController?.pushViewController(lrodvc, animated: true)
        }
        deleteAction.backgroundColor = UIColor(patternImage: deleteImage)
        
        if indexPath.section == 0 {
            let settingsImage = UIImage(named: "locks_setting_button")!
            let settingsAction = UITableViewRowAction(
                style: .normal,
                title: self.rowActionTextForIndexPath(indexPath: indexPath))
            { (rowAction, index) in
                if let lock = self.connectedLock {
                    let lsvc = SLLockSettingsViewController(lock: lock)
                    self.navigationController?.pushViewController(lsvc, animated: true)
                }
            }
            settingsAction.backgroundColor = UIColor(patternImage: settingsImage)
            actions.append(settingsAction)
        } else {
            let connectImage = UIImage(named: "locks_connect_button")!
            let connectAction = UITableViewRowAction(
                style: .normal,
                title: self.rowActionTextForIndexPath(indexPath: indexPath))
            { (rowAction, index) in
                self.addLock()
            }
            connectAction.backgroundColor = UIColor(patternImage: connectImage)
            actions.append(connectAction)
        }
        
        actions.append(deleteAction)
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lock = self.connectedLock , indexPath.section == 0 && indexPath.row == 1 {
            let lsvc = SLLockSettingsViewController(lock: lock)
            self.navigationController?.pushViewController(lsvc, animated: true)
        }
    }
}
