//
//  EXSwitch.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSSwitch: UIControl {
    
    var bgOffColor:UIColor = UIColor.ThemeView.bgIconh50
    var bgOnColor:UIColor = UIColor.ThemeView.highlight25
    var switchOnColor:UIColor = UIColor.ThemeLabel.colorHighlight
    var switchOffColor:UIColor = UIColor.ThemeView.bgIconh
    var isOn:Bool = false
    var bgLayer:CAShapeLayer = CAShapeLayer()
    var trackLayer:CAShapeLayer = CAShapeLayer()
    var thumbLayer:CAShapeLayer = CAShapeLayer()
    
    typealias ValueChangeBlock = (Bool) -> ()
    var onValueChangeCallback : ValueChangeBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config(){
        self.snp.makeConstraints { (make) in
            make.width.equalTo(36)
            make.height.equalTo(18)
        }
        self.frame = CGRect(x: 0, y: 0, width: 36, height: 18)
        bgLayer.backgroundColor = UIColor.clear.cgColor
        bgLayer.frame = self.bounds;
        bgLayer.cornerRadius = self.bounds.size.height/2.0;
        let bgPath = UIBezierPath.init(roundedRect: bgLayer.bounds, cornerRadius: 0).cgPath
        bgLayer.path = bgPath
        bgLayer.setValue(false, forKey: "isOn")
        bgLayer.fillColor = UIColor.ThemeView.bg.cgColor
        self.layer .addSublayer(bgLayer)
        
        let height = self.bounds.size.height
        let trackCenterY = (height - 12)/2
        
        trackLayer.frame = CGRect(x: 0, y: trackCenterY, width: self.bounds.size.width, height: 12).insetBy(dx: 0, dy: 0)
        let fillPath = UIBezierPath.init(roundedRect: trackLayer.bounds, cornerRadius:20).cgPath
        trackLayer.path = fillPath
        trackLayer.setValue(true, forKey: "isVisible")
        trackLayer.fillColor = bgOffColor.cgColor;
        self.layer .addSublayer(trackLayer)

        thumbLayer.backgroundColor = UIColor.clear.cgColor
        thumbLayer.frame = CGRect(x: 0, y: 0, width: height, height: height)
        let knobPath = UIBezierPath.init(roundedRect: thumbLayer.bounds, cornerRadius:9).cgPath
        thumbLayer.path = knobPath
        thumbLayer.fillColor = switchOffColor.cgColor;
        self.layer .addSublayer(thumbLayer)
  
        self.setNeedsDisplay()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let on = !isOn
        self.on(isOn: on, animated: true)
        onValueChangeCallback?(on)
        return true
    }
    
    func setOn(isOn:Bool) {
        self.on(isOn: isOn,animated:false)
    }
    
    private func on(isOn:Bool,animated:Bool = true) {
        if (self.isOn != isOn) {
            self.isOn = isOn
        }
        CATransaction.begin()
        thumbLayer.frame = self.thumbFrameForState(on: isOn)
        CATransaction.commit()
        colorForState(on: isOn)
    }
    
    func colorForState(on:Bool,animated:Bool = true) {
        if animated {
            CATransaction.begin()
            let changeColor = CABasicAnimation.init(keyPath: "fillColor")
            changeColor.duration = 0.2
            changeColor.fromValue = on ? switchOffColor.cgColor : switchOnColor.cgColor
            changeColor.toValue = on ? switchOnColor.cgColor :  switchOffColor.cgColor
            changeColor.isRemovedOnCompletion = false
            changeColor.fillMode = CAMediaTimingFillMode.forwards
            thumbLayer.add(changeColor, forKey: "animateColor")
            CATransaction.commit()
            
            CATransaction.begin()
            let trackcolor = CABasicAnimation.init(keyPath: "fillColor")
            trackcolor.duration = 0.2
            trackcolor.fromValue = on ? bgOffColor.cgColor : bgOnColor.withAlphaComponent(0.25).cgColor
            trackcolor.toValue = on ? bgOnColor.withAlphaComponent(0.25).cgColor :  bgOffColor.cgColor
            trackcolor.isRemovedOnCompletion = false
            trackcolor.fillMode = CAMediaTimingFillMode.forwards
            trackLayer.add(trackcolor, forKey: "animateColor")
            CATransaction.commit()
            
        }else {
            thumbLayer.removeAllAnimations()
            trackLayer.removeAllAnimations()
        }
    }
    
    func thumbFrameForState(on:Bool)->CGRect {
        return CGRect(x:on ? self.bounds.size.width - self.bounds.size.height : 0, y: 0, width: self.bounds.size.height, height: self.bounds.size.height)
    }
    
}
