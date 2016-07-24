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

enum SLThinkerViewControllerLabelTextState {
    case ClockwiseTopStill
    case ClockwiseTopMoving
    case ClockwiseBottomStill
    case ClockwiseBottomMoving
    case CounterClockwiseTopStill
    case CounterClockwiseTopMoving
    case CounterClockwiseBottomStill
    case CounterClockwiseBottomMoving
    case InactiveTop
    case InactiveBottom
}

protocol SLThinkerViewControllerDelegate:class {
    func thinkerViewTapped(tvc: SLThinkerViewController)
}

class SLThinkerViewController: UIViewController {
    private var texts:[SLThinkerViewControllerLabelTextState:String]
    
    private let firstBackgroundColor:UIColor
    
    private let secondBackgroundColor:UIColor
    
    private let foregroundColor:UIColor

    private let inActiveBackgroundColor:UIColor
    
    private let textColor:UIColor
    
    private var currentBackgroundColor:UIColor?
    
    private var currentTintColor:UIColor?
    
    private let foregroundScaler:CGFloat = 0.8
    
    private let animationDuration:Double = 0.32
    
    private var shouldContinueAnimation:Bool = false
    
    private var thinkerState:SLThinkerViewControllerState = .Inactive

    weak var delegate:SLThinkerViewControllerDelegate?
    
    lazy var backgroundView:UIView = {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = self.currentBackgroundColor
        view.layer.cornerRadius = self.viewRadius()
        
        
        return view
    }()
    
    lazy var wormView:UIView = {
        let view:UIView = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.clearColor()
        
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
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tgr.numberOfTapsRequired = 1
        
        let view:UIView = UIView(frame: frame)
        view.backgroundColor = self.foregroundColor
        view.layer.cornerRadius = 0.5*diameter
        view.clipsToBounds = true
        view.userInteractionEnabled = true
        view.addGestureRecognizer(tgr)
        
        return view
    }()
    
    lazy var topLabel:UILabel = {
        let height:CGFloat = 23.0
        let frame = CGRect(
            x: 0.0,
            y: 0.5*self.foregroundView.bounds.size.height - height,
            width: self.foregroundView.bounds.size.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont.systemFontOfSize(21)
        label.textAlignment = .Center
        label.textColor = self.textColor
        return label
    }()
    
    lazy var bottomLabel:UILabel = {
        let height:CGFloat = 23.0
        let frame = CGRect(
            x: 0.0,
            y: 0.5*self.foregroundView.bounds.size.height,
            width: self.foregroundView.bounds.size.width,
            height: height
        )
        
        let label:UILabel = UILabel(frame: frame)
        label.font = UIFont.systemFontOfSize(21)
        label.textAlignment = .Center
        label.textColor = self.textColor
        
        return label
    }()
    
    init(
        texts: [SLThinkerViewControllerLabelTextState:String],
        firstBackgroundColor: UIColor,
        secondBackgroundColor: UIColor,
        foregroundColor: UIColor,
        inActiveBackgroundColor: UIColor,
        textColor: UIColor
        )
    {
        self.texts = texts
        self.firstBackgroundColor = firstBackgroundColor
        self.secondBackgroundColor = secondBackgroundColor
        self.foregroundColor = foregroundColor
        self.inActiveBackgroundColor = inActiveBackgroundColor
        self.textColor = textColor
        
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
            self.foregroundView.addSubview(self.topLabel)
            self.foregroundView.addSubview(self.bottomLabel)
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
        if let sublayers = self.wormView.layer.sublayers {
            for layer:CALayer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        
        let innerRadius = self.foregroundScaler*self.viewRadius()
        let halfArcHeight = 0.5*(self.viewRadius() - innerRadius)
        let startPoint = CGPointMake(self.wormView.center.x, self.wormView.center.y - innerRadius)
        let center1 = CGPointMake(self.wormView.center.x, halfArcHeight)
        let center2 = CGPointMake(self.wormView.center.x, self.wormView.bounds.size.height - halfArcHeight)
        
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
            self.wormView.center,
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
            self.wormView.center,
            radius: innerRadius,
            startAngle: 0,
            endAngle: -CGFloat(M_PI)/2.0,
            clockwise: false
        )
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.CGPath
        shapeLayer.fillColor = self.currentBackgroundColor?.CGColor
        
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
        
        self.wormView.layer.addSublayer(gradientLayer)
    }
    
    private func getTextForState(state: SLThinkerViewControllerLabelTextState) -> String? {
        if let text = self.texts[state] {
            return text
        }
        
        return nil
    }
    
    @objc private func viewTapped() {
        self.delegate?.thinkerViewTapped(self)
    }
    
    private func setLabelTextForTopState(
        topState: SLThinkerViewControllerLabelTextState,
        bottomState: SLThinkerViewControllerLabelTextState
        )
    {
        self.topLabel.text = self.getTextForState(topState)
        self.bottomLabel.text = self.getTextForState(bottomState)
    }
    
    // Mark: Public class functions
    func setState(state: SLThinkerViewControllerState) {
        switch state {
        case .ClockwiseStill:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.secondBackgroundColor
            self.currentTintColor = self.secondBackgroundColor
            self.setLabelTextForTopState(.ClockwiseTopStill, bottomState: .ClockwiseBottomStill)
        case .ClockwiseMoving:
            self.wormView.hidden = false
            self.shouldContinueAnimation = true
            self.currentBackgroundColor = self.firstBackgroundColor
            self.currentTintColor = self.secondBackgroundColor
            self.setLabelTextForTopState(.ClockwiseTopMoving, bottomState: .ClockwiseBottomMoving)
            self.rotateWormView(true)
        case .CounterClockwiseStill:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.firstBackgroundColor
            self.currentTintColor = self.firstBackgroundColor
            self.setLabelTextForTopState(.CounterClockwiseTopStill, bottomState: .CounterClockwiseBottomStill)
        case .CounterClockwiseMoving:
            self.wormView.hidden = false
            self.shouldContinueAnimation = true
            self.currentBackgroundColor = self.secondBackgroundColor
            self.currentTintColor = self.firstBackgroundColor
            self.setLabelTextForTopState(.CounterClockwiseTopMoving, bottomState: .CounterClockwiseBottomMoving)
            self.rotateWormView(false)
        case .Inactive:
            self.wormView.hidden = true
            self.shouldContinueAnimation = false
            self.currentBackgroundColor = self.inActiveBackgroundColor
            self.currentTintColor = self.inActiveBackgroundColor
            self.setLabelTextForTopState(.InactiveTop, bottomState: .InactiveBottom)
        }
        
        self.thinkerState = state
        self.backgroundView.backgroundColor = self.currentBackgroundColor
        self.updateWormLayer()
    }
    
    func updateTextForState(state: SLThinkerViewControllerState, topText: String?, bottomText: String?) {
        let topTextState:SLThinkerViewControllerLabelTextState
        let bottomTextState:SLThinkerViewControllerLabelTextState
        
        switch state {
        case .Inactive:
            topTextState = .InactiveTop
            bottomTextState = .InactiveBottom
        case .ClockwiseMoving:
            topTextState = .ClockwiseTopMoving
            bottomTextState = .ClockwiseBottomMoving
        case .ClockwiseStill:
            topTextState = .ClockwiseTopStill
            bottomTextState = .ClockwiseBottomStill
        case .CounterClockwiseMoving:
            topTextState = .CounterClockwiseTopMoving
            bottomTextState = .CounterClockwiseBottomMoving
        case .CounterClockwiseStill:
            topTextState = .CounterClockwiseTopStill
            bottomTextState = .CounterClockwiseBottomStill
        }
        
        if let top = topText {
            self.texts[topTextState] = top
        }
        
        if let bottom = bottomText {
            self.texts[bottomTextState] = bottom
        }
        
        if state == self.thinkerState {
            self.setLabelTextForTopState(topTextState, bottomState: bottomTextState)
        }
    }
}
