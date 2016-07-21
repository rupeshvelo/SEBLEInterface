//
//  SLThinkerViewController.swift
//  Skylock
//
//  Created by Andre Green on 7/20/16.
//  Copyright © 2016 Andre Green. All rights reserved.
//

enum SLThinkerViewControllerState {
    case ClockwiseMoving
    case ClockwiseStill
    case CounterClockwiseMoving
    case CounterClockwiseStill
    case Inactive
}

class SLThinkerViewController: UIViewController {
    private var topText:String
    
    private var bottomText:String
    
    private let firstBackgroundColor:UIColor
    
    private let secondBackgroundColor:UIColor
    
    private let foregroundColor:UIColor

    private let inActiveBackgroundColor:UIColor
    
    private var currentBackgroundColor:UIColor?
    
    private var currentTintColor:UIColor?
    
    private let foregroundScaler:CGFloat = 0.8
    
    private let animationDuration:Double = 0.32
    
    private var shouldContinueAnimation:Bool = false
    
    private var wormLayer:CAGradientLayer?
    
    lazy var backgroundView:UIView = {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = self.currentBackgroundColor
        view.layer.cornerRadius = self.viewRadius()
        
        return view
    }()
    
    lazy var wormView:UIView = {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.clearColor()
        
        let innerRadius = self.foregroundScaler*self.viewRadius()
        let halfArcHeight = 0.5*(self.viewRadius() - innerRadius)
        let startPoint = CGPointMake(view.center.x, view.center.y - innerRadius)
        let center1 = CGPointMake(view.center.x, halfArcHeight)
        let center2 = CGPointMake(view.center.x, view.bounds.size.height - halfArcHeight)
        
        let bezierPath:UIBezierPath = UIBezierPath()
        bezierPath.moveToPoint(startPoint)
        bezierPath.addArcWithCenter(
            center1,
            radius: halfArcHeight,
            startAngle: CGFloat(M_PI_2),
            endAngle: 3.0*CGFloat(M_PI_2),
            clockwise: true
        )
        bezierPath.addArcWithCenter(
            view.center,
            radius: self.viewRadius(),
            startAngle: -CGFloat(M_PI_2),
            endAngle: CGFloat(M_PI_2),
            clockwise: true
        )
        bezierPath.addArcWithCenter(
            center2,
            radius: halfArcHeight,
            startAngle: CGFloat(M_PI)/2.0,
            endAngle: 3.0*CGFloat(M_PI_2),
            clockwise: true
        )
        bezierPath.addArcWithCenter(
            view.center,
            radius: innerRadius,
            startAngle: 0,
            endAngle: -CGFloat(M_PI)/2.0,
            clockwise: false
        )
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        shapeLayer.fillColor = self.currentBackgroundColor?.CGColor
        
//        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        
        var colors:[CGColor]?
        if let backgroundColor = self.currentBackgroundColor, let tintColor = self.currentTintColor {
            colors = [
                backgroundColor.CGColor,
                tintColor.CGColor
            ]
        }
        let locations = [0.0, 1.0]
        
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        gradientLayer.mask = shapeLayer

        
        view.layer.addSublayer(gradientLayer)
        
        return view
    }()
    
    lazy var foregroundView:UIView = {
        let diameter = 2.0*self.foregroundScaler*self.viewRadius()
        let frame = CGRect(
            x: 0.5*(self.view.bounds.size.width - diameter),
            y: 0.5*(self.view.bounds.size.height - diameter),
            width: diameter,
            height: diameter
        )
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = self.foregroundColor
        view.layer.cornerRadius = 0.5*diameter
        
        return view
    }()
    
    init(
        topText:String,
        bottomText:String,
        firstBackgroundColor: UIColor,
        secondBackgroundColor: UIColor,
        foregroundColor: UIColor,
        inActiveBackgroundColor: UIColor
        )
    {
        self.topText = topText
        self.bottomText = bottomText
        self.firstBackgroundColor = firstBackgroundColor
        self.secondBackgroundColor = secondBackgroundColor
        self.foregroundColor = foregroundColor
        self.inActiveBackgroundColor = inActiveBackgroundColor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.view.subviews.contains(self.backgroundView) {
            self.view.addSubview(self.backgroundView)
        }
        
        if !self.view.subviews.contains(self.wormView) {
            self.view.addSubview(self.wormView)
        }
        
        if !self.view.subviews.contains(self.foregroundView) {
            self.view.addSubview(self.foregroundView)
        }
    }
    
    private func viewRadius() -> CGFloat {
        return self.view.bounds.size.width < self.view.bounds.size.height ?
            0.5*self.view.bounds.size.width : 0.5*self.view.bounds.size.height
    }
    
    private func rotateWormView(shouldRotateClockwise: Bool) {
        UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: .CurveLinear, animations: {
            self.wormView.transform = CGAffineTransformRotate(self.wormView.transform, CGFloat(M_PI))
        }) { (finished) in
            if self.shouldContinueAnimation {
                self.rotateWormView(shouldRotateClockwise)
            }
        }
    }
    
    private func updateWormLayer() {
        
    }
    // Mark: Public class functions
    func setState(state: SLThinkerViewControllerState) {
        switch state {
        case .ClockwiseStill:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.firstBackgroundColor
            self.currentTintColor = self.secondBackgroundColor
        case .ClockwiseMoving:
            self.wormView.hidden = false
            self.shouldContinueAnimation = true
            self.currentBackgroundColor = self.firstBackgroundColor
            self.currentTintColor = self.secondBackgroundColor
            self.rotateWormView(true)
        case .CounterClockwiseStill:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.secondBackgroundColor
            self.currentTintColor = self.firstBackgroundColor
        case .CounterClockwiseMoving:
            self.wormView.hidden = false
            self.shouldContinueAnimation = true
            self.currentBackgroundColor = self.secondBackgroundColor
            self.currentTintColor = self.firstBackgroundColor
            self.rotateWormView(false)
        case .Inactive:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.inActiveBackgroundColor
            self.currentTintColor = self.inActiveBackgroundColor
        }
    }
}
