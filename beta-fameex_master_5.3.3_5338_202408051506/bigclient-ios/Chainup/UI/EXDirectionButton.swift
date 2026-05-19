//
//  EXDirectionButton.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum DirectionActionType:Int {
    case none = 0
    case ascending = 1 // a<b
    case descending = 2 // a>b
}

enum HorizontalMargin {
    case marginLeft
    case marginCenter
    case marginRight
}

class EXDirectionPassThroughView :UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

class EXDirectionButton: UIControl {
    
    var container :EXDirectionPassThroughView  = EXDirectionPassThroughView.init()
    var titleLabel :UILabel = UILabel.init()
    var triangleView :EXDirectionTriangle = EXDirectionTriangle.init()
    private var alighment :HorizontalMargin = .marginLeft
    var dirState :DirectionActionType = .none

    var lableRightmargin :Int = 8
    var triangleWidth :CGFloat = 8
    var isChecked:Bool = false
    //Two triangular style switches are used for sorting
    var doubleTriangleStyle:Bool = false {
        didSet {
            if doubleTriangleStyle  {
                lableRightmargin = 5
            }
            triangleView.doubleTriangleStyle = doubleTriangleStyle
            self.setNeedsDisplay()
        }
    }

    private var lastClickTime: TimeInterval = 0
    private let interval: TimeInterval = 1.0
    
    override func sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        let now = Date().timeIntervalSince1970
        if now - lastClickTime > interval {
            lastClickTime = now
            super.sendAction(action, to: target, for: event)
        }
    }
    

    func checked(check:Bool){
        isChecked = check
        triangleView.isChecked = check
    }
    
    func text(content:String) {
        titleLabel.text = content
        self.setNeedsDisplay()
    }
    
    func setAlighment(margin:HorizontalMargin) {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func reset(idx:Int = 0) {
        triangleView.isChecked = idx == 0 ? false : true
        triangleView.highlightIdx = idx
    }
    
    func config(){
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
            make.left.equalTo(titleLabel.snp.right).offset(lableRightmargin)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.width.equalTo(triangleWidth)
            make.height.equalTo(14)
            make.right.equalToSuperview()
        }
        
        self .setAlighment(margin: .marginLeft)
        
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    
    @objc func normalStyle() {
        self.checked(check: false)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        click(check:!isChecked)
        return true
    }
    
    func click(check:Bool){
        triangleView.isChecked = check
        triangleView.setDoubleTriangleTapped()
        dirState = DirectionActionType(rawValue: triangleView.highlightIdx)!
        print(dirState)
        isChecked = check
    }
}


//Gradually replace the icon drawn above
class EXDoubleArrorwIconButton: UIControl {
    
    var container :EXDirectionPassThroughView  = EXDirectionPassThroughView.init()
    var titleLabel :UILabel = UILabel.init()
    var imgIcon :UIImageView = UIImageView.init()
    private var alighment :HorizontalMargin = .marginLeft
    var dirState :DirectionActionType = .none

    var lableRightmargin :Int = 8
    var triangleWidth :CGFloat = 8
    var isChecked:Bool = false
    
    var highlightIdx:Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    func text(content:String) {
        titleLabel.text = content
        self.setNeedsDisplay()
    }
    
    func setAlighment(margin:HorizontalMargin) {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func reset(idx:Int = 0) {
        self.highlightIdx = idx
        self.imgIcon.image = UIImage.themeImageNamed(imageName: "quotes_default")
    }
    
    func config(){
        self.alighment = .marginLeft
        self.addSubview(container)
        self.backgroundColor = UIColor.ThemeView.bg
        container.backgroundColor = UIColor.ThemeView.bg
        container.addSubview(titleLabel)
        container.addSubview(imgIcon)
        
        self.imgIcon.image = UIImage.themeImageNamed(imageName: "quotes_default")
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

    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        click(check:!isChecked)
        return true
    }
    
    func click(check:Bool){
        self.itemTapped()
        dirState = DirectionActionType(rawValue: highlightIdx)!
        
        switch dirState {
        case .none:
            self.imgIcon.image = UIImage.themeImageNamed(imageName: "quotes_default")
        case .ascending:
            self.imgIcon.image = UIImage.themeImageNamed(imageName: "quotes_on")
        case .descending:
            self.imgIcon.image = UIImage.themeImageNamed(imageName: "quotes_under")
        }
    }
    
    func itemTapped() {
        highlightIdx += 1
        if highlightIdx > 2 {
            highlightIdx = 0
        }
        self.setNeedsDisplay()
    }
}

