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
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        table.backgroundColor = UIColor.whiteColor()
        table.rowHeight = 54.0
        table.scrollEnabled = false
        table.registerClass(
            SLLockDetailsTableViewCell.self,
            forCellReuseIdentifier: String(SLLockDetailsTableViewCell)
        )
        
        return table
    }()
    
    lazy var unconnectedLocks:[SLLock] = {
        let lockManager = SLLockManager.sharedManager() as! SLLockManager
        let locks:[SLLock] = lockManager.unconnectedLocksForCurrentUser() as! [SLLock]
        
        return locks
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let addLockButton:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Add,
            target: self,
            action: #selector(addLock)
        )
        self.navigationItem.rightBarButtonItem = addLockButton
        
        let lockManager = SLLockManager.sharedManager() as! SLLockManager
        self.connectedLock = lockManager.getCurrentLock()
        
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .Plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("Ellipses", comment: "")
        
        self.view.addSubview(self.tableView)
    }
    
    func menuButtonPressed() {
        if let navController = self.navigationController {
            navController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
//        let transitionHandler = SLViewControllerTransitionHandler()
//        self.navigationController?.modalPresentationStyle = .Custom
//        self.navigationController?.transitioningDelegate = transitionHandler
//        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addLock() {
        let lockManager:SLLockManager = SLLockManager()
        lockManager.shouldEnterActiveSearchMode(true)
        
        let alvc = SLAvailableLocksViewController()
        self.navigationController?.pushViewController(alvc, animated: true)
    }
    
    func rowActionTextForIndexPath(indexPath: NSIndexPath) -> String {
        return "         "
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        
        return self.unconnectedLocks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let optionsDotsImage:UIImage = UIImage(named: "icon_more_dots_gray_horizontal_Ellipses")!
        let optionsDotsView:UIImageView = UIImageView(image: optionsDotsImage)
        
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell:SLLockDetailsTableViewCell? = tableView.dequeueReusableCellWithIdentifier(
                String(SLLockDetailsTableViewCell)
                ) as? SLLockDetailsTableViewCell
            
            if let detailCell = cell, let lock = self.connectedLock {
                detailCell.lock = lock
                detailCell.accessoryView = optionsDotsView
                detailCell.selectionStyle = .None
                
                return detailCell
            }
        }
        
        let cellId = "SLLockDetailViewControllerNormalCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        if (indexPath.section == 1) {
            let lock = self.unconnectedLocks[indexPath.row]
            cell?.textLabel!.text = lock.displayName()
            cell?.accessoryView = optionsDotsView
        }
        
        cell?.selectionStyle = .None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 33.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text:String
        let color:UIColor
        let textColor:UIColor
        
        if section == 0 {
            text = NSLocalizedString("CURRENTLY CONNECTED", comment: "")
            color = UIColor(red: 76, green: 79, blue: 97)
            textColor = UIColor(white: 239.0/255.0, alpha: 1.0)
        } else {
            text = NSLocalizedString("CONNECTION HISTORY", comment: "")
            color = UIColor(red: 155, green: 155, blue: 155)
            textColor = UIColor.whiteColor()
        }
        
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = color
        
        let height:CGFloat = 14.0
        let labelFrame = CGRect(
            x: 0,
            y: 0.5*(view.bounds.height - height),
            width: view.bounds.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.font = UIFont.systemFontOfSize(12.0)
        label.textColor = textColor
        label.text = text
        label.textAlignment = .Center
        label.backgroundColor = UIColor.clearColor()
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section != 0 || indexPath.row != 1 {
            return []
        }
        
        let deleteImage = UIImage(named: "lock_details_delete_icon")!
        let deleteAction = UITableViewRowAction(style: .Normal, title: self.rowActionTextForIndexPath(indexPath)) { (rowAction, index) in
            print("delete action button pressed")
        }
        deleteAction.backgroundColor = UIColor(patternImage: deleteImage)
        
        let settingsImage = UIImage(named: "lock_details_settings_icon")!
        let settingsAction = UITableViewRowAction(style: .Normal, title: self.rowActionTextForIndexPath(indexPath)) { (rowAction, index) in
            print("settings action button pressed")
        }
        settingsAction.backgroundColor = UIColor(patternImage: settingsImage)
        
        return [deleteAction, settingsAction]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let lock = self.connectedLock where indexPath.section == 0 && indexPath.row == 1 {
            let lsvc = SLLockSettingsViewController(lock: lock)
            self.navigationController?.pushViewController(lsvc, animated: true)
        }
    }
}
