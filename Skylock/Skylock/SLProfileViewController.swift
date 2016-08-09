//
//  SLProfileViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/11/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLProfileViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    SLLabelAndSwitchCellDelegate,
    SLOpposingLabelsTableViewCellDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    var keyboardShowing:Bool = false
    
    var selectedPath:NSIndexPath?
    
    let tableInfo:[[String]] = [
        [
            NSLocalizedString("First name", comment: ""),
            NSLocalizedString("Last name", comment: ""),
            NSLocalizedString("Phone number", comment: ""),
            NSLocalizedString("Email address", comment: ""),
        ],
        [
            NSLocalizedString("Alerts & notifications", comment: ""),
            NSLocalizedString("Change my number", comment: ""),
            NSLocalizedString("Change my password", comment: ""),
            //NSLocalizedString("Delete my account", comment: ""),
            NSLocalizedString("Logout", comment: "")
        ]
    ]
    
    let headerHeight:CGFloat = 50.0
    
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
    
    lazy var alertViewController:UIAlertController = {
        weak var weakSelf:SLProfileViewController? = self
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .Cancel,
            handler: nil
        )
        
        let choosePhotoAction = UIAlertAction(
            title: NSLocalizedString("Choose photo...", comment: ""),
            style: .Default,
            handler: { _ in
                if let this = weakSelf where UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .PhotoLibrary;
                    imagePicker.allowsEditing = true
                    this.presentViewController(imagePicker, animated: true, completion: nil)
                }
            }
        )
        
        let takePhotoAction = UIAlertAction(
            title: NSLocalizedString("Take a new photo", comment: ""),
            style: .Default,
            handler: { _ in
                if let this = weakSelf where UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera;
                    imagePicker.allowsEditing = true
                    this.presentViewController(imagePicker, animated: true, completion: nil)
                }
            }
        )
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(choosePhotoAction)
        alertController.addAction(takePhotoAction)
        
        return alertController
    }()
    
    deinit {
        print("deinit called")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .Plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("MY PROFILE", comment: "")
        
        self.setPictureForUser()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.selected = false
        }
    }

    func cameraButtonPressed() {
        self.presentViewController(self.alertViewController, animated: true, completion: nil)
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
    
    func keyboardWillShow(notification: NSNotification) {
        if self.keyboardShowing {
            return
        }
        
        guard let userInfo:[NSObject:AnyObject] = notification.userInfo else {
            return
        }
        
        let offset:CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height +
            (self.navigationController == nil ? 0.0 : self.navigationController!.navigationBar.bounds.size.height)
            + self.tableView(self.tableView, heightForHeaderInSection: 0)
        let frameValue:NSValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        self.tableView.contentSize = CGSize(
            width: self.tableView.contentSize.width,
            height: self.tableView.contentSize.height + frameValue.CGRectValue().size.height
        )
        self.tableView.contentOffset = CGPoint(x: 0.0, y: offset)
        
        self.keyboardShowing = true
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        self.navigationItem.rightBarButtonItem = rightButton
        
        if self.selectedPath != nil {
            self.tableView.scrollToRowAtIndexPath(self.selectedPath!, atScrollPosition: .Top, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo:[NSObject:AnyObject] = notification.userInfo else {
            return
        }
        
        self.keyboardShowing = false
        self.selectedPath = nil
        self.navigationItem.rightBarButtonItem = nil
        
        let frameValue:NSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue
        self.tableView.contentSize = CGSize(
            width: self.tableView.contentSize.width,
            height: self.tableView.contentSize.height - frameValue.CGRectValue().size.height
        )
    }
    
    func doneButtonPressed() {
        for i in 0...self.tableInfo.first!.count {
            let path = NSIndexPath(forRow: i, inSection: 0)
            if let cell:SLOpposingLabelsTableViewCell =
                self.tableView.cellForRowAtIndexPath(path) as? SLOpposingLabelsTableViewCell
            {
                if cell.isTextFieldFirstResponder() {
                    cell.haveFieldResignFirstReponder()
                    break
                }
            }
        }
    }
    
    func menuButtonPressed() {
//        let transitionHandler = SLViewControllerTransitionHandler()
//        self.modalPresentationStyle = .Custom
//        self.transitioningDelegate = transitionHandler
        if let navController = self.navigationController {
            navController.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
            
            let greyTextColor = UIColor(red: 157, green: 161, blue: 167)
            let blueTextColor = UIColor(red: 87, green: 216, blue: 255)
            
            cellId = String(SLOpposingLabelsTableViewCell)
            var cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCellWithIdentifier(cellId) as? SLOpposingLabelsTableViewCell
            if cell == nil {
                cell = SLOpposingLabelsTableViewCell(style: .Default, reuseIdentifier: cellId)
            }
            
            cell?.selectionStyle = .None
            cell?.delegate = self
            cell?.setProperties(
                leftText,
                rightLabelText: rightText,
                leftLabelTextColor: greyTextColor,
                rightLabelTextColor: blueTextColor,
                shouldEnableTextField: true
            )
            cell?.tag = indexPath.row
            
            return cell!
        }
        
        cellId = String(SLLabelAndSwitchTableViewCell)
        var cell: SLLabelAndSwitchTableViewCell? =
            tableView.dequeueReusableCellWithIdentifier(cellId) as? SLLabelAndSwitchTableViewCell
        if cell == nil {
            cell = SLLabelAndSwitchTableViewCell(accessoryType: .Arrow, reuseId: cellId)
        }
        
        cell?.delegate = self
        cell?.leftAccessoryType = .Arrow
        cell?.textLabel?.text = self.tableInfo[1][indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? self.profilePictureView.bounds.size.height + self.headerHeight : self.headerHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
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
            text = NSLocalizedString("PERSONAL DETAILS", comment: "")
            view.addSubview(self.profilePictureView)
            view.addSubview(self.cameraButton)
        } else {
            text = NSLocalizedString("ACCOUNT SETTINGS", comment: "")
        }
        
        let height:CGFloat = 16.0
        let labelFrame = CGRect(
            x: 0.0,
            y: view.bounds.size.height - 0.5*(self.headerHeight + height),
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
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let usvc:SLUserSettingsViewController = SLUserSettingsViewController()
                self.navigationController?.pushViewController(usvc, animated: true)
            case 1:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .PhoneNumber)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 2:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .Password)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 4:
                let lvc:SLLogoutViewController = SLLogoutViewController()
                self.presentViewController(lvc, animated: true, completion: nil)
            default:
                print("no action for \(indexPath.description)")
            }
        }
    }
    
    // MARK: SLLabelAndSwitchCellDelegate methods
    func switchFlippedForCell(cell: SLLabelAndSwitchTableViewCell, isNowOn: Bool) {
        print("switch flipped to value: \(isNowOn)")
    }
    
    // MARK: SLOpposingLabelsTableViewCellDelegate methods
    func opposingLabelsCellTextFieldBecameFirstResponder(cell: SLOpposingLabelsTableViewCell) {
        self.selectedPath = self.tableView.indexPathForCell(cell)
    }
    
    // MARK: UIImagePickerViewControllerDelegate methods
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.profilePictureView.image = image
        let user:SLUser = SLDatabaseManager.sharedManager().currentUser
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        picManager.savePicture(image, forUserId: user.userId)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
