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
        
        let image = selected ? UIImage(named: "contacts_selected_circle") : UIImage(named: "contacts_unselected_circle")
        self.imageView?.image = image
    }
}
