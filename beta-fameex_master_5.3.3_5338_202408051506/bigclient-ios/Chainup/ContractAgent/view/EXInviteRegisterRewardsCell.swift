//
//  EXInviteRewardsCell.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/14.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXInviteRegisterRewardsCell: EXInviteBasicCell {
    
    lazy var leftV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.topText = "referral_inviteRewards_number".localized()
        v.bottomText = "--"
        return v
    }()
    
    lazy var rightV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.topText = "referral_inviteRewards_amount".localized()
        v.bottomText = "--"
        return v
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func onCreate() {
        super.onCreate()
        titleView.titleLabel.text = "referral_inviteRewards_".localized()
        titleView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        contentView.addSubViews([titleView, leftV, rightV])
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.width.equalToSuperview()
            make.height.equalTo(52)
        }
        leftV.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        rightV.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.height.width.equalTo(leftV)
            make.left.equalTo(leftV.snp.right).offset(2)
        }
    }
    
    
    override func setInvitePublicConfigModel(_ config: EXInvitationPublicConfigModel?) {
        super.setInvitePublicConfigModel(config)
        if let invitationRuleUrl = config?.config.invitationRuleUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !invitationRuleUrl.isEmpty {
            titleView.ruleButton.isHidden = false
        }
        leftV.bottomText = config?.inviteUserCount
        rightV.bottomText = config?.inviteRewardUsdtSum.formatAmount("USDT")
    }
    

}
