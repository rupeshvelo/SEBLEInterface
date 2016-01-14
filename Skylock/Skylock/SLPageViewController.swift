//
//  SLPageViewController.swift
//  Skylock
//
//  Created by Andre Green on 1/3/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

import UIKit

class SLPageViewController: UIViewController {
    let numberOfDots:Int
    let activeColor = UIColor(red:97, green: 100, blue: 100)
    let nonActiveColor = UIColor(red: 191, green: 191, blue: 191)
    let horizontalSpacer:CGFloat = 20.0
    let dotDiameter:CGFloat = 8.0
    let viewWidth: CGFloat
    let xPadding: CGFloat
    var currentDotIndex = 0
    var dotViews:[UIView] = []
    
    init(numberOfDots: Int, width: CGFloat) {
        self.numberOfDots = numberOfDots - 1
        self.viewWidth = width
        self.xPadding = 0.5*(width - CGFloat(numberOfDots - 1)*self.horizontalSpacer)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpDots()
    }
    
    func setUpDots() {
        for i in 0...self.numberOfDots {
            let rect = CGRectMake(
                self.xPadding + CGFloat(i)*self.horizontalSpacer - 0.5*self.dotDiameter,
                0.5*(self.view.bounds.size.height - self.dotDiameter),
                self.dotDiameter,
                self.dotDiameter
            )
            
            let dotView = UIView(frame: rect)
            dotView.clipsToBounds = true
            dotView.layer.cornerRadius = 0.5*self.dotDiameter
            dotView.backgroundColor = i == 0 ? self.activeColor : self.nonActiveColor
            
            self.view.addSubview(dotView)
            self.dotViews.append(dotView)
        }
    }
    
    func makeDotActive(dotIndex: Int) {
        for (index, dotView) in self.dotViews.enumerate() {
            dotView.backgroundColor = index == dotIndex ? self.activeColor : self.nonActiveColor
        }
    }
    
    func viewRect() -> CGRect {
        return CGRectMake(0.0, 0.0, self.viewWidth, self.dotDiameter)
    }
    
    func increaseActiveDot() {
        if (self.currentDotIndex >= self.numberOfDots - 1 || self.currentDotIndex < 0) {
            return
        }
        
        let currentDotView = self.dotViews[self.currentDotIndex++]
        currentDotView.backgroundColor = self.nonActiveColor
        
        let nextDotView = self.dotViews[self.currentDotIndex]
        nextDotView.backgroundColor = self.activeColor
    }
    
    func decreaseActiveDot() {
        if (self.currentDotIndex > self.numberOfDots - 1 || self.currentDotIndex <=  0) {
            return
        }
        
        let currentDotView = self.dotViews[self.currentDotIndex--]
        currentDotView.backgroundColor = self.nonActiveColor
        
        let nextDotView = self.dotViews[self.currentDotIndex]
        nextDotView.backgroundColor = self.activeColor
    }
}
