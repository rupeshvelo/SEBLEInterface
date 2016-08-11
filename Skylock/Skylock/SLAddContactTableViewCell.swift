//
//  SLAddContactTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 4/5/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLAddContactTableViewCell:UITableViewCell {
    var isSelectedContact:Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.font = UIFont(name: SLFont.OpenSansRegular.rawValue, size: 14.0)
        self.textLabel?.textColor = UIColor(red: 157, green: 161, blue: 167)
        
        let image = selected ? UIImage(named: "contacts_selected_circle") : UIImage(named: "contacts_unselected_circle")
        self.imageView?.image = image
    }
}
