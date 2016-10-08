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
    case InviteFriendsPressed
    case OrderNowPressed
}

protocol SLSlideViewControllerDelegate:class {
    func handleAction(svc: SLSlideViewController, action: SLSlideViewControllerAction)
}

class SLSlideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate:SLSlideViewControllerDelegate?
    
    let cellText:[[String]] = [
        [
            NSLocalizedString("ELLIPSES", comment: ""),
            NSLocalizedString("FIND MY ELLIPSE", comment: "")
        ],
        [
            NSLocalizedString("PROFILE & SETTINGS", comment: ""),
            NSLocalizedString("EMERGENCY CONTACTS", comment: ""),
            NSLocalizedString("HELP", comment: ""),
//            NSLocalizedString("RATE THE APP", comment: ""),
//            NSLocalizedString("INVITE FRIENDS & EARN CREDIT", comment: ""),
            NSLocalizedString("ORDER YOUR ELLIPSE NOW", comment: "")
        ]
    ]
    
    lazy var tableView:UITableView = {
        let table:UITableView = UITableView(frame: self.view.bounds, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        table.backgroundColor = UIColor.clear
        table.rowHeight = 50.0
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = SLUtilities().color(colorCode: .Color130_156_178)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.tableView) {
            self.view.addSubview(self.tableView)
        }
        
        if let path = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRow(at: path)
            cell?.isSelected = false
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: kSLNotificationHideLockBar),
            object: nil
        )
    }
    
    func cellId(section: Int) -> String {
        return section == 0 ? "SLSlideViewControllerSectionMainCell" : "SLSlideViewControllerSectionDetailCell"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = self.cellId(section: indexPath.section)
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellId)
        }
        
        let text = self.cellText[indexPath.section][indexPath.row]
        let fontSize:CGFloat = indexPath.section == 0 ? 16.0 : 11.0
        
        cell?.textLabel?.text = text
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font = UIFont(name: SLFont.MontserratRegular.rawValue, size: fontSize)
        cell?.backgroundColor = UIColor.clear
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.height,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 77.0 : 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
//            case 3:
//                action = .RateTheAppPressed
//            case 4:
//                action = .InviteFriendsPressed
            default:
                action = .OrderNowPressed
            }
        }
        
        self.delegate?.handleAction(svc: self, action: action)
    }
}
