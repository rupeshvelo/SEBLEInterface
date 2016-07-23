//
//  SLSlideViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

enum SLSlideViewControllerAction {
    case EllipsesPressed
    case FindMyEllipsePressed
    case ProfileAndSettingPressed
    case EmergencyContacts
    case HelpPressed
    case RateTheAppPressed
}

protocol SLSlideViewControllerDelegate:class {
    func handleAction(svc: SLSlideViewController, action: SLSlideViewControllerAction)
}

class SLSlideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate:SLSlideViewControllerDelegate?
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        table.backgroundColor = UIColor.clearColor()
        table.rowHeight = 50.0
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 74, green: 80, blue: 96)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.tableView) {
            self.view.addSubview(self.tableView)
        }
        
        if let path = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRowAtIndexPath(path)
            cell?.selected = false
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(
            kSLNotificationHideLockBar,
            object: nil
        )
    }
    
    func cellInfo(indexPath: NSIndexPath) -> [String:String] {
        let text:String
        let imageName:String
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                text = NSLocalizedString("ELLIPSES", comment: "")
                imageName = "icons_leftmenu_ellipses"
            } else {
                text = NSLocalizedString("FIND MY ELLIPSE", comment: "")
                imageName = "icons_navtab_mapview"
            }
        } else {
            if indexPath.row == 0 {
                text = NSLocalizedString("PROFILE & SETTINGS", comment: "")
                imageName = "profile_settings_icon_slideview"
            } else if indexPath.row == 1 {
                text = NSLocalizedString("EMERGENCY CONTACTS", comment: "")
                imageName = "slide_view_emergency_contacts_icon"
            } else if indexPath.row == 2 {
                text = NSLocalizedString("HELP", comment: "")
                imageName = "slideview_help_icon"
            } else {
                text = NSLocalizedString("RATE THE APP", comment: "")
                imageName = "rate_app_icon_slideview"
            }
        }
        
        return [
            "text": text,
            "imageName": imageName,
        ]
    }
    
    func cellId(section: Int) -> String {
        return section == 0 ? "SLSlideViewControllerSectionMainCell" : "SLSlideViewControllerSectionDetailCell"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId = self.cellId(indexPath.section)
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellId)
        }
        
        let cellInfo = self.cellInfo(indexPath)
        let text = cellInfo["text"]!
        let imageName = cellInfo["imageName"]!
        let fontSize:CGFloat = indexPath.section == 0 ? 14.0 : 12.0
        
        cell?.textLabel?.text = text
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.font = UIFont.systemFontOfSize(fontSize)
        cell?.imageView!.image = UIImage(named: imageName)
        cell?.backgroundColor = UIColor.clearColor()
    
        return cell!
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.height,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 77.0 : 144.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let action:SLSlideViewControllerAction
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                action = .EllipsesPressed
            default:
                action = .FindMyEllipsePressed
            }
        } else {
            switch indexPath.row {
            case 0:
                action = .ProfileAndSettingPressed
            case 1:
                action = .EmergencyContacts
            case 2:
                action = .HelpPressed
            default:
                action = .RateTheAppPressed
            }
        }
        
        self.delegate?.handleAction(self, action: action)
    }
}
