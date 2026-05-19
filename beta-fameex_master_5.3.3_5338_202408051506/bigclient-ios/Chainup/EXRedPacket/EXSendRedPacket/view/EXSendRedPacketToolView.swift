//
//  EXSendRedPacketToolView.swift
//  Chainup
//
//  Created by zewu wang on 2023/6/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSendRedPacketToolView: UIView {
    
    typealias ClickBtnBlock = (Int) -> ()
    var clickBtnBlock : ClickBtnBlock?
    
    lazy var spellLuckBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.setTitle("redpacket_send_random".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: UIControl.State.selected)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.isSelected = true
        btn.tag = 1000
        btn.extSetAddTarget(self, #selector(clickBtn))
        return btn
    }()
    
    lazy var normalBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.layoutIfNeeded()
        btn.setTitle("redpacket_send_identical".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: UIControl.State.selected)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        btn.isSelected = true
        btn.tag = 1001
        btn.extSetAddTarget(self, #selector(clickBtn))
        return btn
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeRedPacket.normalRed
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeNav.bg
        addSubViews([spellLuckBtn,normalBtn,lineV])
        spellLuckBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
        }
        normalBtn.snp.makeConstraints { (make) in
            make.left.equalTo(spellLuckBtn.snp.right).offset(40)
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-10)
        }
        lineV.snp.makeConstraints { (make) in
            make.centerX.equalTo(spellLuckBtn)
            make.height.equalTo(3)
            make.width.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }
    
    //Click on the button
    @objc func clickBtn(_ btn : UIButton){
        
        spellLuckBtn.titleLabel?.font = btn == spellLuckBtn ? UIFont.ThemeFont.HeadBold : UIFont.ThemeFont.HeadRegular
        normalBtn.titleLabel?.font = btn == normalBtn ? UIFont.ThemeFont.HeadBold : UIFont.ThemeFont.HeadRegular
        self.clickBtnBlock?(btn.tag - 1000)

        lineV.snp.remakeConstraints { (make) in
            make.centerX.equalTo(btn)
            make.height.equalTo(3)
            make.width.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

