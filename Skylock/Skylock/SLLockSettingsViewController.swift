//
//  SLLockSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/9/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SLLabelAndSwitchCellDelegate {
    enum SettingFieldValue: Int {
        case TheftDetectionSettings = 0
        case CapacitiveTouchPad = 1
        case ProximityLockUnlock = 2
        case PinCode = 3
        case DeleteLock = 4
    }
    
    var lock:SLLock?

    let settingTitles:[String] = [
        NSLocalizedString("Theft detection settings", comment: ""),
        NSLocalizedString("Capacitive Touch Pad", comment: ""),
        NSLocalizedString("Proximity lock/unlock", comment: ""),
        NSLocalizedString("Pin Code", comment: ""),
        NSLocalizedString("Delete lock", comment: "")
    ]
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 55.0
        table.backgroundColor = UIColor.whiteColor()
        table.allowsSelection = true
        table.registerClass(
            SLOpposingLabelsTableViewCell.self,
            forCellReuseIdentifier: String(SLOpposingLabelsTableViewCell)
        )
        table.registerClass(
            SLLabelAndSwitchTableViewCell.self,
            forCellReuseIdentifier: String(SLLabelAndSwitchTableViewCell)
        )
        
        return table
    }()
    
    init(lock:SLLock) {
        self.lock = lock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = self.lock?.displayName()
        
        self.view.addSubview(self.tableView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(userResestLock(_:)),
            name: kSLNotificationRemoveLockForUser,
            object: nil
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedpath = self.tableView.indexPathForSelectedRow,
            let cell = self.tableView.cellForRowAtIndexPath(selectedpath) {
            cell.selected = false
        }
    }
    
    func fieldValueForIndex(index: Int) -> SettingFieldValue {
        let value:SettingFieldValue
        switch index {
        case 0:
            value = .TheftDetectionSettings
        case 1:
            value = .CapacitiveTouchPad
        case 2:
            value = .ProximityLockUnlock
        case 3:
            value = .PinCode
        case 4:
            value = .DeleteLock
        default:
            value = .TheftDetectionSettings
        }
        
        return value
    }
    
    func userResestLock(notification: NSNotification) {
        self.lock = nil
        self.tableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        return self.settingTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId:String
        if indexPath.section == 0 {
            let leftText:String
            let rightText:String?
            let leftTextColor = UIColor(white: 155.0/255.0, alpha: 1.0)
            let rightTextColor = UIColor(red: 102, green: 177, blue: 227)
            
            if indexPath.row == 0 {
                leftText = NSLocalizedString("Lock name", comment: "")
                rightText = self.lock?.displayName()
            } else {
                let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
                leftText = NSLocalizedString("Registered owner", comment: "")
                rightText = dbManager.currentUser.fullName()
            }
            
            cellId = String(SLOpposingLabelsTableViewCell)
            var cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCellWithIdentifier(cellId) as? SLOpposingLabelsTableViewCell
            if cell == nil {
                cell = SLOpposingLabelsTableViewCell(style: .Default, reuseIdentifier: cellId)
            }
            
            //cell?.selectionStyle = .None
            cell?.setProperties(
                leftText,
                rightLabelText: rightText,
                leftLabelTextColor: leftTextColor,
                rightLabelTextColor: rightTextColor,
                shouldEnableTextField: false
            )
            
            return cell!
        }
        
        let leftText = self.settingTitles[indexPath.row]
        let accessoryType:SLLabelAndSwitchTableViewCellAccessoryType
        if indexPath.row == SettingFieldValue.CapacitiveTouchPad.rawValue ||
            indexPath.row == SettingFieldValue.ProximityLockUnlock.rawValue
        {
            accessoryType = .ToggleSwitch
        } else {
            accessoryType = .Arrow
        }
        
        cellId = String(SLLabelAndSwitchTableViewCell)
        var cell: SLLabelAndSwitchTableViewCell? =
            tableView.dequeueReusableCellWithIdentifier(cellId) as? SLLabelAndSwitchTableViewCell
        if cell == nil {
            cell = SLLabelAndSwitchTableViewCell(accessoryType: accessoryType, reuseId: cellId)
        }
        
        cell?.delegate = self
        cell?.leftAccessoryType = accessoryType
        cell?.textLabel?.text = leftText
        cell?.selectionStyle = accessoryType == .ToggleSwitch ? .None : .Default
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = section == 0 ? NSLocalizedString("Lock Details", comment: "") : NSLocalizedString("Device Settings", comment: "")
        
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(white: 239.0/255.0, alpha: 1.0)
        
        let height:CGFloat = 16.0
        let labelFrame = CGRect(
            x: 5.0,
            y: view.bounds.height - height - 5.0,
            width: view.bounds.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.font = UIFont.systemFontOfSize(14.0)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = .Left
        label.backgroundColor = UIColor.clearColor()
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let lock = self.lock {
            if indexPath.section == 0 {
               
            } else {
                if indexPath.row == SettingFieldValue.TheftDetectionSettings.rawValue {
                    let tdsvc = SLTheftDetectionSettingsViewController(lock: lock)
                    self.navigationController?.pushViewController(tdsvc, animated: true)
                } else if indexPath.row == SettingFieldValue.PinCode.rawValue {
                    let tpvc = SLTouchPadViewController()
                    tpvc.onCanelExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismissViewControllerAnimated(true, completion: nil)
                    }
                    tpvc.onSaveExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismissViewControllerAnimated(true, completion: nil)
                    }
                    
                    self.presentViewController(tpvc, animated: true, completion: nil)
                } else if indexPath.row == SettingFieldValue.DeleteLock.rawValue {
                    let lrodvc = SLLockResetOrDeleteViewController(type: .Delete, lock: lock)
                    self.navigationController?.pushViewController(lrodvc, animated: true)
                }
            }
        }
        // If there is no lock or the lock has disconnected, we should notify the user.
    }
    
    // MARK: SLLabelAndSwitchCellDelegate methods
    func switchFlippedForCell(cell: SLLabelAndSwitchTableViewCell, isNowOn: Bool) {
        
    }
}
