//
//  EXDirectionButton.swift
//  Chainup
//
//  Created by liuxuan on2020/3/11.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public enum DirectionActionType:Int {
    case none = 0
    case ascending = 1 // a<b
    case descending = 2 // a>b
}

public enum HorizontalMargin {
    case marginLeft
    case marginCenter
    case marginRight
}

public class EXDirectionPassThroughView :UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

public class EXDirectionButton: UIControl {
    
    public var container :EXDirectionPassThroughView  = EXDirectionPassThroughView.init()
    public var titleLabel :UILabel = UILabel.init()
    public var triangleView :EXDirectionTriangle = EXDirectionTriangle.init()
    private var alighment :HorizontalMargin = .marginLeft
    public var dirState :DirectionActionType = .none

    public var spaceBetweenImageAndTitle :Int = 8
    public var triangleWidth :CGFloat = 8
    public var isChecked:Bool = false
    //上下俩个三角的样式开关,排序的地方用到了
    public var doubleTriangleStyle:Bool = false {
        didSet {
            if doubleTriangleStyle  {
                spaceBetweenImageAndTitle = 5
            }
            triangleView.doubleTriangleStyle = doubleTriangleStyle
            self.setNeedsDisplay()
        }
    }

    public func checked(check:Bool){
        isChecked = check
        triangleView.isChecked = check
    }
    
    public func text(content:String) {
        titleLabel.text = content
        self.setNeedsDisplay()
    }
    
    public func setAlighment(margin:HorizontalMargin) {
        switch margin {
        case .marginLeft:
            container.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
        case .marginRight:
            container.snp.remakeConstraints { (make) in
                make.width.lessThanOrEqualToSuperview()
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            break
        case .marginCenter:
            container.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func reset(idx:Int = 0) {
        triangleView.isChecked = idx == 0 ? false : true
        triangleView.highlightIdx = idx
    }
    
    public func config(){
        self.alighment = .marginLeft
        self.addSubview(container)
        self.backgroundColor = UIColor.ThemeView.bg
        container.backgroundColor = UIColor.ThemeView.bg
        
        container.addSubview(titleLabel)
        container.addSubview(triangleView)
        
        titleLabel.secondaryRegular()
        titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        titleLabel.layoutIfNeeded()
        titleLabel.snp.makeConstraints { (make ) in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(16)
        }
        
        triangleView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(spaceBetweenImageAndTitle)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(triangleWidth)
            make.height.equalTo(14)
            make.right.equalToSuperview()
        }
        
        self .setAlighment(margin: .marginLeft)
        
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    
    @objc public func normalStyle() {
        self.checked(check: false)
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        click(check:!isChecked)
        return true
    }
    
    public func click(check:Bool){
        triangleView.isChecked = check
        triangleView.setDoubleTriangleTapped()
        dirState = DirectionActionType(rawValue: triangleView.highlightIdx)!
        print(dirState)
        isChecked = check
    }
}


//逐渐替代上面的画出来的icon
public class EXDoubleArrorwIconButton: UIControl {
    
    public var container :EXDirectionPassThroughView  = EXDirectionPassThroughView.init()
    public var titleLabel :UILabel = UILabel.init()
    public var imgIcon :UIImageView = UIImageView.init()
    private var alighment :HorizontalMargin = .marginLeft
    public var dirState :DirectionActionType = .none

    public var spaceBetweenImageAndTitle :Int = 8
    public var triangleWidth :CGFloat = 8
    public var isChecked:Bool = false
    
    public var highlightIdx:Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public func text(content:String) {
        titleLabel.text = content
        self.setNeedsDisplay()
    }
    
    public func setAlighment(margin:HorizontalMargin) {
        switch margin {
        case .marginLeft:
            container.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
        case .marginRight:
            container.snp.remakeConstraints { (make) in
                make.width.lessThanOrEqualToSuperview()
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            break
        case .marginCenter:
            container.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func reset(idx:Int = 0) {
        self.highlightIdx = idx
        self.imgIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_default")
    }
    
    public func config(){
        self.alighment = .marginLeft
        self.addSubview(container)
        self.backgroundColor = UIColor.ThemeView.bg
        container.backgroundColor = UIColor.ThemeView.bg
        container.addSubview(titleLabel)
        container.addSubview(imgIcon)
        
        self.imgIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_default")
        titleLabel.secondaryRegular()
        titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        titleLabel.layoutIfNeeded()
        titleLabel.snp.makeConstraints { (make ) in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(16)
        }
        
        imgIcon.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(4)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(10)
            make.height.equalTo(10)
            make.right.equalToSuperview()
        }
        
        self .setAlighment(margin: .marginLeft)
        
    }

    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        click(check:!isChecked)
        return true
    }
    
    public func click(check:Bool){
        self.itemTapped()
        dirState = DirectionActionType(rawValue: highlightIdx)!
        
        switch dirState {
        case .none:
            self.imgIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_default")
        case .ascending:
            self.imgIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_on")
        case .descending:
            self.imgIcon.image = UIImage.themeImageNamedFromPod(imageName: "public_under")
        }
    }
    
    public func itemTapped() {
        highlightIdx += 1
        if highlightIdx > 2 {
            highlightIdx = 0
        }
        self.setNeedsDisplay()
    }
}
