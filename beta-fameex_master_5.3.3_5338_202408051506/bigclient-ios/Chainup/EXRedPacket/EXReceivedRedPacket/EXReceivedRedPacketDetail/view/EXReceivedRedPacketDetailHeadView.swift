//
//  EXReceivedRedPacketDetailHeadView.swift
//  Chainup
//
//  Created by zewu wang on 2023/7/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXReceivedRedPacketDetailHeadView: EXSendOutRedPacketDetailHeadView {

    //How many coins are there in total
    lazy var amountLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        return label
    }()
    
    //Prompt for deposit into account
    lazy var promptLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .center
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickPromptLabel))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tipLabel.isHidden = true
//        shareBtn.isHidden = true
        addSubViews([amountLabel,promptLabel])
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(29)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
        promptLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalTo(amountLabel.snp.bottom).offset(10)
        }
    }
    
    override func setView(_ entity : EXRedPacketDetailEntity){
        nameLabel.text = String.init(format: "redpacket_send_from".localized(), entity.nickName)
        
        switch entity.status {
        case "1","3":
            redPacketDetailLabel.text = String.init(format: "redpacket_received_opened".localized(), entity.getCount,entity.count)
        case "2":
            redPacketDetailLabel.text = String.init(format: "redpacket_sendout_goneDetail".localized(), entity.count,entity.amount,entity.coinSymbol.aliasName())
        default:
            break
        }
        
        amountLabel.attributedText = entity.getMyAmount()
        
        promptLabel.text = "redpacket_received_withdraw".localized()
    }
    
    //Click on the saved status
    @objc func clickPromptLabel(){
        let asset = EXAssetsVc.init()
        asset.assetType = .coin
        self.yy_viewController?.navigationController?.pushViewController(asset, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

