//
//  EXDirectionButton.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

//逐渐替代上面的画出来的icon English: Gradually replace the icon drawn above
class EXCODoubleArrorwIconButton: UIControl {
    
    var container :EXSDirectionPassThroughView  = EXSDirectionPassThroughView.init()
    var titleLabel :UILabel = UILabel.init()
    var imgIcon :UIImageView = UIImageView.init()
    private var alighment :EXSHorizontalMargin = .marginLeft
    var dirState :EXSDirectionActionType = .none

    var spaceBetweenImageAndTitle :Int = 8
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
    
    func setAlighment(margin:EXSHorizontalMargin) {
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
        self.imgIcon.image = UIImage.exs_themeImageNamed(imageName: "quotes_default")
    }
    
    func config(){
        self.alighment = .marginLeft
        self.addSubview(container)
        self.backgroundColor = UIColor.ThemeView.bg
        container.backgroundColor = UIColor.ThemeView.bg
        container.addSubview(titleLabel)
        container.addSubview(imgIcon)
        
        self.imgIcon.image = UIImage.exs_themeImageNamed(imageName: "quotes_default")
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
        dirState = EXSDirectionActionType(rawValue: highlightIdx)!
        
        switch dirState {
        case .none:
            self.imgIcon.image = UIImage.exs_themeImageNamed(imageName: "quotes_default")
        case .ascending:
            self.imgIcon.image = UIImage.exs_themeImageNamed(imageName: "quotes_on")
        case .descending:
            self.imgIcon.image = UIImage.exs_themeImageNamed(imageName: "quotes_under")
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

