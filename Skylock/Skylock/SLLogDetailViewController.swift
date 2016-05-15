//
//  SLLogDetailViewController.swift
//  Skylock
//
//  Created by Andre Green on 5/15/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLLogDetailViewController: UIViewController {
    var text:String
    let padding:CGFloat = 10.0
    
    lazy var scrollView:UIScrollView = {
        let font = UIFont.systemFontOfSize(15)
        let utility: SLUtilities = SLUtilities()
        let size: CGSize = utility.sizeForLabel(
            font,
            text:self.text,
            maxWidth:self.view.bounds.size.width - 2*self.padding,
            maxHeight: CGFloat.max,
            numberOfLines: 0
        )
        
        let labelFrame:CGRect = CGRect(
            x: self.padding,
            y: self.padding,
            width: size.width,
            height: size.height
        )
        
        let label = UILabel(frame: labelFrame)
        label.font = font
        label.text = self.text
        label.numberOfLines = 0
        
        let scroll:UIScrollView = UIScrollView(frame: self.view.bounds)
        scroll.contentSize = label.bounds.size
        scroll.backgroundColor = UIColor.whiteColor()
        scroll.addSubview(label)
        
        return scroll
    }()
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, log:SLLog) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.text = dateFormatter.stringFromDate(log.date!) + "\n\n" + log.entry!
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.scrollView)
    }
}
