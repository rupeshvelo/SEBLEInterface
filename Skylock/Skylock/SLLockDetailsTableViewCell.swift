//
//  SLLockDetailsTableViewCell.swift
//  Skylock
//
//  Created by Andre Green on 6/7/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLockDetailsTableViewCell: UITableViewCell {
    var lock:SLLock?
    let xPadding:CGFloat = 10.0
    
    lazy var nameLabel:UILabel = {
        let labelWidth = self.bounds.size.width - self.xPadding -
            (self.accessoryView == nil ? 0.0 : self.accessoryView!.bounds.size.width) - 5.0
        let utility = SLUtilities()
        let font = UIFont.systemFontOfSize(18)
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: self.lock == nil ? "" : self.lock!.displayName(),
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            self.xPadding,
            0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.text = self.lock?.displayName()
        label.textAlignment = .Left
        label.font = font
        label.numberOfLines = 1
        
        return label
    }()
    
    lazy var tempInfoView:UIImageView = {
        let image = UIImage(named: "lock_status_bar")!
        let frame = CGRect(
            x: self.nameLabel.frame.origin.x,
            y: CGRectGetMaxY(self.nameLabel.frame) + 5.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let view:UIImageView = UIImageView(image: image)
        view.frame = frame
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(tempInfoView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
