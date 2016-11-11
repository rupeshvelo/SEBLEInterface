//
//  SLProfileViewController.swift
//  Skylock
//
//  Created by Andre Green on 6/11/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLProfileViewController:
    SLBaseViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    SLLabelAndSwitchCellDelegate,
    SLOpposingLabelsTableViewCellDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{
    private enum UserProperty {
        case FirstName
        case LastName
        case PhoneNumber
        case Email
    }
    
    private enum ResponseError {
        case InternalServer
    }
    
    let user:SLUser = (SLDatabaseManager.sharedManager() as! SLDatabaseManager).getCurrentUser()!
    
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
            NSLocalizedString("Change my password", comment: ""),
            //NSLocalizedString("Change my number", comment: ""),
            //NSLocalizedString("Delete my account", comment: ""),
            NSLocalizedString("Logout", comment: "")
        ]
    ]
    
    private var changedUserProperties:[UserProperty:String] = [
        .FirstName: "",
        .LastName: "",
        .PhoneNumber: "",
        .Email: ""
    ]
    
    let headerHeight:CGFloat = 50.0
    
    lazy var profilePictureView:UIImageView = {
        let frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: self.view.bounds.size.width,
            height: self.view.bounds.size.width
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
        table.rowHeight = 42.0
        table.backgroundColor = UIColor.white
        table.allowsSelectionDuringEditing = true
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
    
    lazy var imagePickerController:UIImagePickerController = {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        return imagePicker
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
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    self.imagePickerController.sourceType = .photoLibrary
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
        }
        )
        
        let takePhotoAction = UIAlertAction(
            title: NSLocalizedString("Take a new photo", comment: ""),
            style: .default,
            handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePickerController.sourceType = .camera
                    self.present(self.imagePickerController, animated: true, completion: nil)
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
    
    private func presentWarningController(errorType: ResponseError) {
        let info:String
        switch errorType {
        case .InternalServer:
            info = NSLocalizedString(
                "Sorry. Error in Response",
                comment: ""
            )
            let texts:[SLWarningViewControllerTextProperty:String?] = [
                .Header: NSLocalizedString("Server Error", comment: ""),
                .Info: info,
                .CancelButton: NSLocalizedString("OK", comment: ""),
                .ActionButton: nil
            ]
            
            self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
        }
    }
    
    func cameraButtonPressed() {
        self.present(self.alertViewController, animated: true, completion: nil)
    }
    
    func setPictureForUser() {
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        if self.user.userType == kSLUserTypeFacebook {
            picManager.facebookPic(forFBUserId: self.user.userId, completion: { (image) in
                if let profileImage = image {
                    self.setProfile(image: profileImage)
                }
            })
        } else {
            picManager.getPicWithUserId(self.user.userId, withCompletion: { (cachedImage) in
                if let profileImage = cachedImage {
                    self.setProfile(image: profileImage)
                }
            })
        }
    }
    
    func setProfile(image: UIImage) {
        DispatchQueue.main.async {
            for subview in self.profilePictureView.subviews {
                subview.removeFromSuperview()
            }
            
            self.profilePictureView.image = image
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.profilePictureView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            let scaledImage = self.scaledProfile(image: image)
            let scaledImageView:UIImageView = UIImageView(image: scaledImage)
            scaledImageView.frame = CGRect(
                x: 0.5*(self.profilePictureView.bounds.size.width - scaledImageView.bounds.size.width),
                y: 0.5*(self.profilePictureView.bounds.size.height - scaledImageView.bounds.size.height),
                width: scaledImageView.bounds.size.width,
                height: scaledImageView.bounds.size.height
            )
        
            self.profilePictureView.addSubview(blurEffectView)
            self.profilePictureView.addSubview(scaledImageView)
            self.profilePictureView.setNeedsDisplay()
        }
    }
    
    func profileInfomationRightText(row: Int) -> String? {
        if row == 0 || row == 1 {
            return row == 0 ? self.user.firstName != nil ? self.user.firstName : "" :
                self.user.lastName != nil ? self.user.lastName : ""
        } else if row == 2 {
            return self.user.phoneNumber != nil ? self.user.phoneNumber : ""
        } else if row == 3 {
            return self.user.email != nil ? self.user.email : ""
        } else if row == 4 {
            return nil
        }
        
        return nil
    }
    
    func updateUser() {
        if !((self.changedUserProperties[.FirstName]! != "" &&
            self.changedUserProperties[.FirstName]! != self.user.firstName) ||
            (self.changedUserProperties[.LastName]! != "" &&
                self.changedUserProperties[.LastName]! != self.user.lastName) ||
            (self.changedUserProperties[.PhoneNumber]! != "" &&
                self.changedUserProperties[.PhoneNumber]! != self.user.phoneNumber) ||
            (self.changedUserProperties[.Email]! != "" &&
                self.changedUserProperties[.Email]! != self.user.email))
        {
            // Since no user properties have been changed, we can just bail out here.
            return
        }
        
        let keyChainHandler = SLKeychainHandler()
        guard let restToken = keyChainHandler.getItemForUsername(
            userName: self.user.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .RestToken
            ) else
        {
            // TODO: There should probably be some UI here to notify the user if this occurs.
            print("Error: could not update user in profile. The current user does not have a REST token")
            return
        }
        
        guard let password = keyChainHandler.getItemForUsername(
            userName: self.user.userId!,
            additionalSeviceInfo: nil,
            handlerCase: .Password
            ) else
        {
            // TODO: There should probably be some UI here to notify the user if this occurs.
            print("Error: could not update user in profile. The current user does not have a password.")
            return
        }
        
        let restManager:SLRestManager = SLRestManager.sharedManager() as! SLRestManager
        let headers = [
            "Authorization": restManager.basicAuthorizationHeaderValueUsername(restToken, password: "")
        ]
        
        let subRoutes = [self.user.userId!, restManager.path(asString: .profile)]
        var firstName:Any = NSNull()
        var lastName:Any = NSNull()
        var phoneNumber:Any = NSNull()
        var email:Any = NSNull()
        
        if let fName = self.changedUserProperties[.FirstName] {
            firstName = fName
        }
        
        if let lName = self.changedUserProperties[.LastName] {
            lastName = lName
        }
        
        if let pNumber = self.changedUserProperties[.PhoneNumber] {
            phoneNumber = pNumber
        }
        
        if let mail = self.changedUserProperties[.Email] {
            email = mail
        }
        
        let userProperties:[String:Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email,
            "phone_number": phoneNumber,
            "user_id": self.user.userId!,
            "password": password,
            "user_type": self.user.userType!,
            "country_code": NSNull()
        ]
        
        restManager.postObject(
            userProperties,
            serverKey: SLRestManagerServerKey.main,
            pathKey: SLRestManagerPathKey.users,
            subRoutes: subRoutes,
            additionalHeaders: headers,
            completion: { (status: UInt, response:[AnyHashable : Any]?) in
                DispatchQueue.main.async {
                    if status == 200 || status == 201 {
                        var propertiesToSave:[String:Any] = [String:Any]()
                        for (key, property) in userProperties {
                            if !(property is NSNull) || (property is String && property as! String != "") {
                                propertiesToSave[key] = property
                            }
                        }
                        
                        let databaseManager:SLDatabaseManager = SLDatabaseManager.sharedManager() as! SLDatabaseManager
                        databaseManager.saveUser(
                            with: propertiesToSave,
                            isFacebookUser: self.user.userType == kSLUserTypeFacebook
                        )
                        self.tableView.reloadData()
                    } else {
                        let texts:[SLWarningViewControllerTextProperty:String?] = [
                            .Header: NSLocalizedString("Server Error", comment: ""),
                            .Info: NSLocalizedString(
                                "There was an error saving your info. Please try again later.",
                                comment: ""
                            ),
                            .CancelButton: NSLocalizedString("OK", comment: ""),
                            .ActionButton: nil
                        ]
                        
                        self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
                    }
                }
        }
        )
    }
    
    func scaledProfile(image: UIImage) -> UIImage? {
        let scale = image.size.width > image.size.height ? self.profilePictureView.bounds.size.width/image.size.width
            : self.profilePictureView.bounds.size.height/image.size.height
        let size = image.size.applying(CGAffineTransform(scaleX: scale, y: scale))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
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
        self.updateUser()
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
                shouldEnableTextField: true
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
                if self.user.userType == nil || self.user.userType == kSLUserTypeFacebook {
                    let texts:[SLWarningViewControllerTextProperty:String?] = [
                        .Header: NSLocalizedString("Uh-oh...", comment: ""),
                        .Info: NSLocalizedString(
                            "Since you signed in with Facebook, we're not able to change your password.",
                            comment: ""
                        ),
                        .CancelButton: NSLocalizedString("OK", comment: ""),
                        .ActionButton: nil
                    ]
                    
                    self.presentWarningViewControllerWithTexts(texts: texts, cancelClosure: nil)
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.setSelected(false, animated: false)
                    }
                } else {
                    let msdvc:SLModifySensitiveDataViewController = SLModifySensitiveDataViewController(type: .Password)
                    self.navigationController?.pushViewController(msdvc, animated: true)
                }
            case 1:
                let lvc:SLLogoutViewController = SLLogoutViewController(userId: user.userId!)
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
    
    func opposingLablesCellTextFieldChangeEventOccured(cell: SLOpposingLabelsTableViewCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            print("Error: no index path for opposing label table view cell")
            return
        }
        
        let property:UserProperty
        switch indexPath.row {
        case 0:
            property = .FirstName
        case 1:
            property = .LastName
        case 2:
            property = .PhoneNumber
        default:
            property = .Email
        }
        
        self.changedUserProperties[property] = cell.rightField.text
    }
    
    // UIImagePickerController Delegate Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Error: could not set profile image. There was no image returned by the picker")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let picManager:SLPicManager = SLPicManager.sharedManager() as! SLPicManager
        picManager.savePicture(image, forUserId: self.user.userId)
        self.setProfile(image: image)
        
        self.dismiss(animated: true, completion: nil)
    }
}
