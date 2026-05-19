//
//  EXSwitch.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/10.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import SnapKit

public class EXSwitch: UIControl {
    
    public var bgOffColor:UIColor = UIColor.ThemeView.bgIconh50
    public var bgOnColor:UIColor = UIColor.ThemeView.highlight25
    public var switchOnColor:UIColor = UIColor.ThemeLabel.colorHighlight
    public var switchOffColor:UIColor = UIColor.ThemeView.bgIconh
    public var isOn:Bool = false
    public var bgLayer:CAShapeLayer = CAShapeLayer()
    public var trackLayer:CAShapeLayer = CAShapeLayer()
    public var thumbLayer:CAShapeLayer = CAShapeLayer()
    
    public typealias ValueChangeBlock = (Bool) -> ()
    public var onValueChangeCallback : ValueChangeBlock?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func config(){
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
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let on = !isOn
        self.on(isOn: on, animated: true)
        onValueChangeCallback?(on)
        return true
    }
    
    
    public func setOn(isOn:Bool) {
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
    
    public func colorForState(on:Bool,animated:Bool = true) {
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
    
    public func thumbFrameForState(on:Bool)->CGRect {
        return CGRect(x:on ? self.bounds.size.width - self.bounds.size.height : 0, y: 0, width: self.bounds.size.height, height: self.bounds.size.height)
    }
    
}



public class EXPaymentSwitch: UIControl {
    
    public var bgOffColor:UIColor = UIColor.ThemeView.bgIconh50
    public var bgOnColor:UIColor = UIColor.ThemeView.highlight
    public var switchOnColor:UIColor = UIColor.white
    public var switchOffColor:UIColor = UIColor.ThemeView.bgIconh
    public var isOn:Bool = false
    public var bgLayer:CAShapeLayer = CAShapeLayer()
    public var trackLayer:CAShapeLayer = CAShapeLayer()
    public var thumbLayer:CAShapeLayer = CAShapeLayer()
    
    public let bgwidth:CGFloat = 33.0
    public let bgheight:CGFloat = 19.0
    public let thumbR:CGFloat = 15.0
    
    public typealias ValueChangeBlock = (Bool) -> ()
    public var onValueChangeCallback : ValueChangeBlock?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func config(){

        backgroundColor = .clear
        bgLayer.masksToBounds = true
        self.snp.makeConstraints { (make) in
            make.width.equalTo(bgwidth)
            make.height.equalTo(bgheight)
        }
        self.frame = CGRect(x: 0, y: 0, width: bgwidth, height: bgheight)
        bgLayer.backgroundColor = UIColor.clear.cgColor
        bgLayer.frame = self.bounds;
        bgLayer.cornerRadius = self.bounds.size.height/2.0;
        let bgPath = UIBezierPath.init(roundedRect: bgLayer.bounds, cornerRadius: 0).cgPath
        bgLayer.path = bgPath
        bgLayer.setValue(false, forKey: "isOn")
        bgLayer.fillColor = UIColor.ThemeView.bg.cgColor
        self.layer .addSublayer(bgLayer)
                
        
        trackLayer.frame = CGRect(x: 0, y: 0, width:bgwidth, height: bgheight).insetBy(dx: 0, dy: 0)
        let fillPath = UIBezierPath.init(roundedRect: trackLayer.bounds, cornerRadius:bgheight/2).cgPath
        trackLayer.path = fillPath
        trackLayer.setValue(true, forKey: "isVisible")
        trackLayer.fillColor = bgOffColor.cgColor;
        self.layer .addSublayer(trackLayer)

        thumbLayer.backgroundColor = UIColor.clear.cgColor
        thumbLayer.frame = CGRect(x: 0, y: 0, width: thumbR, height: thumbR)
        let knobPath = UIBezierPath.init(roundedRect: thumbLayer.bounds, cornerRadius:thumbR/2).cgPath
        thumbLayer.path = knobPath
        thumbLayer.fillColor = switchOffColor.cgColor;
        self.layer .addSublayer(thumbLayer)
  
        self.setNeedsDisplay()
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let on = !isOn
        self.on(isOn: on, animated: true)
        onValueChangeCallback?(on)
        return true
    }
    
    
    public func setOn(isOn:Bool) {
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
    
    public func colorForState(on:Bool,animated:Bool = true) {
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
            trackcolor.fromValue = on ? bgOffColor.cgColor : bgOnColor.cgColor
            trackcolor.toValue = on ? bgOnColor.cgColor :  bgOffColor.cgColor
            trackcolor.isRemovedOnCompletion = false
            trackcolor.fillMode = CAMediaTimingFillMode.forwards
            trackLayer.add(trackcolor, forKey: "animateColor")
            CATransaction.commit()
            
        }else {
            thumbLayer.removeAllAnimations()
            trackLayer.removeAllAnimations()
        }
    }
    
    public func thumbFrameForState(on:Bool)->CGRect {
        return CGRect(x:on ? (bgwidth - thumbR - 2) : 2, y: 2, width: thumbR, height: thumbR)
    }
    
}


public class EXSwitchV6: UIControl {
    
    public enum Style {
        case small
        case large
        case custom
        public static let `default`:Self = .small
    }
    
    public let style:Style
    
    public var isOn:Bool = false {
        didSet {
            update(animated: true)
        }
    }
    
    public var onValueChangeCallback : ((Bool)->())?
    
    public override var intrinsicContentSize: CGSize {
        switch style {
            case .small:
                return CGSize(width: 26, height: 14)
            case .large:
                return CGSize(width: 34, height: 18)
            default:
                return super.intrinsicContentSize
        }
    }
    //
    private let offBackgroundColor:UIColor = .Ex.text3
    private let onBackgroundColor:UIColor = .Ex.main1
    //
    private let offThumbColor:UIColor = .Ex.fill3
    private let onThumbColor:UIColor = .white
    //
    private var onThumbConstraint:Constraint!
    private var offThumbConstraint:Constraint!
    
    //
    private let contentView = UIView()
    private let thumbView = UIView()
    
    public required init(frame: CGRect = .zero, style:Style = .default) {
        self.style = style
        super.init(frame: frame)
        backgroundColor = .clear
        //
        contentView.isUserInteractionEnabled = false
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //
        contentView.addSubview(thumbView)
        thumbView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().offset(-4)
            make.width.equalTo(thumbView.snp.height)
            offThumbConstraint = make.left.equalTo(2).constraint
            onThumbConstraint = make.right.equalTo(-2).constraint
        }
        //
        updateState()
        //
        if style != .custom {
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .vertical)
            setContentHuggingPriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .vertical)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.corneradius = contentView.height / 2
        thumbView.corneradius = (contentView.height - 4) / 2
    }
    
    private func updateState() {
        if isOn {
            contentView.backgroundColor = onBackgroundColor
            thumbView.backgroundColor = onThumbColor
            offThumbConstraint.deactivate()
            onThumbConstraint.activate()
        }else{
            contentView.backgroundColor = offBackgroundColor
            thumbView.backgroundColor = offThumbColor
            onThumbConstraint.deactivate()
            offThumbConstraint.activate()
        }
    }
    
    private func update(animated:Bool) {
        if animated && superview != nil {
            UIView.animate(withDuration: 0.2) {
                self.updateState()
                self.layoutIfNeeded()
            }
        }else{
            updateState()
        }
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        isOn = !isOn
        onValueChangeCallback?(isOn)
        sendActions(for: .valueChanged)
        return true
    }
    
}
