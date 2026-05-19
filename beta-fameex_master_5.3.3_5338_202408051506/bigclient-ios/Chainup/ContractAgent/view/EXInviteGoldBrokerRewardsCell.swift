//
//  EXInviteGoldBrokerRewardsCell.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/14.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit

class EXInviteGoldBrokerRewardsCell: EXInviteBasicCell {

    lazy var directRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_return".localized()
        v.bottomText = "106"
        return v
    }()
    
    lazy var secondRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_level2return".localized()
        v.bottomText = "46626.4236"
        return v
    }()
    
    lazy var subAgentRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_childReturn".localized()
        v.bottomText = "46626.4236"
        return v
    }()
    
    ///
    lazy var customersAmountV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.topText = "coAgent_text_childTotal".localized()
        v.bottomText = "46626.4236"
        return v
    }()
    lazy var totalRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.textAlignment = .right
        v.topText = "coAgent_text_childTotalUSDT".localized()
        v.bottomText = "46626.4236"
        return v
    }()
    ///
    lazy var yesterdayRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.topText = "coAgent_text_yesterdayReturn".localized()
        v.bottomText = "46626.4236"
        return v
    }()

    lazy var beforeYesterdayRebateV: EXInviteVerticalView = {
        let v = EXInviteVerticalView()
        v.bottomTextColor = .Ex.text1
        v.textAlignment = .right
        v.topText = "coAgent_text_byesterdayReturn".localized()
        v.bottomText = "46626.4236"
        return v
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func onCreate() {
        super.onCreate()
        titleView.titleLabel.text = "金牌经纪人".localized()
        titleView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        contentView.addSubViews([titleView,
                                 directRebateV, secondRebateV, subAgentRebateV,
                                 customersAmountV, totalRebateV,
                                 yesterdayRebateV, beforeYesterdayRebateV])
        titleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.width.equalToSuperview()
            make.height.equalTo(52)
        }
        
        ///
        directRebateV.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(40)
        }
        secondRebateV.snp.makeConstraints { make in
            make.centerY.height.equalTo(directRebateV)
            make.left.greaterThanOrEqualTo(directRebateV.snp.right).offset(2)
            make.centerX.equalToSuperview()
        }
        subAgentRebateV.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.height.equalTo(directRebateV)
            make.left.greaterThanOrEqualTo(secondRebateV.snp.right).offset(2)
        }
        directRebateV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        subAgentRebateV.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        secondRebateV.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        ///
        customersAmountV.snp.makeConstraints { make in
            make.top.equalTo(directRebateV.snp.bottom).offset(15)
            make.left.height.equalTo(directRebateV)
        }
        totalRebateV.snp.makeConstraints { make in
            make.centerY.height.equalTo(customersAmountV)
            make.left.greaterThanOrEqualTo(customersAmountV.snp.right).offset(2)
            make.right.equalTo(subAgentRebateV.snp.right)
        }
        ///
        yesterdayRebateV.snp.makeConstraints { make in
            make.top.equalTo(customersAmountV.snp.bottom).offset(15)
            make.left.height.equalTo(directRebateV)
            make.bottom.equalToSuperview().offset(-20)
        }
        beforeYesterdayRebateV.snp.makeConstraints { make in
            make.centerY.height.equalTo(yesterdayRebateV)
            make.left.greaterThanOrEqualTo(yesterdayRebateV.snp.right).offset(2)
            make.right.equalTo(subAgentRebateV.snp.right)
        }
    }

}
