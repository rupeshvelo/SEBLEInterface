//
//  SLAvailableLocksViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLAvailableLocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var locks:[SLLock] = [SLLock]()
    
    let buttonTagShift:Int = 1000
    
    var tempButtons:[UIButton] = [UIButton]()
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        table.rowHeight = 75.0
        table.backgroundColor = UIColor.clearColor()
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = NSLocalizedString("SELECT AN ELLIPSE", comment: "")
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.tableView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(foundLock),
            name: kSLNotificationLockManagerDiscoverdLock,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector:
            #selector(lockShallowlyConntected(_:)),
            name: kSLNotificationLockManagerShallowlyConnectedLock,
            object: nil
        )
    }
    
    func foundLock() {
        let lockManager = SLLockManager.sharedManager() as! SLLockManager
        let managerLocks = lockManager.locksDiscovereInSearch() as! [SLLock]
        self.locks = managerLocks.reverse()
        let indexPath:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        self.tableView.endUpdates()
    }
    
    func lockShallowlyConntected(notificaiton: NSNotification) {
        if let connectedLock:SLLock = notificaiton.object?["lock"] as? SLLock {
            for lock in self.locks {
                if lock.macAddress == connectedLock.macAddress {
                    self.blinkLock(lock)
                    break
                }
            }
        }
    }
    
    func blinkLockButtonPressed(button: UIButton) {
        for (i, lock) in self.locks.enumerate() {
            let indexPath:NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell:UITableViewCell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
            print("\(cell.textLabel?.text!)")
            
            if let accessoryButton:UIButton = cell.accessoryView as? UIButton {
                let accessoryButtonTag = accessoryButton.tag
                let buttonTag = button.tag
                if accessoryButtonTag == buttonTag {
                    SLLockManager.sharedManager().shallowConnectLock(lock)
                    break
                }
            }
        }
    }

    func blinkLock(lock: SLLock) {
        let lockManager:SLLockManager = SLLockManager.sharedManager() as! SLLockManager
        lockManager.flashLEDsForLock(lock)
    }
    
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
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        }
        
        let lock = self.locks[indexPath.row]
        let image:UIImage = UIImage(named: "button_blink_device_Onboarding")!
        let button:UIButton = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height)
        )
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(blinkLockButtonPressed(_:)), forControlEvents: .TouchDown)
        button.tag = indexPath.row + self.buttonTagShift
        self.tempButtons.append(button)
        
        cell?.textLabel?.text = lock.name
        cell?.imageView?.image = UIImage(named: "table_cell_lock_pic_onboarding")!
        cell?.accessoryView = button
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelHeight:CGFloat = 18.0
        let viewFrame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: viewFrame)
        
        let frame = CGRect(
            x: 0,
            y: 0.5*(view.bounds.size.height - labelHeight),
            width: tableView.bounds.size.width,
            height: labelHeight
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.text = NSLocalizedString("We've found the following Ellipses", comment: "")
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor(red: 102, green: 177, blue: 227)
        
        view.addSubview(label)
        
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
        
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ccvc = SLConcentricCirclesViewController()
        self.navigationController?.pushViewController(ccvc, animated: true)
        
        let lock = self.locks[indexPath.row]
        let lockManager = SLLockManager.sharedManager()
        lockManager.connectToLockWithName(lock.name)
    }
}
