//
//  EXTradingWithInfoView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/27.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXTradingWithInfoView: UIView {
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInset)}
        }
    }
    
    lazy var userAvatarView: EXAvatarView = {
        let v = EXAvatarView()
        return v
    }()
    
    lazy var stacks: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = nil
        v.axis = .horizontal
        v.spacing = 10
        return v
    }()
    
    lazy var infoView: EXThreeColumnView = {
        let v = EXThreeColumnView()
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    func onCreate() {
        addSubview(contentView)
        contentView.addSubViews([userAvatarView, stacks, infoView])
        ///
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInset)
        }
        ///
        userAvatarView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.height.equalTo(26)
        }
        stacks.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(userAvatarView.snp.right).offset(4)
            make.right.equalToSuperview()
            make.height.lessThanOrEqualTo(26)
            make.centerY.equalTo(userAvatarView)
        }
        infoView.snp.makeConstraints { make in
            make.top.equalTo(userAvatarView.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(32)
            make.bottom.equalToSuperview()
        }
    }
    
    func bindTradingWithData(item:EXOTCWantedModel) {
        
        userAvatarView.bindAvatarInfo(name: item.otcNickName, avatarImg: item.imageUrl, userOnline: item.loginStatus == "1")
        if item.payments.count > 0 {
            self.stacks.removeAllArrangedSubviews()
            for item in item.payments {
                let imageView = UIImageView.init()
                imageView.yy_setImage(with: URL.init(string:item.icon), placeholder: nil)
                stacks.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { (make) in
                    make.width.height.equalTo(16)
                }
            }
        }
        
        let model = ExThreeColumnDataModel()
        model.title = "charge_text_volume_frequency".localized()
        model.content = item.completeOrders
        model.style = self.getStyle()
        let modelm = ExThreeColumnDataModel()
        modelm.title = "otc_text_merchantCredit".localized()
        modelm.content = item.creditGrade
        modelm.style = self.getStyle()
        let modelr = ExThreeColumnDataModel()
        modelr.title = "otc_text_totalBargainAmount".localized()
        modelr.content = item.turnover.formatAmount("BTC")
        modelr.style = self.getStyle()
        infoView.bindItems(with: [model,modelm,modelr])
        
    }
    
    func getStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.topLabelFont = .Ex.regular(12)
        style.bottomLabelColor = .Ex.text1
        return style
    }
    
}
