//
//  EXReceivedRedPacketListHeadView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXReceivedRedPacketListHeadView: UIView {

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
    
    lazy var hlineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([amountLabel,numLabel,hlineV])
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(20)
        }
        numLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(amountLabel)
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.height.equalTo(14)
        }
        hlineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setView(_ entity : EXReceivedRedPacketEntity){
        amountLabel.attributedText = entity.fmsAllAmount()
        
        numLabel.text = entity.fmsAllCount()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
