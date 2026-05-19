//
//  EXInviteRegisterRewardsListCell.swift
//  Chainup
//
//  Created by bradjohn on 2024/3/15.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXInviteRegisterRewardsListCell: UITableViewCell {
    
   private lazy var uidV: EXInviteRegisterRewardsCellLabel = {
        let v = EXInviteRegisterRewardsCellLabel()
       v.leftText = "referral_inviteRewards_invitation_UID".localized()
        return v
    }()
    
    private lazy var accountV: EXInviteRegisterRewardsCellLabel = {
         let v = EXInviteRegisterRewardsCellLabel()
        v.leftText = "referral_inviteRewards_invitation_account".localized()
         return v
     }()
    
    private lazy var typeV: EXInviteRegisterRewardsCellLabel = {
         let v = EXInviteRegisterRewardsCellLabel()
        v.leftText = "referral_inviteRewards_invitation_type".localized()
        v.rightText = "--"
         return v
     }()
    
    private lazy var registerDateV: EXInviteRegisterRewardsCellLabel = {
         let v = EXInviteRegisterRewardsCellLabel()
        v.leftText = "referral_inviteRewards_invitation_time".localized()
         return v
     }()
    
    private lazy var releaseTimeV: EXInviteRegisterRewardsCellLabel = {
         let v = EXInviteRegisterRewardsCellLabel()
        v.leftText = "invite_reward_issue_date".localized()
         return v
     }()
    
    private lazy var rewardsV: EXInviteRegisterRewardsCellLabel = {
         let v = EXInviteRegisterRewardsCellLabel()
        v.leftText = "referral_inviteRewards_amount".localized()
         return v
     }()


   private lazy var stackView: EXStackView = {
        let v = EXStackView()
       v.separatorConfiguration = .init(color: .clear)
       v.distribution = .fill
       v.axis = .vertical
       v.spacing = 0
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        extSetCell(.clear,isRemoveSelectedBackgroundView: true)
        contentView.extSetCornerRadius(4)
        contentView.backgroundColor = .Ex.special2
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        contentView.addSubViews([stackView])
        stackView.addArrangedSubviews([uidV, releaseTimeV, accountV, typeV, registerDateV,
                                        rewardsV])
        stackView.subviews.forEach { subview in
            if subview is EXInviteRegisterRewardsCellLabel {
                subview.isHidden = true
                subview.snp.makeConstraints { $0.height.equalTo(32) }
            }
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
    }
    
    func setModel(_ model: EXMyInvitationsItemModel, _ inviteType: EXInviteRegisterType) {
        if inviteType == .invited {
            uidV.isHidden = false
            accountV.isHidden = false
            typeV.isHidden = false
            registerDateV.isHidden = false
            
            uidV.rightText = model.levelZeroRegisterUid
            accountV.rightText = model.levelZeroRegisterAccount
            typeV.rightText = model.levelStr
            registerDateV.rightText = model.registerTime.isEmpty ? "" : DateTools.strToTimeString(model.registerTime, dateFormat:"yyyy-MM-dd")
            
            return
        }
        
        if inviteType == .reward {
            releaseTimeV.isHidden = false
            accountV.isHidden = false
            rewardsV.isHidden = false
            releaseTimeV.rightText = model.sendTime.isEmpty ? "" : DateTools.strToTimeString(model.sendTime, dateFormat:"yyyy-MM-dd")
            accountV.rightText = model.userAccountNum
            
            var showPrecision = "2"
            if let entity = EXAppMarketManager.sharedInstance.getCoinEntity("USDT") {
               showPrecision = entity.showPrecision
            }
            rewardsV.rightText = model.conversionAmount?.formatAmountUseDecimal(showPrecision)
            return
        }
    }
    
}

private class EXInviteRegisterRewardsCellLabel: UIView {
    
    var leftText: String? {
        didSet {
            leftLabel.text = leftText
        }
    }
    
    var rightText: String? {
        didSet {
            rightLabel.text = rightText?.count != 0 ? rightText : "--"
        }
    }
    
    lazy var leftLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text2, numberOfLines: 1)
        return v
    }()
    
    lazy var rightLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text1, numberOfLines: 1)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([leftLabel, rightLabel])
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.height.equalToSuperview()
            make.left.greaterThanOrEqualTo(leftLabel.snp.right).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
