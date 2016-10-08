//
//  SLLoadingView.swift
//  Ellipse
//
//  Created by Andre Green on 8/30/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLoadingView: UIView {
    private let xPadding:CGFloat = 10.0
    
    private lazy var loadingLabel:UILabel = {
        let frame = CGRect(x: self.xPadding, y: 0.0, width: self.bounds.size.width - 2.0*self.xPadding, height: 34.0)
        let label:UILabel = UILabel(frame: frame)
        label.textColor = UIColor.white
        label.font = UIFont(name: SLFont.YosemiteRegular.rawValue, size: 15.0)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var loadingIconView:UIImageView = {
        let image:UIImage = UIImage(named: "loading_icon")!
        let frame = CGRect(
            x: 0.5*(self.bounds.size.width - image.size.width),
            y: self.loadingLabel.frame.maxY + 20.0,
            width: image.size.width,
            height: image.size.height
        )
        
        let imageView:UIImageView = UIImageView(image: image)
        imageView.frame = frame
        
        return imageView
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = UIColor.clear
        
        if !self.subviews.contains(self.loadingLabel) {
            self.addSubview(self.loadingLabel)
        }
        
        if !self.subviews.contains(self.loadingIconView) {
            self.addSubview(self.loadingIconView)
        }
    }
    
    func setMessage(message: String) {
        self.loadingLabel.text = message
    }
    
    func rotate() {
        self.loadingIconView.center = self.loadingIconView.center
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
            self.loadingIconView.transform = self.loadingIconView.transform.rotated(by: CGFloat(M_PI))
        }) { (finished) in
            self.rotate()
        }
    }
}
