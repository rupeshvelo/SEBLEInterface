//
//  SLAvailableLocksViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/29/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLAvailableLocksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var locks:[SLLock] = SLLockManager.sharedManager().availableLocks() as! [SLLock]
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
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addSubview(self.tableView)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(foundLock),
            name: "kSLNotificationLockManagerDiscoverdLock",
            object: nil
        )
    }
    
    func foundLock() {
        
    }
    
    func addLockButtonPressed() {
        print("add lock button pressed")
        
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
        let image:UIImage = UIImage(named: "button_connect_device_Onboarding")!
        let button:UIButton = UIButton(frame: CGRect(
            x: 0,
            y: 0,
            width: image.size.width,
            height: image.size.height)
        )
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(addLockButtonPressed), forControlEvents: .TouchDown)
        
        cell?.textLabel?.text = lock.name
        cell?.imageView?.image = UIImage(named: "table_cell_lock_pic_onboarding")!
        cell?.accessoryView = button
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelHeight:CGFloat = 15.0
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
        label.font = UIFont.systemFontOfSize(labelHeight)
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
}
