//
//  SLContactViewController.swift
//  Skylock
//
//  Created by Andre Green on 4/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import Contacts

protocol SLContactViewControllerDelegate {
    func calloutViewTapped(calloutView: SLMapCalloutView)
}

class SLContactViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    var contacts:[CNContact] = [CNContact]()
    var currentText: String = ""
    let contactCellId:String = String(SLAddContactTableViewCell)
    
    lazy var searchBar: UISearchBar = {
        var y0: CGFloat = 0.0;
        if let navController = self.navigationController {
            y0 = navController.navigationBar.bounds.size.height
        }
        y0 += UIApplication.sharedApplication().statusBarFrame.size.height
        
        var bar = UISearchBar(frame: CGRectMake(0, y0, self.view.bounds.size.width, 45.0))
        bar.delegate = self
        bar.placeholder = NSLocalizedString("Invite Friends", comment: "")
        bar.setShowsCancelButton(true, animated: true)
        bar.showsBookmarkButton = false;
        bar.tintColor = UIColor.whiteColor()
        
        return bar
    }()
    
    lazy var tableView: UITableView = {
        let searchBarMaxY = CGRectGetMaxY(self.searchBar.frame)
        let table:UITableView = UITableView.init(frame: CGRectMake(
            0,
            searchBarMaxY,
            self.view.bounds.size.width,
            self.view.bounds.size.height - searchBarMaxY
            ), style: UITableViewStyle.Plain
        )
        table.dataSource = self;
        table.delegate = self;
        table.rowHeight = 50
        table.separatorStyle = UITableViewCellSeparatorStyle.None
        table.registerClass(SLAddContactTableViewCell.self, forCellReuseIdentifier: self.contactCellId)
    
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.searchBar)
        self.view.addSubview(self.tableView)
    }
    
    func getContactsFromCurrentText() {
        if self.currentText == "" {
            self.contacts = []
            return;
        }
        
        let store = CNContactStore()
        do {
            let contacts = try store.unifiedContactsMatchingPredicate(
                CNContact.predicateForContactsMatchingName(self.currentText),
                keysToFetch:[
                    CNContactGivenNameKey,
                    CNContactFamilyNameKey,
                    CNContactImageDataKey,
                    CNContactEmailAddressesKey
                ]
            )
            
            print("there are \(contacts.count) contacts to display.")
            self.contacts = contacts
        } catch {
            print("There was an exception getting CNContacts");
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let contact: CNContact = self.contacts[indexPath.row]
        let text = contact.givenName + " " + contact.familyName

        let cell: SLAddContactTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.contactCellId, forIndexPath: indexPath) as! SLAddContactTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.updateImageWithData(contact.imageData)
        cell.textLabel!.text = text
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let searchText = searchBar.text {
            self.currentText = (searchText as NSString).stringByReplacingCharactersInRange(range, withString: text)
            self.getContactsFromCurrentText()
        } else {
            self.contacts = []
        }
        
        self.tableView.reloadData()
        
        return true
    }
}
