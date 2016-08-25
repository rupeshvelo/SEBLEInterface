//
//  SLLockSettingsViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/9/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockSettingsViewController:
UIViewController,
UITableViewDataSource,
UITableViewDelegate,
SLLabelAndSwitchCellDelegate
{
    enum SettingFieldValue: Int {
        case TheftDetectionSettings = 0
        case ProximityLockUnlock = 1
        case PinCode = 2
        case DeleteLock = 3
        case RemoveLock = 4
    }
    
    var lock:SLLock?

    var firmwareVersion:String = ""
    
    var serialNumber:String = ""
    let settingTitles:[String] = [
        NSLocalizedString("Theft detection settings", comment: ""),
        NSLocalizedString("Proximity lock/unlock", comment: ""),
        NSLocalizedString("Pin Code", comment: ""),
        NSLocalizedString("Delete lock", comment: ""),
        "Remove Lock"
    ]
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 55.0
        table.backgroundColor = UIColor.whiteColor()
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
        
//        let backButton:UIBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .Action,
//            target: self,
//            action: #selector(backButtonPressed)
//        )
//        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = self.lock?.displayName()
        self.view.addSubview(self.tableView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(userDeletedLock(_:)),
            name: kSLNotificationRemoveLockForUser,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(firmwareRead(_:)),
            name: kSLNotificationLockManagerReadFirmwareVersion,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(serialNumberRead(_:)),
            name: kSLNotificationLockManagerReadSerialNumber,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(disconnectedLock(_:)),
            name: kSLNotificationLockManagerDisconnectedLock,
            object: nil
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedpath = self.tableView.indexPathForSelectedRow,
            let cell = self.tableView.cellForRowAtIndexPath(selectedpath) {
            cell.selected = false
        }
        
        if self.lock != nil {
            let lockManager:SLLockManager = SLLockManager.sharedManager
            lockManager.readFirmwareDataForCurrentLock()
            lockManager.readSerialNumberForCurrentLock()
        }
    }
    
    func fieldValueForIndex(index: Int) -> SettingFieldValue {
        let value:SettingFieldValue
        switch index {
        case 0:
            value = .TheftDetectionSettings
        case 1:
            value = .ProximityLockUnlock
        case 2:
            value = .PinCode
        case 3:
            value = .DeleteLock
        default:
            value = .TheftDetectionSettings
        }
        
        return value
    }
    
    func userDeletedLock(notification: NSNotification) {
        self.lock = nil
        self.tableView.reloadData()
    }
    
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func firmwareRead(notification: NSNotification) {
        guard let firmwareValues:[NSNumber] = notification.object as? [NSNumber] else {
            return
        }
        
        let start = firmwareValues.count - 4
        if start < 0 {
            return
        }
        
        self.firmwareVersion = ""
        print(firmwareValues.description)
        for i in start..<firmwareValues.count {
            let value = firmwareValues[i]
            if value.intValue != 0 {
                self.firmwareVersion += String(value)
            }
            
            if i == start + 1 {
                self.firmwareVersion += "."
            }
        }
        
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func serialNumberRead(notification: NSNotification) {
        guard let serialNumber:String = notification.object as? String else {
            return
        }
        
        self.serialNumber = serialNumber
        let indexPath = NSIndexPath(forRow: 2, inSection: 0)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func disconnectedLock(notification: NSNotification) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // Mark: UITableViewDelegate and Datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        
        return self.settingTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId:String
        if indexPath.section == 0 {
            let leftText:String
            var rightText:String?
            let leftTextColor = UIColor(red: 157, green: 161, blue: 167)
            let rightTextColor = (indexPath.row == 1 || indexPath.row == 2)  ? UIColor(red: 140, green: 140, blue: 140) :
                UIColor(red: 69, green: 217, blue: 255)
            let showArrow:Bool
            
            if indexPath.row == 0 {
                leftText = NSLocalizedString("Lock name", comment: "")
                rightText = self.lock?.displayName()
                showArrow = true
            } else if indexPath.row == 1 {
                let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
                leftText = NSLocalizedString("Registered owner", comment: "")
                rightText = dbManager.currentUser.fullName()
                showArrow = false
            } else if indexPath.row == 2 {
                leftText = NSLocalizedString("Serial number", comment: "")
                rightText = self.serialNumber
                showArrow = false
            } else {
                leftText = NSLocalizedString("Firmware", comment: "")
                rightText = self.firmwareVersion
                showArrow = true
            }
            
            cellId = String(SLOpposingLabelsTableViewCell)
            var cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCellWithIdentifier(cellId) as? SLOpposingLabelsTableViewCell
            if cell == nil {
                cell = SLOpposingLabelsTableViewCell(style: .Default, reuseIdentifier: cellId)
            }
            
            cell?.isEditable = false
            cell?.showArrow = showArrow
            cell?.setProperties(
                leftText,
                rightLabelText: rightText,
                leftLabelTextColor: leftTextColor,
                rightLabelTextColor: rightTextColor,
                shouldEnableTextField: true
            )
            
            return cell!
        }
        
        let leftText = self.settingTitles[indexPath.row]
        let accessoryType:SLLabelAndSwitchTableViewCellAccessoryType =
            indexPath.row == SettingFieldValue.ProximityLockUnlock.rawValue ? .ToggleSwitch : .Arrow
        
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
        let text = section == 0 ? NSLocalizedString("Lock Details", comment: "")
            : NSLocalizedString("Device Settings", comment: "")
        
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
        
        let height:CGFloat = 16.0
        let labelFrame = CGRect(
            x: 0.0,
            y: 0.5*(view.bounds.height - height),
            width: view.bounds.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: labelFrame)
        label.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: 14.0)
        label.textColor = UIColor(white: 140.0/255.0, alpha: 1.0)
        label.text = text
        label.textAlignment = .Center
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let lock = self.lock {
            if indexPath.section == 0 {
                if indexPath.row == 3 {
                    let fuvc:SLFirmwareUpdateViewController = SLFirmwareUpdateViewController()
                    self.presentViewController(fuvc, animated: true, completion: nil)
                }
            } else {
                switch indexPath.row {
                case SettingFieldValue.TheftDetectionSettings.rawValue:
                    let tdsvc = SLTheftDetectionSettingsViewController(lock: lock)
                    self.navigationController?.pushViewController(tdsvc, animated: true)
                case SettingFieldValue.PinCode.rawValue:
                    let tpvc = SLTouchPadViewController()
                    tpvc.onCanelExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismissViewControllerAnimated(true, completion: nil)
                    }
                    tpvc.onSaveExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismissViewControllerAnimated(true, completion: nil)
                    }
                    self.navigationController?.pushViewController(tpvc, animated: true)
                case SettingFieldValue.DeleteLock.rawValue:
                    let lrodvc = SLLockResetOrDeleteViewController(type: .Delete, lock: lock)
                    self.navigationController?.pushViewController(lrodvc, animated: true)
                case SettingFieldValue.RemoveLock.rawValue:
                    SLLockManager.sharedManager.disconnectFromCurrentLock()
                default:
                    print("Lock setting tapped for indexPath \(indexPath.description), but no case handles the path")
                }
            }
        }
        // If there is no lock or the lock has disconnected, we should notify the user.
    }
    
    // MARK: SLLabelAndSwitchCellDelegate methods
    func switchFlippedForCell(cell: SLLabelAndSwitchTableViewCell, isNowOn: Bool) {
        
    }
}
