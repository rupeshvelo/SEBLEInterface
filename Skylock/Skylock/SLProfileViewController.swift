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
    private enum UserProperty {
        case FirstName
        case LastName
        case Password
        case Email
    }
    
    private var keyboardShowing:Bool = false
    
    private var selectedPath:IndexPath?
    
    private let tableInfo:[[String]] = [
        [
            NSLocalizedString("First name", comment: ""),
            NSLocalizedString("Last name", comment: ""),
            NSLocalizedString("Phone number", comment: ""),
            NSLocalizedString("Email address", comment: ""),
        ],
        [
            NSLocalizedString("Change first name", comment: ""),
            NSLocalizedString("Change last name", comment: ""),
            NSLocalizedString("Change my number", comment: ""),
            NSLocalizedString("Change my password", comment: ""),
            //NSLocalizedString("Delete my account", comment: ""),
            NSLocalizedString("Logout", comment: "")
        ]
    ]
    
    private var changedUserProperties: [UserProperty:String?] = [
        .FirstName: nil,
        .LastName: nil,
        .Password: nil,
        .Email: nil
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
            x: self.profilePictureView.frame.maxX - image.size.width - 10.0,
            y: self.profilePictureView.frame.maxY - image.size.height - 10.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let button:UIButton = UIButton(frame: frame)
        button.addTarget(self, action: #selector(cameraButtonPressed), for: .touchDown)
        button.setImage(image, for: .normal)
        
        return button
    }()
    
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
    
    lazy var alertViewController:UIAlertController = {
        weak var weakSelf:SLProfileViewController? = self
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .cancel,
            handler: nil
        )
        
        let choosePhotoAction = UIAlertAction(
            title: NSLocalizedString("Choose photo...", comment: ""),
            style: .default,
            handler: { _ in
                if let this = weakSelf , UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .photoLibrary;
                    imagePicker.allowsEditing = true
                    this.present(imagePicker, animated: true, completion: nil)
                }
            }
        )
        
        let takePhotoAction = UIAlertAction(
            title: NSLocalizedString("Take a new photo", comment: ""),
            style: .default,
            handler: { _ in
                if let this = weakSelf , UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = true
                    this.present(imagePicker, animated: true, completion: nil)
                }
            }
        )
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(choosePhotoAction)
        alertController.addAction(takePhotoAction)
        
        return alertController
    }()
    
    deinit {
        print("deinit called")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = NSLocalizedString("MY PROFILE", comment: "")
        
        self.setPictureForUser()
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillShow,
            object: nil,
            queue: nil,
            using: keyboardWillShow
        )
        
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIKeyboardWillHide,
            object: nil,
            queue: nil,
            using: keyboardWillHide
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.isSelected = false
        }
    }

    func cameraButtonPressed() {
        self.present(self.alertViewController, animated: true, completion: nil)
    }
    
    func setPictureForUser() {
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        guard let user:SLUser = dbManager.getCurrentUser() else {
            print("Error: can't set picture for current user. No current user in db")
            return
        }
        
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        if user.userType == kSLUserTypeFacebook {
            picManager.facebookPic(forFBUserId: user.userId, completion: { (image) in
                DispatchQueue.main.async {
                    self.profilePictureView.image = image
                    self.profilePictureView.setNeedsDisplay()
                }
            })
        } else {
            picManager.getPicWithUserId(user.userId, withCompletion: { (cachedImage) in
                if let image = cachedImage {
                    DispatchQueue.main.async {
                        self.profilePictureView.image = image
                        self.profilePictureView.setNeedsDisplay()
                    }
                }
            })
        }
    }
    
    func profileInfomationRightText(row: Int) -> String? {
        let dbManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        if let user = dbManager.getCurrentUser() {
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
    
    func keyboardWillShow(notification: Notification) {
        if self.keyboardShowing {
            return
        }
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let offset:CGFloat = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController == nil ? 0.0 : self.navigationController!.navigationBar.bounds.size.height)
            + self.tableView(self.tableView, heightForHeaderInSection: 0)
        
        
        self.tableView.contentSize = CGSize(
            width: self.tableView.contentSize.width,
            height: self.tableView.contentSize.height + frameValue.cgRectValue.size.height
        )
        self.tableView.contentOffset = CGPoint(x: 0.0, y: offset)
        
        self.keyboardShowing = true
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonPressed)
        )
        self.navigationItem.rightBarButtonItem = rightButton
        
        if self.selectedPath != nil {
            self.tableView.scrollToRow(at: self.selectedPath! as IndexPath, at: .top, animated: true)
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        self.keyboardShowing = false
        self.selectedPath = nil
        self.navigationItem.rightBarButtonItem = nil
        
        guard let frameValue:NSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        
        self.tableView.contentSize = CGSize(
            width: self.tableView.contentSize.width,
            height: self.tableView.contentSize.height - frameValue.cgRectValue.size.height
        )
    }
    
    func doneButtonPressed() {
        for i in 0...self.tableInfo.first!.count {
            let path = IndexPath(row: i, section: 0)
            if let cell:SLOpposingLabelsTableViewCell =
                self.tableView.cellForRow(at: path) as? SLOpposingLabelsTableViewCell
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
            navController.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK tableview delegate & datasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.tableInfo[0].count
        }
        
        return self.tableInfo[1].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId:String
        if indexPath.section == 0 {
            let leftText = self.tableInfo[0][indexPath.row]
            let rightText = self.profileInfomationRightText(row: indexPath.row)
            
            let greyTextColor = UIColor(red: 157, green: 161, blue: 167)
            let blueTextColor = UIColor(red: 87, green: 216, blue: 255)
            
            cellId = String(describing: SLOpposingLabelsTableViewCell.self)
            let cell: SLOpposingLabelsTableViewCell? =
                tableView.dequeueReusableCell(withIdentifier: cellId) as? SLOpposingLabelsTableViewCell
            cell?.selectionStyle = .none
            cell?.delegate = self
            cell?.setProperties(
                leftLabelText: leftText,
                rightLabelText: rightText,
                leftLabelTextColor: greyTextColor,
                rightLabelTextColor: blueTextColor,
                shouldEnableTextField: false
            )
            cell?.tag = indexPath.row
            
            return cell!
        }
        
        cellId = String(describing: SLLabelAndSwitchTableViewCell.self)
        let cell: SLLabelAndSwitchTableViewCell? =
            tableView.dequeueReusableCell(withIdentifier: cellId) as? SLLabelAndSwitchTableViewCell
        cell?.delegate = self
        cell?.leftAccessoryType = .Arrow
        cell?.textLabel?.text = self.tableInfo[1][indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? self.profilePictureView.bounds.size.height + self.headerHeight : self.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
        label.textAlignment = .center
        
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .FirstName)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 1:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .LastName)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 2:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .PhoneNumber)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 3:
                let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .Password)
                self.navigationController?.pushViewController(msdvc, animated: true)
            case 4:
                let lvc:SLLogoutViewController = SLLogoutViewController()
                self.present(lvc, animated: true, completion: nil)
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
        self.selectedPath = self.tableView.indexPath(for: cell)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingImage image: UIImage,
                              editingInfo: [String : AnyObject]?
        )
    {
        let dbManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
        guard let user:SLUser = dbManager.getCurrentUser() else {
            return
        }

        self.profilePictureView.image = image
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        picManager.savePicture(image, forUserId: user.userId)
        
        self.dismiss(animated: true, completion: nil)
    }
}
