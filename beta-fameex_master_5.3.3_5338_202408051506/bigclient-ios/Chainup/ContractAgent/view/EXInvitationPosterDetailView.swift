//
//  EXInvitationPosterDetailView.swift
//  Chainup
//
//  Created by chainup on 2023/9/1.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

class EXInvitationPosterDetailView: UIView {
    
    lazy var posterImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    
    lazy var infoBgView: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill2
        return v
    }()
    
    lazy var inviteCodeImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        return v
    }()
    
    lazy var userPhoneLabel: UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text1
        v.font = .Ex.medium(10)
        v.numberOfLines = 1
        v.text = UserInfoEntity.sharedInstance().userAccount
        return v
    }()
    
    lazy var tipLabel: UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text1
        v.font = .Ex.regular(6)
        v.numberOfLines = 2
        v.text = String(format: "invite_you_qr".localized(), EXKitStanders.getAppName())
        return v
    }()
    
     lazy var contentView: UIView = {
        let v = UIView()
        v.extSetCornerRadius(6)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
//        let inviteUrl = UserInfoEntity.sharedInstance().inviteUrl.trimmingCharacters(in: .whitespacesAndNewlines)
//        if !inviteUrl.isEmpty {
//            inviteCodeImageView.image = QRCodeCreate().creteScancode(inviteUrl)
//        }
        backgroundColor = .Ex.fill2
        extSetCornerRadius(6)
        layer.masksToBounds = false
        contentView.extSetShadowColor(.Ex.main1.withAlphaComponent(0.2),
                                      shadowOffset: .init(width: 0, height: -1),
                                      opacity: 0.8,
                                      shadowRadius: 3)
        addSubViews([contentView])
        contentView.addSubViews([posterImageView, infoBgView])
        infoBgView.addSubViews([userPhoneLabel, tipLabel, inviteCodeImageView])
        ///
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        ///
        posterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(posterImageView.snp.width).multipliedBy(1.592)
        }
        infoBgView.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        ///
        userPhoneLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(6)
        }
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(userPhoneLabel.snp.bottom).offset(2)
            make.left.width.equalTo(userPhoneLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
        inviteCodeImageView.snp.makeConstraints { make in
            make.left.equalTo(userPhoneLabel.snp.right).offset(6)
            make.right.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        userPhoneLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        tipLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func updatePoster(inviteUrl: String? = nil) {
        if let inviteUrl = inviteUrl, !inviteUrl.isEmpty {
            inviteCodeImageView.image = QRCodeCreate().creteScancode(inviteUrl)
        }
    }
    
    func updatePosterLayoutIfNeed(posterImage: UIImage? = nil, 
                                  qrCodeImage: UIImage? = nil,
                                  account: String? = nil,
                                  tipNotes: String? = nil) {
        backgroundColor = .Ex.fill2
        contentView.extSetCornerRadius(0)
        userPhoneLabel.textColor = .Ex.text1
        userPhoneLabel.font = .Ex.medium(18)
        tipLabel.textColor = .Ex.text2
        tipLabel.font = .Ex.regular(12)
        posterImageView.image = posterImage
        userPhoneLabel.text = account
        tipLabel.text = tipNotes
        inviteCodeImageView.image = qrCodeImage
        infoBgView.snp.makeConstraints { $0.height.equalTo(70)}
        inviteCodeImageView.snp.updateConstraints { $0.size.equalTo(CGSize(width: 48, height: 48)) }
    }
}


