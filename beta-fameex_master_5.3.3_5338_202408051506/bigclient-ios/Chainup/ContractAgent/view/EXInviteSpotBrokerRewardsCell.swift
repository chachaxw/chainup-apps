//
//  EXInviteSpotBrokerRewardsCell.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/14.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit

class EXInviteSpotBrokerRewardsCell: EXInviteBasicCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    lazy var leftV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.topText = "invitation_number_people".localized()
        v.bottomText = "--"
        return v
    }()
    
    lazy var middleV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomLabel.textColor = .Ex.text1
        v.topText = "invitation_ratio_commission".localized()
        v.bottomText = "--"
        return v
    }()
    
    lazy var rightV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.textAlignment = .right
        v.topText = "total_commission".localized()
        v.bottomText = "--"
        return v
    }()


    override func onCreate() {
        super.onCreate()
        titleView.titleLabel.text = "spot_trading_broker".localized()
        titleView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        contentView.addSubViews([titleView, leftV, middleV, rightV])
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        leftV.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        middleV.snp.makeConstraints { make in
            make.centerY.height.equalTo(leftV)
            make.left.greaterThanOrEqualTo(leftV.snp.right).offset(2)
            make.centerX.equalToSuperview()
        }
        rightV.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.height.equalTo(leftV)
            make.left.greaterThanOrEqualTo(middleV.snp.right).offset(2)
        }
        leftV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        rightV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        middleV.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
     func setInvitePublicConfigModel(_ config: EXInvitationPublicConfigModel?, spotModel: EXInvitationSpotDataModel?) {
        super.setInvitePublicConfigModel(config)
         if let invitationRuleUrl = config?.config.invitationRuleUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !invitationRuleUrl.isEmpty {
             titleView.ruleButton.isHidden = false
         }
         leftV.bottomText = spotModel?.userCount.toCurrencyFormat()
         middleV.bottomText = (spotModel?.scaleOfDecimal() ?? "--") + "%"
         rightV.topText = "invitation_total_commission".localized() + "（\(spotModel?.allBonusCoin ?? ""))"
         rightV.bottomText = spotModel?.allBonusAmount.formatAmount("USDT").toCurrencyFormat()
    }
}
