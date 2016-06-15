//
//  SLTheftDetectionSliderView.swift
//  Skylock
//
//  Created by Andre Green on 6/10/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

protocol SLTheftDetctionSliderViewDelegate {
    func sliderViewValueChanged(sliderView: SLTheftDetectionSliderView, value:Float)
}
class SLTheftDetectionSliderView: UIView {
    let xPadding:CGFloat = 32.0
    var delegate:SLTheftDetctionSliderViewDelegate?
    
    lazy var lowLabel:UILabel = {
        let labelWidth = self.bounds.size.width - 2*self.xPadding
        let font = UIFont.systemFontOfSize(8.0)
        let text = NSLocalizedString("Low", comment: "")
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            self.xPadding,
            CGRectGetMinY(self.slider.frame) - 18.0,
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame:frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.textAlignment = .Left
        
        return label
    }()
    
    lazy var mediumLabel:UILabel = {
        let labelWidth = self.bounds.size.width - 2*self.xPadding
        let font = UIFont.systemFontOfSize(8.0)
        let text = NSLocalizedString("Medium", comment: "")
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            0.5*(self.bounds.size.width - labelSize.width),
            CGRectGetMinY(self.lowLabel.frame),
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame:frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.textAlignment = .Center
        
        return label
    }()
    
    lazy var highLabel:UILabel = {
        let labelWidth = self.bounds.size.width - 2*self.xPadding
        let font = UIFont.systemFontOfSize(8.0)
        let text = NSLocalizedString("High", comment: "")
        let utility = SLUtilities()
        let labelSize:CGSize = utility.sizeForLabel(
            font,
            text: text,
            maxWidth: labelWidth,
            maxHeight: CGFloat.max,
            numberOfLines: 1
        )
        
        let frame = CGRectMake(
            self.bounds.size.width - labelSize.width - self.xPadding,
            CGRectGetMinY(self.lowLabel.frame),
            labelSize.width,
            labelSize.height
        )
        
        let label:UILabel = UILabel(frame:frame)
        label.text = text
        label.font = font
        label.textColor = UIColor(white: 155.0/255.0, alpha: 1.0)
        label.textAlignment = .Right
        
        return label
    }()
    
    lazy var slider:UISlider = {
        let height:CGFloat = 20
        let frame = CGRect(
            x: self.xPadding,
            y: 0.5*(self.bounds.height - height),
            width: self.bounds.size.width - 2*self.xPadding,
            height: height
        )
        
        let slider:UISlider = UISlider(frame: frame)
        slider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        slider.tintColor = UIColor(red: 102, green: 177, blue: 227)
        slider.thumbTintColor = UIColor(red: 102, green: 177, blue: 227)
        slider.continuous = true
        
        return slider
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = UIColor.whiteColor()
        
        self.addSubview(self.slider)
        self.addSubview(self.lowLabel)
        self.addSubview(self.mediumLabel)
        self.addSubview(self.highLabel)
    }
    
    func sliderValueChanged() {
        print("slider value: \(self.slider.value)")
        self.delegate?.sliderViewValueChanged(self, value: self.slider.value)
    }
}
