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
        case ProximityLock = 1
        case ProximityUnlock = 2
        case PinCode = 3
        case DeleteLock = 4
        case RemoveLock = 5
    }
    
    var lock:SLLock?

    var firmwareVersion:String = ""
    
    var serialNumber:String = ""
    
    let settingTitles:[String] = [
        NSLocalizedString("Theft detection settings", comment: ""),
        NSLocalizedString("Proximity lock", comment: ""),
        NSLocalizedString("Proximity unlock", comment: ""),
        NSLocalizedString("Pin Code", comment: ""),
        NSLocalizedString("Delete lock", comment: "")
    ]
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 55.0
        table.backgroundColor = UIColor.white
        table.register(
            SLOpposingLabelsTableViewCell.self,
            forCellReuseIdentifier: String(describing: SLOpposingLabelsTableViewCell.self)
        )
        table.register(
            SLLabelAndSwitchTableViewCell.self,
            forCellReuseIdentifier: String(describing: SLLabelAndSwitchTableViewCell.self)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
//        let backButton:UIBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .Action,
//            target: self,
//            action: #selector(backButtonPressed)
//        )
//        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = self.lock?.displayName()
        self.view.addSubview(self.tableView)
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationRemoveLockForUser),
            object: nil,
            queue: nil,
            using: userDeletedLock
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerReadFirmwareVersion),
            object: nil,
            queue: nil,
            using: firmwareRead
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerReadSerialNumber),
            object: nil,
            queue: nil,
            using: serialNumberRead
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: kSLNotificationLockManagerDisconnectedLock),
            object: nil,
            queue: nil,
            using: disconnectedLock
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedpath = self.tableView.indexPathForSelectedRow,
            let cell = self.tableView.cellForRow(at: selectedpath) {
            cell.isSelected = false
        }
        
        if self.lock != nil {
            let lockManager:SLLockManager = SLLockManager.sharedManager
            lockManager.readFirmwareDataForCurrentLock()
            lockManager.readSerialNumberForCurrentLock()
        }
    }
    
    func fieldValueFor(index: Int) -> SettingFieldValue {
        let value:SettingFieldValue
        switch index {
        case 0:
            value = .TheftDetectionSettings
        case 1:
            value = .ProximityLock
        case 2:
            value = .ProximityUnlock
        case 3:
            value = .PinCode
        case 4:
            value = .DeleteLock
        default:
            value = .TheftDetectionSettings
        }
        
        return value
    }
    
    func userDeletedLock(notification: Notification) {
        self.lock = nil
        self.tableView.reloadData()
    }
    
    func backButtonPressed() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func firmwareRead(notification: Notification) {
        guard let firmwareValues:[NSNumber] = notification.object as? [NSNumber] else {
            return
        }
        
        let start = firmwareValues.count - 9
        if start < 0 {
            return
        }
        
        self.firmwareVersion = ""
        print(firmwareValues.description)
        for i in start..<start + 3 {
            self.firmwareVersion += String(describing: firmwareValues[i])
            
            if i == start {
                self.firmwareVersion += "."
            }
        }
        
        let indexPath:IndexPath = IndexPath(row: 3, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func serialNumberRead(notification: Notification) {
        guard let serialNumber:String = notification.object as? String else {
            return
        }
        
        self.serialNumber = serialNumber
        let indexPath = IndexPath(row: 2, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func disconnectedLock(notification: Notification) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    // Mark: UITableViewDelegate and Datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 4
        }
        
        return self.settingTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                rightText = dbManager.getCurrentUser()?.fullName()
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
            
            cellId = String(describing: SLOpposingLabelsTableViewCell.self)
            var cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCell(withIdentifier: cellId) as? SLOpposingLabelsTableViewCell
            if cell == nil {
                cell = SLOpposingLabelsTableViewCell(style: .default, reuseIdentifier: cellId)
            }
            
            cell?.isEditable = false
            cell?.showArrow = showArrow
            cell?.setProperties(
                leftLabelText: leftText,
                rightLabelText: rightText,
                leftLabelTextColor: leftTextColor,
                rightLabelTextColor: rightTextColor,
                shouldEnableTextField: true
            )
            
            return cell!
        }
        
        
        var shouldTurnOn:Bool = false
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        if let user:SLUser = dbManager.getCurrentUser() {
            if self.fieldValueFor(index: indexPath.row) == .ProximityLock {
                shouldTurnOn = user.isAutoLockOn!.boolValue
            } else if self.fieldValueFor(index: indexPath.row) == .ProximityUnlock {
                shouldTurnOn = user.isAutoUnlockOn!.boolValue
            }
        }
        
        let leftText = self.settingTitles[indexPath.row]
        let accessoryType:SLLabelAndSwitchTableViewCellAccessoryType =
            (indexPath.row == SettingFieldValue.ProximityLock.rawValue ||
                indexPath.row == SettingFieldValue.ProximityUnlock.rawValue) ? .ToggleSwitch : .Arrow
        
        cellId = String(describing: SLLabelAndSwitchTableViewCell.self)
        var cell: SLLabelAndSwitchTableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: cellId) as? SLLabelAndSwitchTableViewCell
        if cell == nil {
            cell = SLLabelAndSwitchTableViewCell(accessoryType: accessoryType, reuseId: cellId)
        }
        
        cell?.delegate = self
        cell?.leftAccessoryType = accessoryType
        cell?.textLabel?.text = leftText
        cell?.selectionStyle = accessoryType == .ToggleSwitch ? .none : .default
        cell?.turnSwitchOn(shouldTurnOn: shouldTurnOn)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        label.textAlignment = .center
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lock = self.lock {
            if indexPath.section == 0 {
                if indexPath.row == 3 {
                    let fuvc:SLFirmwareUpdateViewController = SLFirmwareUpdateViewController()
                    self.present(fuvc, animated: true, completion: nil)
                }
            } else {
                switch indexPath.row {
                case SettingFieldValue.TheftDetectionSettings.rawValue:
                    let tdsvc = SLTheftDetectionSettingsViewController(lock: lock)
                    self.navigationController?.pushViewController(tdsvc, animated: true)
                case SettingFieldValue.PinCode.rawValue:
                    let tpvc = SLTouchPadViewController()
                    tpvc.onCanelExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismiss(animated: true, completion: nil)
                    }
                    tpvc.onSaveExit = {[weak weakTpvc = tpvc] in
                        weakTpvc!.dismiss(animated: true, completion: nil)
                    }
                    self.navigationController?.pushViewController(tpvc, animated: true)
                case SettingFieldValue.DeleteLock.rawValue:
                    let lrodvc = SLLockResetOrDeleteViewController(type: .Delete, lock: lock)
                    self.navigationController?.pushViewController(lrodvc, animated: true)
                case SettingFieldValue.RemoveLock.rawValue:
                    SLLockManager.sharedManager.disconnectFromCurrentLock(completion: nil)
                default:
                    print("Lock setting tapped for indexPath \(indexPath.description), but no case handles the path")
                }
            }
        }
    }
    
    // MARK: SLLabelAndSwitchCellDelegate methods
    func switchFlippedForCell(cell: SLLabelAndSwitchTableViewCell, isNowOn: Bool) {
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        guard let user = dbManager.getCurrentUser() else {
            print("Error: could not assign auto lock/unlock property to current user. No current user in db")
            return
        }
        
        for i in 0..<self.tableView.numberOfRows(inSection: 1) {
            let indexPath = IndexPath(row: i, section: 1)
            if let cellAtPath = self.tableView.cellForRow(at: indexPath) as? SLLabelAndSwitchTableViewCell,
                cellAtPath == cell
            {
                if self.fieldValueFor(index: i) == .ProximityLock {
                    user.isAutoLockOn = NSNumber(value: isNowOn)
                    (SLDatabaseManager.sharedManager() as AnyObject).save(user, withCompletion: nil)
                } else if self.fieldValueFor(index: i) == .ProximityUnlock {
                    user.isAutoUnlockOn = NSNumber(value: isNowOn)
                    (SLDatabaseManager.sharedManager() as AnyObject).save(user, withCompletion: nil)
                }
                
                break
            }
        }
    }
}
