//
//  EXLoadable.swift
//  Chainup
//
//  Created by liuxuan on2020/3/7.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

private var key = 0

public protocol LoadingAnimation {
    var activityIndicator: LoadingView { get }
    func showLoading(radius:CGFloat)
    func hideLoading()
    func isAnimating()
    func animationStopped()
}

public class LoadingView :UIView {
    
    public var animateLayer = CAShapeLayer.init()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }

    func config() {
        animateLayer.lineWidth = 2
        animateLayer.strokeColor = UIColor.white.cgColor
        animateLayer.fillColor = UIColor.clear.cgColor
        //设置半径为10
        let radius:CGFloat = self.bounds.size.width/4
        let center:CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        //按照顺时针方向
        let clockWise = true;
        //初始化一个路径
        
        let circlePath = UIBezierPath.init(arcCenter:center, radius: radius, startAngle: (CGFloat(0*Double.pi)), endAngle: (CGFloat(1.75*Double.pi)), clockwise: clockWise)
        animateLayer.path = circlePath.cgPath
        self.layer .addSublayer(animateLayer)
    }
    
    public func startAnimating(){
       self.layer.add(self.animation(), forKey: "rotationAnimation")
    }
    
    public func stopAnimating() {
      self.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    func animation() -> CABasicAnimation{
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
         rotation.toValue = NSNumber(value: Double.pi * 2)
         rotation.duration = 1
         rotation.isCumulative = true
         rotation.repeatCount = Float.greatestFiniteMagnitude
         self.layer.add(rotation, forKey: "rotationAnimation")
        return rotation
    }
}

public extension LoadingAnimation where Self : UIView {
    
    func showLoading(radius:CGFloat = 26) {
        if self.activityIndicator.superview == nil {
            self.addSubview(self.activityIndicator)
            self.activityIndicator.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(radius)
            }
        }
        self.activityIndicator.startAnimating()
        self.isAnimating()
    }
    
    func hideLoading() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        self.animationStopped()
    }
}

// 协议
public protocol NibLoadable {
    // 具体实现写到extension内
}

// 加载nib
public extension NibLoadable where Self : UIView {
    static func loadFromNib(_ nibname : String? = nil) -> Self {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}
