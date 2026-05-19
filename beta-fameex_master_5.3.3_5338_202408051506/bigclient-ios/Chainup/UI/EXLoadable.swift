//
//  EXLoadable.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

private var key = 0

protocol LoadingAnimation {
    var activityIndicator: LoadingView { get }
    func showLoading(radius:CGFloat)
    func hideLoading()
    func isAnimating()
    func animationStopped()
}

class LoadingView :UIView {
    
    var animateLayer = CAShapeLayer.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }

    func config() {
        animateLayer.lineWidth = 2
        animateLayer.strokeColor = UIColor.white.cgColor
        animateLayer.fillColor = UIColor.clear.cgColor
        //Set the radius to 10
        let radius:CGFloat = self.bounds.size.width/4
        let center:CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        //In a clockwise direction
        let clockWise = true;
        //Initialize a path
        
        let circlePath = UIBezierPath.init(arcCenter:center, radius: radius, startAngle: (CGFloat(0*Double.pi)), endAngle: (CGFloat(1.75*Double.pi)), clockwise: clockWise)
        animateLayer.path = circlePath.cgPath
        self.layer .addSublayer(animateLayer)
    }
    
    func startAnimating(){
       self.layer.add(self.animation(), forKey: "rotate")
    }
    
    func stopAnimating() {
      self.layer.removeAnimation(forKey: "rotate")
    }
    
    func animation() -> CABasicAnimation{
        let animation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animation.fillMode = CAMediaTimingFillMode.forwards;
        animation.toValue = Double.pi * 2.0
        animation.duration = 1
        animation.repeatCount = Float.greatestFiniteMagnitude
        return animation
    }
}

extension LoadingAnimation where Self : UIView {
    
    func showLoading(radius:CGFloat = 26) {
        self.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(radius)
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

//protocol
protocol NibLoadable {
    //Write the specific implementation into the extension
}

//Load nib
extension NibLoadable where Self : UIView {
    static func loadFromNib(_ nibname : String? = nil) -> Self {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}

