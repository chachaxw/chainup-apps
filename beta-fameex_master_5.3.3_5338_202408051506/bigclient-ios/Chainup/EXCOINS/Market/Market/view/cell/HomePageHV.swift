//
//  HomePageHV.swift
//  AppProject
//
//  Created by zewu wang on 2023/8/6.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class HomePageHV: UIView {

    typealias ClickBtnBlock = (EXDoubleArrorwIconButton) -> ()
    var clickBtnBlock : ClickBtnBlock?
    
    var btnArr : [EXDoubleArrorwIconButton] = []
    
    //name
    lazy var nameBtn : EXDoubleArrorwIconButton = {
        let btn = EXDoubleArrorwIconButton()
        btn.extUseAutoLayout()
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorDark
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.text(content: LanguageTools.getString(key: "home_action_coinNameTitle"))
        return btn
    }()
    
    //Latest price
    lazy var newpriceBtn : EXDoubleArrorwIconButton = {
        let btn = EXDoubleArrorwIconButton()
        btn.extUseAutoLayout()
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorDark
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.text(content: LanguageTools.getString(key: "home_text_dealLatestPrice"))
        return btn
    }()
    
    //range
    lazy var amplitudeBtn : EXDoubleArrorwIconButton = {
        let btn = EXDoubleArrorwIconButton()
        btn.extUseAutoLayout()
        btn.setAlighment(margin: .marginRight)
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorDark
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.text(content: LanguageTools.getString(key: "common_text_priceLimit"))
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        btnArr = [nameBtn,newpriceBtn,amplitudeBtn]
        addSubViews([nameBtn,newpriceBtn,amplitudeBtn])
        
        nameBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(newpriceBtn.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        newpriceBtn.snp.makeConstraints { (make) in
           // make.left.equalToSuperview().offset(SCREEN_WIDTH / 2.5)
            make.right.equalTo(amplitudeBtn.snp.left).offset(-28)
            make.height.equalToSuperview()
            make.centerY.equalTo(nameBtn)
        }
        
        amplitudeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.height.equalToSuperview()
            make.centerY.equalTo(nameBtn)
        }
        self.backgroundColor = UIColor.ThemeView.bg
    }
    
    @objc func clickBtn(_ sender : EXDoubleArrorwIconButton){
        for btn in btnArr{
            if btn != sender{
                btn.reset()
            }
        }
        clickBtnBlock?(sender)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

