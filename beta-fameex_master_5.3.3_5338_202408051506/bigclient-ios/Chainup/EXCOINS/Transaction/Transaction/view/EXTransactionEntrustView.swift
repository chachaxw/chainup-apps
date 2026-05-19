//
//  EXTransactionEntrustView.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//Current delegate header

import UIKit
import EXKit
class EXTransactionEntrustView: UIView {
    
    typealias ClickAllEntrustBlock = () -> ()
    var clickAllEntrustBlock : ClickAllEntrustBlock?
    
    lazy var line : UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        return v
    }()

    lazy var nameLabel : UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.font = .Ex.medium(16)
        v.textColor = .Ex.text1
        v.text = LanguageTools.getString(key: "contract_text_currentEntrust")
        return v 
    }()
    
    lazy var indicator: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.main1
        return v
    }()
    
    lazy var allEntrustBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setImage(EXKitBundle.image(named: "public_icon_order"), for: UIControl.State.normal)
        btn.extSetAddTarget(self, #selector(clickBtn))
        btn.enlargeInteractionEdge(with: 10)
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let menuBg = UIView()
        addSubViews([menuBg, line])
        menuBg.addSubViews([nameLabel, indicator])
        menuBg.addSubview(allEntrustBtn)
    
        menuBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
        }
        
        line.snp.makeConstraints { (make) in
            make.top.equalTo(menuBg.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(200)
        }
        
        indicator.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.size.equalTo(CGSize(width: 24, height: 4))
            make.centerX.equalTo(nameLabel)
            make.bottom.equalToSuperview()
        }
        
        allEntrustBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        allEntrustBtn.textSizeFit()
    }
    
    @objc func clickBtn(){
        
        clickAllEntrustBlock?()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

