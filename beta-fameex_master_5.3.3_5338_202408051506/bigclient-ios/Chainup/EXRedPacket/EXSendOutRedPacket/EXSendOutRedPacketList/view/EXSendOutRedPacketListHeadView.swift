//
//  EXSendOutRedPacketListHeadView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSendOutRedPacketListHeadView: UIView {
    
    lazy var amountLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()

    lazy var vlineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var invitationRegisterLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var receiveNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var hlineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([amountLabel,numLabel,vlineV,invitationRegisterLabel,receiveNumLabel,hlineV])
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.right.equalTo(vlineV.snp.left).offset(-15)
            make.height.equalTo(20)
        }
        numLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(amountLabel)
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
        }
        vlineV.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(0.5)
        }
        invitationRegisterLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.left.equalTo(vlineV.snp.right).offset(15)
            make.height.equalTo(20)
        }
        receiveNumLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(invitationRegisterLabel)
            make.top.equalTo(invitationRegisterLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
        }
        hlineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setView(_ entity : EXSendOutRedPacketHeadEntity){
        amountLabel.attributedText = entity.fmsAllAmount()
        
        numLabel.text = entity.fmsAllCount()
        
        invitationRegisterLabel.attributedText = entity.fmsNewCount()
        
        receiveNumLabel.text = entity.fmsGetCount()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
