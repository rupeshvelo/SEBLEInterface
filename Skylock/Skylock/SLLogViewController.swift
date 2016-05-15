//
//  SLLogViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/14/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLogViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    var logs:[SLLog] = [SLLog]()
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        table.rowHeight = 80.0
        table.delegate = self
        table.dataSource = self
        
        return table
    }()
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        let backButton:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Done,
            target: self,
            action: #selector(backButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = backButton;
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let databaseManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        self.logs = databaseManager.getAllLogs() as! [SLLog]
        self.logs.sortInPlace({$0.date!.compare($1.date!) == .OrderedDescending})
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(newLogAdded(_:)),
            name: kSLNotificationLogUpdated,
            object: nil
        )
    }
    
    func backButtonPressed() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func newLogAdded(notification: NSNotification) {
        if let info = notification.object as? [String:SLLog], let log = info["log"] {
            self.logs.insert(log, atIndex: 0)
            let newIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths(
                [newIndexPath],
                withRowAnimation: UITableViewRowAnimation.Automatic
            )
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "SLLogViewControllerCell"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        }
        
        let log = self.logs[indexPath.row]
        cell!.textLabel?.text = log.entry
        cell!.detailTextLabel?.text = self.dateFormatter.stringFromDate(log.date!)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let log = self.logs[indexPath.row]
        let dvc:SLLogDetailViewController = SLLogDetailViewController(nibName: nil, bundle: nil, log: log)
        self.navigationController?.pushViewController(dvc, animated: true) 
    }
}
