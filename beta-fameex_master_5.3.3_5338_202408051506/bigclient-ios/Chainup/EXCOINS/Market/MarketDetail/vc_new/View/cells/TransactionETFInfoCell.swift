//
//  TransactionETFInfoCell.swift
//  Chainup
//
//  Created by youbin on 2023/6/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class TransactionETFInfoCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorLite
        v.font = UIFont.ThemeFont.HeadBold
        return v
    }()
    
    lazy var introLabel: UILabel = {
        let v = UILabel()
        v.extUseAutoLayout()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemekLine.labcolorMedium
        v.font = UIFont.ThemeFont.BodyMedium
        return v
    }()
    
    //lever
    lazy var leverV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.isTopLine = true
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "etf_info_lever".localized()
        v.subtitleLabel.text = "--/--"
        return v
    }()
    
    //net worth
    lazy var networthV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "etf_text_networth".localized()
        v.subtitleLabel.text = "--"
        return v
    }()
    
    //Regular warehouse adjustment
    lazy var melodyV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "etf_info_rules".localized()
        v.subtitleLabel.text = "etf_notes_auto_lever_time".localized()
        return v
    }()
    
    //Unscheduled warehouse adjustment
    lazy var multipleV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.text = "etf_info_rules_no".localized()
        v.titleLabel.numberOfLines = 1
        v.subtitleLabel.numberOfLines = 0
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.subtitleLabel.text = String(format: "etf_notes_manual_lever_time".localized(), "--")
        return v
    }()
    
    //rate 
    lazy var rateV: EXTwofoldView = {
        let v = EXTwofoldView()
        v.extUseAutoLayout()
        v.type = .justifyAlign
        v.titleLabel.textColor = UIColor.ThemekLine.labcolorMedium
        v.subtitleLabel.textColor = UIColor.ThemekLine.labcolorLite
        v.topLineColor = UIColor.ThemekLine.viewSeperator
        v.bottomLineColor = UIColor.ThemekLine.viewSeperator
        v.titleLabel.text = "cl_funding_rate_str".localized()
        return v
    }()
    
    lazy var backStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 0
        v.distribution = .fillEqually
        v.alignment = .fill
        v.addArrangedSubviews([leverV, networthV, melodyV, multipleV, rateV])
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        // Configure the view for the selected state
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.ThemekLine.viewBg
        contentView.backgroundColor = UIColor.ThemekLine.viewBg
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        contentView.addSubViews([titleLabel, introLabel, backStack])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(0)
        }
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16).priority(750)
            make.top.equalToSuperview().priority(650)
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(0)
        }
        backStack.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(13).priority(750)
            make.top.equalTo(titleLabel.snp.bottom).priority(700)
            make.top.equalToSuperview().priority(650)
            make.left.right.equalToSuperview()
            make.height.equalTo(230)
            make.bottom.equalToSuperview()
        }
    }
    
    
    func bindModel(_ model:(CoinMapEntity, EXETFNetValueModel)) {
        let entity   = model.0
        let networth = model.1
        var mText = ""
        if entity.etfSide == "S" {
            mText = String(format: "etf_notes_title_mul".localized(), entity.etfMultiple) + "etf_notes_title_action_short".localized() + entity.etfBase
        } else {
            mText = String(format: "etf_notes_title_mul".localized(), entity.etfMultiple) + "etf_notes_title_action_long".localized() + entity.etfBase
        }
        
        titleLabel.text = entity.coinName + "[\(mText)]"
        introLabel.text = entity.getETFNotesAttributes("etf_notes_explain").string
        leverV.subtitleLabel.text = "\(networth.maxLeverValue)/\(networth.realLeverValue)"
        networthV.subtitleLabel.text = networth.price
        multipleV.subtitleLabel.text = String(format: "etf_notes_manual_lever_time".localized(), networth.maxLeverValue)
        rateV.subtitleLabel.text = entity.fundRate.isEmpty ? "--" : entity.fundRate
    }
    
    
   static func getHeightByContent(_ content: String) -> CGFloat {
        let introHeight = ceil(30)
        return CGFloat(introHeight + 280 + 49)
    }
    
    
}

