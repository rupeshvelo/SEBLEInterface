//
//  SLProfileViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/11/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SLLabelAndSwitchCellDelegate {
    let tableInfo:[[String]] = [
        [
            NSLocalizedString("First name", comment: ""),
            NSLocalizedString("Last name", comment: ""),
            NSLocalizedString("Phone number", comment: ""),
            NSLocalizedString("Email address", comment: ""),
            NSLocalizedString("Lives in", comment: "")
        ],
        [
            NSLocalizedString("Alerts & notifications", comment: ""),
            NSLocalizedString("Change my number", comment: ""),
            NSLocalizedString("Change my password", comment: ""),
            NSLocalizedString("Delete my account", comment: ""),
        ]
    ]
    
    lazy var profilePictureView:UIImageView = {
        let frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.bounds.size.width,
            height: 280.0
        )
        
        let imageView:UIImageView = UIImageView(frame: frame)
        
        return imageView
    }()
    
    lazy var cameraButton:UIButton = {
        let image:UIImage = UIImage(named: "icon_camera_Myprofile")!
        let frame = CGRect(
            x: CGRectGetMaxX(self.profilePictureView.frame) - image.size.width - 10.0,
            y: CGRectGetMaxY(self.profilePictureView.frame) - image.size.height - 10.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(cameraButtonPressed), forControlEvents: .TouchDown)
        button.setImage(image, forState: .Normal)
        
        return button
    }()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        
        self.setPictureForUser()
    }

    func cameraButtonPressed() {
        print("camera view pressed")
    }
    
    func setPictureForUser() {
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        let user:SLUser = dbManager.currentUser
        
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        if user.userType == kSLUserTypeFacebook {
            picManager.facebookPicForFBUserId(user.userId, completion: { (image) in
                dispatch_async(dispatch_get_main_queue(), { 
                    self.profilePictureView.image = image
                    self.profilePictureView.setNeedsDisplay()
                })
            })
        } else {
            picManager.getPicWithUserId(user.userId, withCompletion: { (cachedImage) in
                if let image = cachedImage {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.profilePictureView.image = image
                        self.profilePictureView.setNeedsDisplay()
                    })
                }
            })
        }
    }
    
    func profileInfomationRightText(row: Int) -> String? {
        if let user = SLDatabaseManager.sharedManager().currentUser {
            if row == 0 || row == 1 {
                return row == 0 ? user.firstName : user.lastName
            } else if row == 2 {
                return user.phoneNumber
            } else if row == 3 {
                return user.email
            } else if row == 4 {
                return nil
            }
        }
        
        return nil
    }
    
    // MARK tableview delegate & datasource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.tableInfo[0].count
        }
        
        return self.tableInfo[1].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellId:String
        if indexPath.section == 0 {
            let leftText = self.tableInfo[0][indexPath.row]
            let rightText = self.profileInfomationRightText(indexPath.row)
            
            let greyTextColor = UIColor(white: 155.0/255.0, alpha: 1.0)
            let blueTextColor = UIColor(red: 102, green: 177, blue: 227)
            
            cellId = String(SLOpposingLabelsTableViewCell)
            var cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCellWithIdentifier(cellId) as? SLOpposingLabelsTableViewCell
            if cell == nil {
                cell = SLOpposingLabelsTableViewCell(style: .Default, reuseIdentifier: cellId)
            }
            
            cell?.setProperties(
                leftText,
                rightLabelText: rightText,
                leftLabelTextColor: greyTextColor,
                rightLabelTextColor: (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) ?
                    greyTextColor : blueTextColor
            )
            
            return cell!
        }
        
        cellId = String(SLLabelAndSwitchTableViewCell)
        var cell: SLLabelAndSwitchTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellId) as? SLLabelAndSwitchTableViewCell
        if cell == nil {
            cell = SLLabelAndSwitchTableViewCell(accessoryType: .Arrow, reuseId: cellId)
        }
        
        cell?.delegate = self
        cell?.leftAccessoryType = .Arrow
        cell?.textLabel?.text = self.tableInfo[1][indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? self.profilePictureView.bounds.size.height + 50.0 : 50.0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewFrame = CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.size.width,
            height: self.tableView(tableView, heightForHeaderInSection: section)
        )
        
        
        let view:UIView = UIView(frame: viewFrame)
        view.backgroundColor = UIColor(white: 239.0/255.0, alpha: 1.0)
        
        let text:String
        if section == 0 {
            text = NSLocalizedString("PROFILE INFORMATION", comment: "")
            view.addSubview(self.profilePictureView)
            view.addSubview(self.cameraButton)
        } else {
            text = NSLocalizedString("MY ACCOUNT", comment: "")
        }
        
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
    
    // MARK: SLLabelAndSwitchCellDelegate methods
    func switchFlippedForCell(cell: SLLabelAndSwitchTableViewCell, isNowOn: Bool) {
        print("switch flipped to value: \(isNowOn)")
    }
}
