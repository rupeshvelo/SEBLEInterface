//
//  SLEmergencyContactsViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

class SLEmergencyContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var contacts:[SLEmergencyContact] = [SLEmergencyContact]()
    
    let maxNumberOfContacts:Int = 3
    
    var onExit:(() -> Void)?
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 92.0
        table.separatorInset = UIEdgeInsetsZero
        table.backgroundColor = UIColor(white: 242.0/255.0, alpha: 1.0)
        table.registerClass(
            SLEmergenyContactTableViewCell.self,
            forCellReuseIdentifier: String(SLEmergenyContactTableViewCell)
        )
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = NSLocalizedString("FIND EMERGENCY CONTACTS", comment: "")
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .Plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.getEmergencyContats()
        
        self.view.addSubview(self.tableView)
    }
    
    func getEmergencyContats() {
        let allContacts:[SLEmergencyContact] =
            SLDatabaseManager.sharedManager().emergencyContacts() as! [SLEmergencyContact]
        self.contacts.removeAll()
        var counter:Int = 0
        for contact in allContacts {
            if let isCurrent = contact.isCurrentContact
                where isCurrent.boolValue && counter < self.maxNumberOfContacts
            {
                self.contacts.append(contact)
                counter += 1
            }
        }
    }
    
    func menuButtonPressed() {
        if self.onExit == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.onExit!()
        }
    }
    
    // MARK: UITableView Delegate and Datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.contacts.count : 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell:SLEmergenyContactTableViewCell? = tableView.dequeueReusableCellWithIdentifier(
                String(SLEmergenyContactTableViewCell)
                ) as? SLEmergenyContactTableViewCell
            
            if cell == nil {
                cell = SLEmergenyContactTableViewCell(
                    style: .Default,
                    reuseIdentifier: String(SLEmergenyContactTableViewCell)
                )
            }
            
            var name = "First name Last name"
            if indexPath.row < self.contacts.count {
                let contact = self.contacts[indexPath.row]
                name = contact.fullName()
            }
            
            let image = UIImage(named: "sharing_default_picture")!
            let properties:[SLEmergencyContactTableViewCellProperty:AnyObject] = [
                .Name: name,
                .Pic: image
            ]
            
            cell?.setProperties(properties)
            
            return cell!
        }
        
        let cellId:String = "SLEmergenyContactDefaultTableViewCell"
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellId)
        }
        
        cell?.textLabel!.text = NSLocalizedString("Contacts", comment: "")
        cell?.textLabel!.font = UIFont.systemFontOfSize(14.0)
        cell?.textLabel!.textColor = UIColor(red: 155, green: 155, blue: 155)
        cell?.imageView!.image = UIImage(named: "contacts_phone_icon")
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20.0 : 144.0
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 20.0 : 144.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewFrame = CGRect(
            x: 0.0,
            y: 0.0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view = UIView(frame: viewFrame)
        view.backgroundColor = UIColor(white: 242.0/255.0, alpha: 1.0)
        
        if section == 1 {
            let xPadding:CGFloat = 26.0
            let labelWidth = self.view.bounds.size.width - 2*xPadding
            let utility = SLUtilities()
            let font = UIFont.systemFontOfSize(12)
            let text = NSLocalizedString(
                "Nominate 3 close friends or family members as your emergency contacts. In the event of a crash, " +
                "they will be notified by the contact methods you choose.",
                comment: ""
            )
            let labelSize:CGSize = utility.sizeForLabel(
                font,
                text: text,
                maxWidth: labelWidth,
                maxHeight: CGFloat.max,
                numberOfLines: 0
            )
            
            let frame = CGRectMake(
                xPadding,
                0.5*(view.bounds.size.height - labelSize.height),
                labelWidth,
                labelSize.height
            )
            
            let label:UILabel = UILabel(frame: frame)
            label.textColor = UIColor(red: 155, green: 155, blue: 155)
            label.text = text
            label.textAlignment = .Center
            label.font = font
            label.numberOfLines = 0
            
            view.addSubview(label)
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let ecvc = SLEmergencyContactsViewController()
        }
    }
}
