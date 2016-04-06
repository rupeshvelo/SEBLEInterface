//
//  SLAddContactButtonView.swift
//  Skylock
//
//  Created by Andre Green on 4/6/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import Cocoa

class SLAddContactButtonView: UIView {
    var imageData: Data?
    var name: String?
    
    lazy var picView:UIImageView = {
        let defaultImage = UIImage(name: ")
        let imageView:UIImageView
        if let imageData = self.imageData, let image:UIImage = UIImage(data: imageData){
            imageView
        }
    }()
}
