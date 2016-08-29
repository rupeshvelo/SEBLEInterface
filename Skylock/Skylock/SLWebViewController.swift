//
//  SLWebViewController.swift
//  Ellipse
//
//  Created by Andre Green on 8/28/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit
import WebKit

enum SLWebViewControllerBaseURL: String {
    case Help = "http://lattis.helpscoutdocs.com/"
    case Skylock = "http://skylock.cc"
}

class SLWebViewController: UIViewController, UIWebViewDelegate {
    let baseUrl:SLWebViewControllerBaseURL
    
    lazy var webView:WKWebView = {
        let view:WKWebView = WKWebView(frame: self.view.bounds)
        return view
    }()
    
    init(baseUrl: SLWebViewControllerBaseURL) {
        self.baseUrl = baseUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.webView)
        
        let menuImage = UIImage(named: "lock_screen_hamburger_menu")!
        let menuButton:UIBarButtonItem = UIBarButtonItem(
            image: menuImage,
            style: .Plain,
            target: self,
            action: #selector(menuButtonPressed)
        )
        
        self.navigationItem.leftBarButtonItem = menuButton
        
        if let url:NSURL = NSURL(string: self.baseUrl.rawValue) {
            let request:NSURLRequest = NSURLRequest(URL: url)
            self.webView.loadRequest(request)
        }
    }
    
    func menuButtonPressed() {
        if let navController = self.navigationController {
            if navController.viewControllers.first == self {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                navController.popViewControllerAnimated(true)
            }
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
