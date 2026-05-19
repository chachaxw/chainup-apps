//
//  EXHomeGuideBase.swift
//  Chainup
//
//  Created by liuxuan on 2023/1/20.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXHomeGuideBase: UIView {
    
    let arrowheight:CGFloat = 9
    let arrowWidth:CGFloat = 10
    
    var yOffset:CGFloat = 0
    var xOffset:CGFloat = 0 
    var configWidth:CGFloat = 220

    lazy var contentView:UIView = {
        let content = UIView()
        content.layer.cornerRadius = 4
        content.backgroundColor = UIColor.ThemeView.bg
        return content
    }()
    
    lazy var arrow:UIImageView = {
        let arrowIcon = UIImageView()
        arrowIcon.image = UIImage.themeImageNamed(imageName:"jiantou")
        return arrowIcon
    }()
    
    lazy var guideIcon:UIImageView = {
        let content = UIImageView()
        return content
    }()
    
    lazy var guideLabel:UILabel = {
        let guideLabel = UILabel()
        guideLabel.textColor = UIColor.ThemeLabel.colorLite
        guideLabel.font = UIFont.ThemeFont.HeadMedium
        guideLabel.numberOfLines = 0
        return guideLabel
    }()
    
    lazy var seperator:UIView = {
        let content = UIView()
        content.backgroundColor = UIColor.ThemeView.seperator
        return content
    }()
    
    lazy var skipBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("common_guide_skip_hint".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        return btn
    }()
    
    lazy var nextBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setTitle("common_action_next".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        return btn
    }()
    
    var guideIconName:String
    var guideTitleStr:String
    var hasNext:Bool
    var isArrowLeft:Bool
    var justShowTitle:Bool
    required init(guideIcon:String,guideTitle:String,hasSkipNext:Bool = true,arrowLeft:Bool = true,justShowTitle:Bool = false){
        self.guideIconName = guideIcon
        self.guideTitleStr = guideTitle
        self.hasNext = hasSkipNext
        self.isArrowLeft = arrowLeft
        self.justShowTitle = justShowTitle
        super.init(frame: CGRect.zero)
        
        if justShowTitle {
            configTitleSubViews()
        }else {
            configSubViews()
        }
    }
    
    func addArrow() {
        self.addSubview(arrow)
        if self.isArrowLeft {
            arrow.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(10)
                make.top.equalToSuperview()
            }
        }else {
            arrow.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-10)
                make.top.equalToSuperview()
            }
        }
        
    }
    
    func configTitleSubViews() {
        self.addArrow()
        self.addSubview(contentView)

        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(arrow.snp.bottom).offset(-2)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        if guideTitleStr.count > 0 {
            var fullWidth = guideTitleStr.textSizeWithFont(UIFont.ThemeFont.HeadMedium, width: CGFloat.greatestFiniteMagnitude).width + MARGIN_LEFT_DOUBLE
            fullWidth = fullWidth > 220 ? 220 : fullWidth
            self.configWidth = fullWidth
            guideLabel.text = guideTitleStr
            contentView.addSubview(guideLabel)
            guideLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(MARGIN_LEFT)
                make.left.equalToSuperview().offset(MARGIN_LEFT)
                make.right.equalToSuperview().offset(-MARGIN_LEFT)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
    
    func configSubViews() {
        self.addArrow()
        self.addSubview(contentView)
        
        if hasNext {
            contentView.addSubview(seperator)
            contentView.addSubview(skipBtn)
            contentView.addSubview(nextBtn)
            
            contentView.snp.makeConstraints { (make) in
                make.top.equalTo(arrow.snp.bottom).offset(-2)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }else {
            contentView.snp.makeConstraints { (make) in
                make.top.equalTo(arrow.snp.bottom).offset(-2)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }
        
        var preView:UIView?
        if guideIconName.count > 0 {
            guideIcon.image = UIImage.themeImageNamed(imageName: guideIconName)
            contentView.addSubview(guideIcon)
            guideIcon.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(MARGIN_LEFT + arrowheight)
                make.left.equalToSuperview().offset(MARGIN_LEFT)
                make.right.equalToSuperview().offset(-MARGIN_LEFT)
            }
            preView = guideIcon
        }
        if guideTitleStr.count > 0 {
            guideLabel.text = guideTitleStr
            contentView.addSubview(guideLabel)
            
            guideLabel.snp.makeConstraints { (make) in
                if let pre = preView {
                    make.top.equalTo(pre.snp.bottom).offset(20)
                }else {
                    make.top.equalToSuperview().offset(MARGIN_LEFT + arrowheight)
                }
                make.left.equalToSuperview().offset(MARGIN_LEFT)
                make.right.equalToSuperview().offset(-MARGIN_LEFT)
                if hasNext {
                    make.bottom.equalTo(seperator.snp.top).offset(-20)
                }else {
                    make.bottom.equalToSuperview().offset(-20)
                }
            }
            preView = guideLabel
        }
        
        if hasNext {

            seperator.snp.makeConstraints { (make) in
                make.top.equalTo(guideLabel.snp.bottom).offset(20)
                make.height.equalTo(0.5)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            
            skipBtn.snp.makeConstraints { (make) in
                make.top.equalTo(seperator.snp.bottom)
                make.left.equalToSuperview().offset(MARGIN_LEFT)
                make.height.equalTo(40)
                make.bottom.equalToSuperview()
            }
            
            nextBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(skipBtn)
                make.right.equalToSuperview().offset(-MARGIN_LEFT)
                make.height.equalTo(40)
                make.bottom.equalToSuperview()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
