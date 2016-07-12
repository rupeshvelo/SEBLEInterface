//
//  SLContactsLetterViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/4/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

protocol SLContactsLetterViewControllerDelegate:class {
    func contactsLetterViewController(letterViewController: SLContactsLetterViewController, letter:String)
}

class SLContactsLetterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate:SLContactsLetterViewControllerDelegate?
    
    let letters:[String] = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z"
    ]
    
    lazy var tableView:UITableView = {
        let tableView:UITableView = UITableView(frame: self.view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = self.view.bounds.size.height/CGFloat(self.letters.count)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = .None
        tableView.scrollEnabled = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.tableView) {
            self.view.addSubview(self.tableView)
        }
    }
    
    // MARK: UITableView Delegate and Datasource Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.letters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = "SLContactsLetterViewControllerCell"
        var cell:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text = self.letters[indexPath.row]
        cell?.textLabel?.textColor = UIColor(red: 102, green: 177, blue: 227)
        cell?.textLabel?.font = UIFont.systemFontOfSize(10)
        cell?.selectionStyle = .None
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.contactsLetterViewController(self, letter: self.letters[indexPath.row])
    }
}
